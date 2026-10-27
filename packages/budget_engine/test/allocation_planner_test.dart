import 'dart:math';

import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

Money rs(int paise) => Money(paise);

void main() {
  final settings = standardSettings();

  CyclePlan planFor(
    int rupees, {
    String start = '2026-01-05',
    List<int> previous = const [],
    ReserveInputs reserves = const ReserveInputs(),
    Money carryInToPool = Money.zero,
  }) =>
      AllocationPlanner.plan(PlanInput(
        window: windowFrom(start),
        cycleDeposits: [installment(rupees, start)],
        settings: settings,
        previousInstallmentTotals: [for (final value in previous) Money.rupees(value)],
        reserves: reserves,
        carryInToPool: carryInToPool,
      ));

  test('12,000 over 31 days: reserves first, then weights on the remainder', () {
    final plan = planFor(12000);
    expect(plan.allocations[BudgetCategory.nightFoodStock], rs(75000));
    expect(plan.allocations[BudgetCategory.food], rs(675000));
    expect(plan.allocations[BudgetCategory.petrol], rs(157500));
    expect(plan.allocations[BudgetCategory.outings], rs(101250));
    expect(plan.allocations[BudgetCategory.trySomethingNew], rs(45000));
    expect(plan.allocations[BudgetCategory.misc], rs(33750));
    expect(plan.allocations[BudgetCategory.buffer], rs(112500));
    expect(plan.total, Money.rupees(12000));
    expect(plan.foodFloor, Money.rupees(4650));
    expect(plan.petrolFloor, Money.rupees(1240));
    expect(plan.hasShortfall, isFalse);
  });

  test('night food stock tops up to its target instead of adding the full target', () {
    final plan = planFor(12000, reserves: ReserveInputs(nightFoodCarried: Money.rupees(200)));
    expect(plan.allocations[BudgetCategory.nightFoodStock], Money.rupees(550));
    final full = planFor(12000, reserves: ReserveInputs(nightFoodCarried: Money.rupees(900)));
    expect(full.allocations[BudgetCategory.nightFoodStock], Money.zero);
  });

  test('positive delta is shared by the generosity rule', () {
    final plan = planFor(12000, previous: [11000]);
    expect(plan.delta, Money.rupees(1000));
    final base = planFor(11000);
    expect(plan.allocations[BudgetCategory.goals], Money.rupees(100));
    expect(plan.total, Money.rupees(12000));
    expect(plan.allocations[BudgetCategory.food]! - base.allocations[BudgetCategory.food]!, Money.rupees(500));
    expect(plan.allocations[BudgetCategory.outings]! - base.allocations[BudgetCategory.outings]!, Money.rupees(200));
  });

  test('negative delta is absorbed from Try something new, then Outings', () {
    final plan = planFor(11000, previous: [12000, 12000, 12000]);
    expect(plan.delta, Money.rupees(-1000));
    expect(plan.allocations[BudgetCategory.trySomethingNew], Money.zero);
    expect(plan.allocations[BudgetCategory.outings], rs(46250));
    expect(plan.allocations[BudgetCategory.buffer], rs(112500));
    expect(plan.allocations[BudgetCategory.food], rs(675000));
    expect(plan.total, Money.rupees(11000));
  });

  test('deep negative delta defers the least urgent supply, then trims Petrol and Food to floor', () {
    final plan = planFor(
      8500,
      previous: [12000],
      reserves: ReserveInputs(supplies: [
        SupplyReserve(itemId: 'shampoo', increment: Money.rupees(200), daysUntilDue: 60),
        SupplyReserve(itemId: 'soap', increment: Money.rupees(100), daysUntilDue: 10),
      ]),
    );
    expect(plan.deferredSupplies, {'shampoo': Money.rupees(200)});
    expect(plan.supplyAllocations['soap'], Money.rupees(100));
    expect(plan.allocations[BudgetCategory.petrol], plan.petrolFloor);
    expect(plan.allocations[BudgetCategory.food], rs(608150));
    expect(plan.hasShortfall, isFalse);
    expect(plan.total, Money.rupees(8500));
  });

  test('a deposit that cannot cover the floors cuts Petrol before Night food stock and shows the shortfall', () {
    final plan = planFor(5000);
    expect(plan.allocations[BudgetCategory.food], plan.foodFloor);
    expect(plan.allocations[BudgetCategory.petrol], Money.zero);
    expect(plan.allocations[BudgetCategory.nightFoodStock], Money.rupees(350));
    expect(plan.allocations[BudgetCategory.misc], Money.zero);
    expect(plan.shortfall, Money.rupees(1640));
    expect(plan.total, Money.rupees(5000));
  });

  test('Food is the last thing cut when money is truly short', () {
    final plan = planFor(3000);
    expect(plan.allocations[BudgetCategory.food], Money.rupees(3000));
    expect(plan.total, Money.rupees(3000));
  });

  test('carry into the pool is split by weights but is not part of the delta', () {
    final plan = planFor(12000, previous: [12000], carryInToPool: Money.rupees(1000));
    expect(plan.delta, Money.zero);
    expect(plan.total, Money.rupees(13000));
  });

  test('negative carry in reduces the money available', () {
    final plan = planFor(12000, carryInToPool: Money.rupees(-500));
    expect(plan.total, Money.rupees(11500));
  });

  test('base daily is the pool at cycle start divided by cycle length', () {
    final plan = planFor(12000);
    expect(plan.baseDaily, Money((675000 + 101250 + 45000) ~/ 31));
  });

  test('property: sums exact, no negatives, floors hold whenever affordable, deterministic', () {
    final random = Random(2026);
    for (var run = 0; run < 3000; run++) {
      final start = CivilDate(2025 + random.nextInt(4), 1 + random.nextInt(12), 1 + random.nextInt(28));
      final anchorDay = 1 + random.nextInt(31);
      final window = CycleCalendar.windowStartingOn(start, anchorDay: anchorDay, policy: policy);
      final supplies = [
        for (var item = 0; item < random.nextInt(4); item++)
          SupplyReserve(
            itemId: 'item$item',
            increment: Money(random.nextInt(60000)),
            daysUntilDue: random.nextInt(120),
          ),
      ];
      final reserves = ReserveInputs(
        nightFoodCarried: Money(random.nextInt(100000)),
        supplies: supplies,
        bikeFundIncrement: Money(random.nextInt(60000)),
        recurringIncrement: Money(random.nextInt(2) * random.nextInt(40000)),
      );
      final input = PlanInput(
        window: window,
        cycleDeposits: [
          Deposit(
            id: 'd',
            amount: Money(1 + random.nextInt(3000000)),
            receivedAt: KolkataTime.startOfDate(start),
            kind: DepositKind.installment,
          ),
        ],
        settings: settings,
        carryInToPool: Money(random.nextInt(700000) - 200000),
        previousInstallmentTotals: [
          for (var cycle = 0; cycle < random.nextInt(5); cycle++) Money(500000 + random.nextInt(1500000)),
        ],
        completedCycleSpends: [
          for (var cycle = 0; cycle < random.nextInt(6); cycle++)
            {
              for (final category in BudgetCategory.blended) category: Money(random.nextInt(800000)),
            },
        ],
        reserves: reserves,
      );
      final plan = AllocationPlanner.plan(input);
      final available = (input.cycleDeposits.installmentTotal + input.carryInToPool).positivePart;
      expect(plan.total, available);
      expect(plan.allocations.values.every((amount) => !amount.isNegative), isTrue);

      final nightTopUp = (settings.nightFoodStockTarget - reserves.nightFoodCarried).positivePart;
      final dueSupplies = Money.sum(supplies.where((item) => item.daysUntilDue < window.length).map((item) => item.increment));
      final required = plan.foodFloor +
          plan.petrolFloor +
          nightTopUp +
          dueSupplies +
          reserves.bikeFundIncrement +
          reserves.recurringIncrement;
      expect(plan.shortfall, (required - available).positivePart);
      if (available >= required) {
        expect(plan.allocations[BudgetCategory.food]! >= plan.foodFloor, isTrue);
        expect(plan.allocations[BudgetCategory.petrol]! >= plan.petrolFloor, isTrue);
        expect(plan.allocations[BudgetCategory.nightFoodStock], nightTopUp);
      } else {
        expect(plan.allocations[BudgetCategory.food], Money.min(plan.foodFloor, available));
      }
      expect(plan.allocations[BudgetCategory.essentialsStock], Money.sum(plan.supplyAllocations.values));

      final again = AllocationPlanner.plan(input);
      expect(again.allocations, plan.allocations);
      expect(again.shortfall, plan.shortfall);
    }
  });
}
