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
  }) {
    if (!price.isPositive) {
      throw ArgumentError.value(price, 'price', 'must be positive');
    }
    if (lifespanDays < 1) {
      throw ArgumentError.value(lifespanDays, 'lifespanDays', 'must be at least 1');
    }
  }

  final String id;
  final Money price;
  final int lifespanDays;
  final CivilDate lastRestock;

  CivilDate get expectedRestock => lastRestock.addDays(lifespanDays);

  int daysLeftOn(CivilDate today) {
    final left = today.daysUntil(expectedRestock);
    return left < 0 ? 0 : left;
  }
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
  static SupplyReserve supplyReserve(SupplyItemState item, CycleWindow window) {
    final steady = item.price.times(window.length).ceilDiv(item.lifespanDays);
    return SupplyReserve(
      itemId: item.id,
      increment: steady.atMost(item.price),
      daysUntilDue: item.daysLeftOn(window.start),
    );
  }

  static List<SupplyReserve> supplyReserves(Iterable<SupplyItemState> items, CycleWindow window) =>
      [for (final item in items) supplyReserve(item, window)];

  static Money essentialsTarget(Iterable<SupplyItemState> items) =>
      Money.sum(items.map((item) => item.price));

  static Money recurringIncrement(Iterable<RecurringCostState> costs) =>
      Money.sum(costs.map((cost) => cost.amount.ceilDiv(cost.everyMonths)));
}
