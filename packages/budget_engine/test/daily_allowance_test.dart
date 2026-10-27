import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  test('allowance is the pool divided by days left including today', () {
    final allowance = DailyAllowanceCalculator.compute(
      poolAtStartOfDay: Money.rupees(6000),
      spentToday: Money.rupees(50),
      daysLeft: 30,
      baseDaily: Money.rupees(200),
    );
    expect(allowance.allowance, Money.rupees(200));
    expect(allowance.ringAmount, Money.rupees(200));
    expect(allowance.remainingToday, Money.rupees(150));
    expect(allowance.banked, Money.zero);
  });

  test('unspent money carries forward because the pool is recomputed daily', () {
    final dayOne = DailyAllowanceCalculator.compute(
      poolAtStartOfDay: Money.rupees(6200),
      spentToday: Money.rupees(100),
      daysLeft: 31,
      baseDaily: Money.rupees(200),
    );
    final dayTwo = DailyAllowanceCalculator.compute(
      poolAtStartOfDay: dayOne.poolAtStartOfDay - dayOne.spentToday,
      spentToday: Money.zero,
      daysLeft: 30,
      baseDaily: Money.rupees(200),
    );
    expect(dayTwo.allowance, Money(20333));
  });

  test('allowance above 1.5x base shows base in the ring and banks the excess', () {
    final allowance = DailyAllowanceCalculator.compute(
      poolAtStartOfDay: Money.rupees(10000),
      spentToday: Money.zero,
      daysLeft: 30,
      baseDaily: Money.rupees(200),
    );
    expect(allowance.allowance, Money(33333));
    expect(allowance.ringAmount, Money.rupees(200));
    expect(allowance.banked, Money.rupees(4000));
    expect(allowance.isSoftCapped, isTrue);
  });

  test('exactly 1.5x base is not capped', () {
    final allowance = DailyAllowanceCalculator.compute(
      poolAtStartOfDay: Money.rupees(9000),
      spentToday: Money.zero,
      daysLeft: 30,
      baseDaily: Money.rupees(200),
    );
    expect(allowance.isSoftCapped, isFalse);
    expect(allowance.ringAmount, Money.rupees(300));
  });

  test('an overspent pool gives zero, never a negative allowance', () {
    final allowance = DailyAllowanceCalculator.compute(
      poolAtStartOfDay: Money.rupees(-100),
      spentToday: Money.zero,
      daysLeft: 3,
      baseDaily: Money.rupees(200),
    );
    expect(allowance.allowance, Money.zero);
  });

  test('awaiting deposit spreads leftover money over the planned days', () {
    final days = CycleCalendar.awaitingPlanDays(expectedStart: d('2026-03-05'), today: d('2026-03-06'), policy: policy);
    final allowance = DailyAllowanceCalculator.compute(
      poolAtStartOfDay: Money.rupees(900),
      spentToday: Money.zero,
      daysLeft: days,
      baseDaily: Money.rupees(200),
    );
    expect(days, 3);
    expect(allowance.allowance, Money.rupees(300));
  });

  test('pool at start of day adds back today\'s pool spending', () {
    expect(
      DailyAllowanceCalculator.poolAtStartOfDay(
        balancesNow: {
          BudgetCategory.food: Money.rupees(500),
          BudgetCategory.outings: Money.rupees(100),
          BudgetCategory.petrol: Money.rupees(999),
        },
        spentTodayByCategory: {BudgetCategory.food: Money.rupees(40), BudgetCategory.petrol: Money.rupees(100)},
      ),
      Money.rupees(640),
    );
  });

  group('moving banked money', () {
    final balances = {
      ...BudgetCategory.filled(Money.zero),
      BudgetCategory.trySomethingNew: Money.rupees(100),
      BudgetCategory.outings: Money.rupees(500),
      BudgetCategory.food: Money.rupees(7000),
    };

    test('takes from Try something new, then Outings, then Food above its floor', () {
      final moves = BankedMover.move(
        amount: Money.rupees(1000),
        to: BudgetCategory.buffer,
        banked: Money.rupees(4000),
        balances: balances,
        foodFloorPerDay: Money.rupees(150),
        daysLeft: 10,
      );
      expect(moves.map((move) => (move.from, move.amount)), [
        (BudgetCategory.trySomethingNew, Money.rupees(100)),
        (BudgetCategory.outings, Money.rupees(500)),
        (BudgetCategory.food, Money.rupees(400)),
      ]);
      final after = Ledger.applyDrafts(balances, moves);
      expect(after[BudgetCategory.food]! >= Money.rupees(1500), isTrue);
    });

    test('cannot move more than is banked or to a spendable category', () {
      expect(
        () => BankedMover.move(
          amount: Money.rupees(5000),
          to: BudgetCategory.buffer,
          banked: Money.rupees(4000),
          balances: balances,
          foodFloorPerDay: Money.rupees(150),
          daysLeft: 10,
        ),
        throwsArgumentError,
      );
      expect(
        () => BankedMover.move(
          amount: Money.rupees(5),
          to: BudgetCategory.outings,
          banked: Money.rupees(4000),
          balances: balances,
          foodFloorPerDay: Money.rupees(150),
          daysLeft: 10,
        ),
        throwsArgumentError,
      );
    });
  });
}
