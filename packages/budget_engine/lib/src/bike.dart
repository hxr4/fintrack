import 'civil_date.dart';
import 'money.dart';

final class BikeServicePlan {
  const BikeServicePlan({
    this.intervalKm,
    this.intervalMonths,
    this.cost = Money.zero,
    this.lastServiceDate,
    this.lastServiceKm,
  });

  final int? intervalKm;
  final int? intervalMonths;
  final Money cost;
  final CivilDate? lastServiceDate;
  final int? lastServiceKm;

  CivilDate? get dueByDate {
    final last = lastServiceDate;
    final months = intervalMonths;
    if (last == null || months == null) {
      return null;
    }
    return CivilDate.clamped(last.year, last.month + months, last.day);
  }

  int? get dueByKm {
    final last = lastServiceKm;
    final interval = intervalKm;
    if (last == null || interval == null) {
      return null;
    }
    return last + interval;
  }
}

final class ServiceDue {
  const ServiceDue({required this.dueByDate, required this.dueByKm, required this.kmLeft, required this.daysLeft});

  final CivilDate? dueByDate;
  final int? dueByKm;
  final int? kmLeft;
  final int? daysLeft;

  bool get isKnown => daysLeft != null || kmLeft != null;
  bool get isDue => (daysLeft != null && daysLeft! <= 0) || (kmLeft != null && kmLeft! <= 0);
}

abstract final class BikeSchedule {
  static const fallbackDaysUntilService = 180;

  static int? daysUntil(CivilDate? date, CivilDate today) => date == null ? null : today.daysUntil(date);

  static ServiceDue serviceDue({
    required BikeServicePlan plan,
    required CivilDate today,
    int? currentKm,
    int ridingKm = 0,
    int ridingDays = 0,
  }) {
    final byDate = plan.dueByDate;
    final byKm = plan.dueByKm;
    final kmLeft = byKm == null || currentKm == null ? null : byKm - currentKm;
    int? daysFromKm;
    if (kmLeft != null && ridingKm > 0 && ridingDays > 0) {
      daysFromKm = kmLeft <= 0 ? 0 : (kmLeft * ridingDays) ~/ ridingKm;
    }
    final daysFromDate = daysUntil(byDate, today);
    int? daysLeft;
    if (daysFromDate != null && daysFromKm != null) {
      daysLeft = daysFromDate < daysFromKm ? daysFromDate : daysFromKm;
    } else {
      daysLeft = daysFromDate ?? daysFromKm;
    }
    return ServiceDue(dueByDate: byDate, dueByKm: byKm, kmLeft: kmLeft, daysLeft: daysLeft);
  }

  static Money fundIncrement({
    required Money serviceCost,
    required Money fundBalance,
    required int? daysUntilDue,
    required int cycleLength,
  }) {
    final remaining = (serviceCost - fundBalance.positivePart).positivePart;
    if (remaining.isZero) {
      return Money.zero;
    }
    final days = daysUntilDue ?? fallbackDaysUntilService;
    if (days < cycleLength) {
      return remaining;
    }
    return remaining.times(cycleLength).ceilDiv(days).atMost(remaining);
  }
}
