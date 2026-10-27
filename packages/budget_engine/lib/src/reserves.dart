import 'allocation_planner.dart';
import 'civil_date.dart';
import 'cycle_calendar.dart';
import 'money.dart';

final class SupplyItemState {
  SupplyItemState({
    required this.id,
    required this.price,
    required this.lifespanDays,
    required this.lastRestock,
    this.saved = Money.zero,
    this.lastRestockEstimated = false,
  }) {
    if (!price.isPositive) {
      throw ArgumentError.value(price, 'price', 'must be positive');
    }
    if (lifespanDays < 1) {
      throw ArgumentError.value(lifespanDays, 'lifespanDays', 'must be at least 1');
    }
    if (saved.isNegative) {
      throw ArgumentError.value(saved, 'saved', 'must not be negative');
    }
  }

  final String id;
  final Money price;
  final int lifespanDays;
  final CivilDate lastRestock;
  final Money saved;
  final bool lastRestockEstimated;

  CivilDate get expectedRestock => lastRestock.addDays(lifespanDays);

  Money get stillToSave => (price - saved).positivePart;

  int daysLeftOn(CivilDate today) {
    final left = today.daysUntil(expectedRestock);
    return left < 0 ? 0 : left;
  }

  SupplyItemState copyWith({
    Money? price,
    int? lifespanDays,
    CivilDate? lastRestock,
    Money? saved,
    bool? lastRestockEstimated,
  }) =>
      SupplyItemState(
        id: id,
        price: price ?? this.price,
        lifespanDays: lifespanDays ?? this.lifespanDays,
        lastRestock: lastRestock ?? this.lastRestock,
        saved: saved ?? this.saved,
        lastRestockEstimated: lastRestockEstimated ?? this.lastRestockEstimated,
      );
}

final class RecurringCostState {
  RecurringCostState({required this.id, required this.amount, required this.everyMonths}) {
    if (!amount.isPositive) {
      throw ArgumentError.value(amount, 'amount', 'must be positive');
    }
    if (everyMonths < 1) {
      throw ArgumentError.value(everyMonths, 'everyMonths', 'must be at least 1');
    }
  }

  final String id;
  final Money amount;
  final int everyMonths;
}

abstract final class ReserveCalculator {
  static const lifespanLearningPercent = 40;

  static SupplyReserve supplyReserve(SupplyItemState item, CycleWindow window) {
    final remaining = item.stillToSave;
    final daysUntilDue = item.daysLeftOn(window.start);
    if (remaining.isZero) {
      return SupplyReserve(itemId: item.id, increment: Money.zero, daysUntilDue: daysUntilDue);
    }
    final steady = item.price.times(window.length).ceilDiv(item.lifespanDays);
    final needed = daysUntilDue < window.length
        ? remaining
        : remaining.times(window.length).ceilDiv(daysUntilDue);
    return SupplyReserve(
      itemId: item.id,
      increment: Money.max(steady, needed).atMost(remaining),
      daysUntilDue: daysUntilDue,
    );
  }

  static List<SupplyReserve> supplyReserves(Iterable<SupplyItemState> items, CycleWindow window) =>
      [for (final item in items) supplyReserve(item, window)];

  static Money essentialsTarget(Iterable<SupplyItemState> items) =>
      Money.sum(items.map((item) => item.price));

  static Money recurringIncrement(Iterable<RecurringCostState> costs) =>
      Money.sum(costs.map((cost) => cost.amount.ceilDiv(cost.everyMonths)));

  static SupplyItemState afterAllocation(SupplyItemState item, Money allocated) =>
      item.copyWith(saved: (item.saved + allocated).atMost(item.price));

  static SupplyItemState restock(SupplyItemState item, {required CivilDate on, required Money paid}) {
    if (!paid.isPositive) {
      throw ArgumentError.value(paid, 'paid', 'must be positive');
    }
    var lifespan = item.lifespanDays;
    if (!item.lastRestockEstimated && on.isAfter(item.lastRestock)) {
      final observed = item.lastRestock.daysUntil(on);
      lifespan = (item.lifespanDays * (100 - lifespanLearningPercent) +
              observed * lifespanLearningPercent +
              50) ~/
          100;
      if (lifespan < 1) {
        lifespan = 1;
      }
    }
    return item.copyWith(
      price: paid,
      lifespanDays: lifespan,
      lastRestock: on,
      saved: (item.saved - paid).positivePart,
      lastRestockEstimated: false,
    );
  }
}
