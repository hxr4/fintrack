import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  final capacity = SavingsCapacity(
    flexibleBalances: {
      BudgetCategory.outings: Money.rupees(300),
      BudgetCategory.trySomethingNew: Money.rupees(150),
      BudgetCategory.misc: Money.rupees(150),
      BudgetCategory.food: Money.rupees(5000),
    },
    daysLeftInCycle: 20,
    buffer: Money.rupees(1000),
    banked: Money.rupees(200),
    typicalOutingCost: Money.rupees(400),
    typicalTreatCost: Money.rupees(150),
  );

  PurchasePlan planFor(int rupees, {String? target, int saved = 0}) => PurchasePlanner.plan(
        request: PurchaseRequest(
          item: 'Headphones',
          price: Money.rupees(rupees),
          today: d('2026-04-15'),
          alreadySaved: Money.rupees(saved),
          targetDate: target == null ? null : d(target),
        ),
        capacity: capacity,
      );

  test('three scenarios with days, daily saving and trade-offs', () {
    final plan = planFor(2000);
    final fast = plan.scenario(ScenarioPace.fast);
    expect(fast.fromBanked, Money.rupees(200));
    expect(fast.fromBuffer, Money.rupees(500));
    expect(fast.dailySaving, Money(2250));
    expect(fast.days, 58);
    expect(fast.cuts[BudgetCategory.outings], Money.rupees(650));
    expect(fast.outingsSkipped, 2);
    expect(fast.treatsSkipped, 2);

    final balanced = plan.scenario(ScenarioPace.balanced);
    expect(balanced.fromBuffer, Money.zero);
    expect(balanced.days, 120);

    final slow = plan.scenario(ScenarioPace.slow);
    expect(slow.fromBanked, Money.zero);
    expect(slow.days, 267);
    expect(slow.reachedOn, d('2026-04-15').addDays(267));
  });

  test('savings never come from Food or Petrol', () {
    for (final scenario in planFor(2000).scenarios) {
      expect(scenario.cuts.keys.toSet(), BudgetCategory.flexibleSavingsSources.toSet());
    }
  });

  test('a reachable target date is marked feasible', () {
    final plan = planFor(2000, target: '2026-05-15');
    expect(plan.target!.feasible, isTrue);
    expect(plan.scenario(ScenarioPace.fast).meetsTarget, isFalse);
  });

  test('an impossible target says so and shows the date and extra income that would work', () {
    final plan = planFor(2000, target: '2026-04-25');
    expect(plan.target!.feasible, isFalse);
    expect(plan.target!.extraIncomeNeeded, Money.rupees(500));
    expect(plan.target!.earliestDate, d('2026-05-12'));
  });

  test('money already saved can finish the goal immediately', () {
    final plan = planFor(2000, saved: 1900);
    expect(plan.scenario(ScenarioPace.fast).days, 0);
    expect(plan.scenario(ScenarioPace.slow).days, isNotNull);
  });

  test('no flexible money means no daily saving and no completion date', () {
    final empty = PurchasePlanner.plan(
      request: PurchaseRequest(item: 'Bag', price: Money.rupees(500), today: d('2026-04-15')),
      capacity: SavingsCapacity(
        flexibleBalances: const {},
        daysLeftInCycle: 10,
        buffer: Money.zero,
        banked: Money.zero,
        typicalOutingCost: Money.rupees(400),
        typicalTreatCost: Money.rupees(150),
      ),
    );
    expect(empty.scenarios.every((scenario) => !scenario.isFeasible), isTrue);
  });

  test('typical cost is the median transaction or the fallback', () {
    final at = KolkataTime.at(d('2026-04-10'), 20);
    final history = [
      spend(300, BudgetCategory.outings, at),
      spend(500, BudgetCategory.outings, at),
      spend(900, BudgetCategory.outings, at),
      spend(80, BudgetCategory.food, at),
    ];
    expect(PurchasePlanner.typicalCost(history, BudgetCategory.outings, fallback: Money.rupees(400)), Money.rupees(500));
    expect(PurchasePlanner.typicalCost(history, BudgetCategory.trySomethingNew, fallback: Money.rupees(150)), Money.rupees(150));
  });

  test('target date must be in the future', () {
    expect(
      () => PurchaseRequest(item: 'x', price: Money.rupees(1), today: d('2026-04-15'), targetDate: d('2026-04-15')),
      throwsArgumentError,
    );
  });
}
