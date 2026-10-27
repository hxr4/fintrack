import 'civil_date.dart';
import 'money.dart';

final class FuelFill {
  FuelFill({
    required this.id,
    required this.date,
    required this.amount,
    required this.pricePerLitre,
    required this.odometerKm,
    required this.fullTank,
  }) {
    if (!amount.isPositive) {
      throw ArgumentError.value(amount, 'amount', 'must be positive');
    }
    if (!pricePerLitre.isPositive) {
      throw ArgumentError.value(pricePerLitre, 'pricePerLitre', 'must be positive');
    }
    if (odometerKm < 0) {
      throw ArgumentError.value(odometerKm, 'odometerKm', 'must not be negative');
    }
  }

  final String id;
  final CivilDate date;
  final Money amount;
  final Money pricePerLitre;
  final int odometerKm;
  final bool fullTank;

  int get litresMl => litresFor(amount: amount, pricePerLitre: pricePerLitre);

  static int litresFor({required Money amount, required Money pricePerLitre}) =>
      (amount.paise * 1000 + pricePerLitre.paise ~/ 2) ~/ pricePerLitre.paise;
}

final class MileageSegment {
  const MileageSegment({
    required this.fromFillId,
    required this.toFillId,
    required this.distanceKm,
    required this.fuelMl,
    required this.cost,
  });

  final String fromFillId;
  final String toFillId;
  final int distanceKm;
  final int fuelMl;
  final Money cost;

  int get kmPerLitreTenths => (distanceKm * 10000 + fuelMl ~/ 2) ~/ fuelMl;

  Money get costPerKm => Money((cost.paise + distanceKm ~/ 2) ~/ distanceKm);
}

final class FuelSummary {
  const FuelSummary({
    required this.segments,
    required this.averageKmPerLitreTenths,
    required this.averageCostPerKm,
    required this.ridingKm,
    required this.ridingDays,
    required this.recentDistanceKm,
    required this.recentCost,
  });

  final List<MileageSegment> segments;
  final int? averageKmPerLitreTenths;
  final Money? averageCostPerKm;
  final int ridingKm;
  final int ridingDays;
  final int recentDistanceKm;
  final Money recentCost;

  MileageSegment? get latest => segments.isEmpty ? null : segments.last;

  bool get hasRidingRate => ridingKm > 0 && ridingDays > 0;

  int? get kmPerDayTenths => hasRidingRate ? (ridingKm * 10 + ridingDays ~/ 2) ~/ ridingDays : null;

  Money? suggestedPerCycle(int cycleLength) {
    if (!hasRidingRate || recentDistanceKm == 0) {
      return null;
    }
    final numerator = recentCost.paise * ridingKm * cycleLength;
    final denominator = recentDistanceKm * ridingDays;
    return Money((numerator + denominator - 1) ~/ denominator);
  }
}

abstract final class FuelLog {
  static List<FuelFill> sorted(Iterable<FuelFill> fills) => [...fills]
    ..sort((a, b) {
      final byOdometer = a.odometerKm.compareTo(b.odometerKm);
      if (byOdometer != 0) {
        return byOdometer;
      }
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });

  static List<MileageSegment> segments(Iterable<FuelFill> fills) {
    final ordered = sorted(fills);
    final result = <MileageSegment>[];
    FuelFill? lastFull;
    var fuelMl = 0;
    var cost = Money.zero;
    for (final fill in ordered) {
      if (lastFull == null) {
        if (fill.fullTank) {
          lastFull = fill;
        }
        continue;
      }
      fuelMl += fill.litresMl;
      cost += fill.amount;
      if (fill.fullTank) {
        final distance = fill.odometerKm - lastFull.odometerKm;
        if (distance > 0 && fuelMl > 0) {
          result.add(MileageSegment(
            fromFillId: lastFull.id,
            toFillId: fill.id,
            distanceKm: distance,
            fuelMl: fuelMl,
            cost: cost,
          ));
        }
        lastFull = fill;
        fuelMl = 0;
        cost = Money.zero;
      }
    }
    return result;
  }

  static FuelSummary summarise(
    Iterable<FuelFill> fills, {
    required CivilDate today,
    int recentSegments = 3,
    int ridingWindowDays = 30,
  }) {
    final all = segments(fills);
    final recent = all.length > recentSegments ? all.sublist(all.length - recentSegments) : all;
    final distance = recent.fold(0, (sum, segment) => sum + segment.distanceKm);
    final fuel = recent.fold(0, (sum, segment) => sum + segment.fuelMl);
    final cost = Money.sum(recent.map((segment) => segment.cost));

    final windowStart = today.addDays(-ridingWindowDays);
    final inWindow = sorted(fills).where((fill) => !fill.date.isBefore(windowStart)).toList();
    var ridingKm = 0;
    var ridingDays = 0;
    if (inWindow.length >= 2) {
      ridingKm = inWindow.last.odometerKm - inWindow.first.odometerKm;
      ridingDays = inWindow.first.date.daysUntil(inWindow.last.date);
    }
    return FuelSummary(
      segments: all,
      averageKmPerLitreTenths: fuel == 0 ? null : (distance * 10000 + fuel ~/ 2) ~/ fuel,
      averageCostPerKm: distance == 0 ? null : Money((cost.paise + distance ~/ 2) ~/ distance),
      ridingKm: ridingKm < 0 ? 0 : ridingKm,
      ridingDays: ridingDays < 0 ? 0 : ridingDays,
      recentDistanceKm: distance,
      recentCost: cost,
    );
  }
}
