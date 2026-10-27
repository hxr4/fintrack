import 'dart:math';

import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

Map<BudgetCategory, Money> balances(Map<BudgetCategory, int> paise) => {
      ...BudgetCategory.filled(Money.zero),
      for (final entry in paise.entries) entry.key: Money(entry.value),
    };

void main() {
  test('stock funds keep their balance up to target and spill the rest to Buffer', () {
    final carry = CycleCloser.close(
      closingBalances: balances({
        BudgetCategory.nightFoodStock: 90000,
        BudgetCategory.essentialsStock: 20000,
      }),
      nightFoodTarget: Money(75000),
      essentialsTarget: Money(50000),
      bufferAllocation: Money(112500),
    );
    expect(carry.openingBalances[BudgetCategory.nightFoodStock], Money(75000));
    expect(carry.openingBalances[BudgetCategory.essentialsStock], Money(20000));
    expect(carry.openingBalances[BudgetCategory.buffer], Money(15000));
  });

  test('Buffer carries up to two cycles of its allocation and the rest joins the pool', () {
    final carry = CycleCloser.close(
      closingBalances: balances({
        BudgetCategory.food: 30000,
        BudgetCategory.outings: 10000,
        BudgetCategory.buffer: 200000,
        BudgetCategory.goals: 50000,
      }),
      nightFoodTarget: Money(75000),
      essentialsTarget: Money.zero,
      bufferAllocation: Money(112500),
    );
    expect(carry.openingBalances[BudgetCategory.buffer], Money(225000));
    expect(carry.carryInToPool, Money(15000));
    expect(carry.openingBalances[BudgetCategory.goals], Money(50000));
    expect(carry.openingBalances[BudgetCategory.food], Money.zero);
  });

  test('overspending reduces Buffer first, then the next pool', () {
    final carry = CycleCloser.close(
      closingBalances: balances({BudgetCategory.food: -20000, BudgetCategory.buffer: 5000}),
      nightFoodTarget: Money(75000),
      essentialsTarget: Money.zero,
      bufferAllocation: Money(112500),
    );
    expect(carry.openingBalances[BudgetCategory.buffer], Money.zero);
    expect(carry.carryInToPool, Money(-15000));
  });

  test('a stock fund never exceeds its target after the next top-up', () {
    final settings = standardSettings();
    final carry = CycleCloser.close(
      closingBalances: balances({BudgetCategory.nightFoodStock: 30000}),
      nightFoodTarget: settings.nightFoodStockTarget,
      essentialsTarget: Money.zero,
      bufferAllocation: Money(112500),
    );
    final plan = AllocationPlanner.plan(PlanInput(
      window: windowFrom('2026-02-05'),
      cycleDeposits: [installment(12000, '2026-02-05')],
      settings: settings,
      reserves: ReserveInputs(nightFoodCarried: carry.openingBalances[BudgetCategory.nightFoodStock]!),
    ));
    expect(
      carry.openingBalances[BudgetCategory.nightFoodStock]! + plan.allocations[BudgetCategory.nightFoodStock]!,
      settings.nightFoodStockTarget,
    );
  });

  test('property: closing conserves money exactly and opening balances are never negative', () {
    final random = Random(11);
    for (var run = 0; run < 3000; run++) {
      final closing = {
        for (final category in BudgetCategory.values) category: Money(random.nextInt(400000) - 100000),
      };
      final carry = CycleCloser.close(
        closingBalances: closing,
        nightFoodTarget: Money(random.nextInt(100000)),
        essentialsTarget: Money(random.nextInt(100000)),
        bufferAllocation: Money(random.nextInt(200000)),
      );
      expect(carry.total, Money.sum(closing.values));
      expect(carry.openingBalances.values.every((amount) => !amount.isNegative), isTrue);
    }
  });
}
