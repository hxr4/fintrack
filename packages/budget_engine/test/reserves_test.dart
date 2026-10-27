import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  final window = windowFrom('2026-01-05');

  test('steady supply set-aside is price over lifespan times cycle length, rounded up', () {
    final reserve = ReserveCalculator.supplyReserve(
      SupplyItemState(id: 'soap', price: Money.rupees(90), lifespanDays: 45, lastRestock: d('2025-12-20')),
      window,
    );
    expect(reserve.increment, Money(6200));
    expect(reserve.daysUntilDue, 29);
  });

  test('set-aside never exceeds the item price', () {
    final reserve = ReserveCalculator.supplyReserve(
      SupplyItemState(id: 'tissue', price: Money.rupees(40), lifespanDays: 10, lastRestock: d('2026-01-01')),
      window,
    );
    expect(reserve.increment, Money.rupees(40));
  });

  test('overdue items are due now', () {
    final item = SupplyItemState(id: 'x', price: Money.rupees(10), lifespanDays: 5, lastRestock: d('2025-11-01'));
    expect(item.daysLeftOn(d('2026-01-05')), 0);
  });

  test('recurring increment splits each cost over its months', () {
    expect(
      ReserveCalculator.recurringIncrement([
        RecurringCostState(id: 'a', amount: Money.rupees(1200), everyMonths: 12),
        RecurringCostState(id: 'b', amount: Money.rupees(100), everyMonths: 3),
      ]),
      Money.rupees(100) + Money(3334),
    );
  });

  test('essentials target is the sum of item prices', () {
    expect(
      ReserveCalculator.essentialsTarget([
        SupplyItemState(id: 'a', price: Money.rupees(90), lifespanDays: 45, lastRestock: d('2026-01-01')),
        SupplyItemState(id: 'b', price: Money.rupees(60), lifespanDays: 30, lastRestock: d('2026-01-01')),
      ]),
      Money.rupees(150),
    );
  });
}
