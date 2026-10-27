import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  final window = windowFrom('2026-01-05');

  test('an item due inside the cycle gets everything still to save', () {
    final reserve = ReserveCalculator.supplyReserve(
      SupplyItemState(id: 'soap', price: Money.rupees(90), lifespanDays: 45, lastRestock: d('2025-12-20')),
      window,
    );
    expect(reserve.increment, Money.rupees(90));
    expect(reserve.daysUntilDue, 29);
  });

  test('an item due later gets the larger of steady rate and catch-up', () {
    final reserve = ReserveCalculator.supplyReserve(
      SupplyItemState(id: 'shampoo', price: Money.rupees(90), lifespanDays: 90, lastRestock: d('2026-01-01')),
      window,
    );
    expect(reserve.daysUntilDue, 86);
    expect(reserve.increment, Money(3245));
  });

  test('steady rate wins when the item is already partly saved for', () {
    final reserve = ReserveCalculator.supplyReserve(
      SupplyItemState(
        id: 'shampoo',
        price: Money.rupees(90),
        lifespanDays: 90,
        lastRestock: d('2026-01-01'),
        saved: Money.rupees(40),
      ),
      window,
    );
    expect(reserve.increment, Money(3100));
  });

  test('a fully saved item needs nothing more', () {
    final reserve = ReserveCalculator.supplyReserve(
      SupplyItemState(id: 'x', price: Money.rupees(90), lifespanDays: 90, lastRestock: d('2026-01-01'), saved: Money.rupees(90)),
      window,
    );
    expect(reserve.increment, Money.zero);
  });

  test('restocking learns the lifespan with a moving average and uses up the savings', () {
    final item = SupplyItemState(
      id: 'soap',
      price: Money.rupees(90),
      lifespanDays: 45,
      lastRestock: d('2026-01-01'),
      saved: Money.rupees(90),
    );
    final after = ReserveCalculator.restock(item, on: d('2026-02-10'), paid: Money.rupees(95));
    expect(after.lifespanDays, 43);
    expect(after.saved, Money.zero);
    expect(after.price, Money.rupees(95));
    expect(after.lastRestock, d('2026-02-10'));
  });

  test('the first restock after a guessed date does not teach the lifespan', () {
    final item = SupplyItemState(
      id: 'soap',
      price: Money.rupees(90),
      lifespanDays: 45,
      lastRestock: d('2026-01-01'),
      lastRestockEstimated: true,
    );
    final after = ReserveCalculator.restock(item, on: d('2026-01-11'), paid: Money.rupees(90));
    expect(after.lifespanDays, 45);
    expect(after.lastRestockEstimated, isFalse);
    final next = ReserveCalculator.restock(after, on: d('2026-02-10'), paid: Money.rupees(90));
    expect(next.lifespanDays, 39);
  });

  test('allocation adds to savings without passing the price', () {
    final item = SupplyItemState(id: 'x', price: Money.rupees(90), lifespanDays: 30, lastRestock: d('2026-01-01'), saved: Money.rupees(80));
    expect(ReserveCalculator.afterAllocation(item, Money.rupees(50)).saved, Money.rupees(90));
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
