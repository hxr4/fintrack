import 'dart:math';

import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

Map<BudgetCategory, Money> balances(Map<BudgetCategory, int> paise) => {
      ...BudgetCategory.filled(Money.zero),
      for (final entry in paise.entries) entry.key: Money(entry.value),
    };

AutoAdjustResult run(Map<BudgetCategory, Money> balances, {int daysLeft = 10, Money reserved = Money.zero}) =>
    AutoAdjuster.run(
      balances: balances,
      foodFloorPerDay: Money.rupees(150),
      petrolFloorForCycle: Money.rupees(1240),
      cycleLength: 31,
      daysLeft: daysLeft,
      essentialsReservedForDue: reserved,
    );

void main() {
  test('nothing moves while every essential is above zero, even if a projection looks bad', () {
    final result = run(balances({
      BudgetCategory.food: 100,
      BudgetCategory.petrol: 1,
      BudgetCategory.nightFoodStock: 1,
      BudgetCategory.buffer: 500000,
    }));
    expect(result.moved, isFalse);
  });

  test('Food at zero is refilled to floor times days left from donors in order', () {
    final result = run(balances({
      BudgetCategory.food: -5000,
      BudgetCategory.petrol: 1,
      BudgetCategory.nightFoodStock: 1,
      BudgetCategory.buffer: 100000,
      BudgetCategory.trySomethingNew: 30000,
      BudgetCategory.outings: 40000,
      BudgetCategory.misc: 99999,
      BudgetCategory.goals: 99999,
    }));
    expect(result.moves.map((move) => (move.from, move.amount)), [
      (BudgetCategory.buffer, Money(100000)),
      (BudgetCategory.trySomethingNew, Money(30000)),
      (BudgetCategory.outings, Money(25000)),
    ]);
    expect(result.moves.every((move) => move.to == BudgetCategory.food && move.auto), isTrue);
    final after = Ledger.applyDrafts(balances({
      BudgetCategory.food: -5000,
      BudgetCategory.petrol: 1,
      BudgetCategory.nightFoodStock: 1,
      BudgetCategory.buffer: 100000,
      BudgetCategory.trySomethingNew: 30000,
      BudgetCategory.outings: 40000,
    }), result.moves);
    expect(after[BudgetCategory.food], Money.rupees(1500));
    expect(result.shortfall, isFalse);
  });

  test('Petrol refills to its prorated remaining floor', () {
    expect(
      AutoAdjuster.refillTarget(
        category: BudgetCategory.petrol,
        foodFloorPerDay: Money.rupees(150),
        petrolFloorForCycle: Money.rupees(1240),
        cycleLength: 31,
        daysLeft: 10,
      ),
      Money.rupees(400),
    );
  });

  test('Night food stock is only brought back to zero', () {
    final result = run(balances({
      BudgetCategory.nightFoodStock: -3000,
      BudgetCategory.food: 1,
      BudgetCategory.petrol: 1,
      BudgetCategory.buffer: 100000,
    }));
    expect(result.totalMoved, Money(3000));
  });

  test('Essentials stock gives only what is not reserved for items due this cycle', () {
    final result = run(
      balances({BudgetCategory.food: 0, BudgetCategory.essentialsStock: 200000}),
      reserved: Money(120000),
    );
    expect(result.totalMoved, Money(80000));
    expect(result.uncovered[BudgetCategory.food], Money(70000));
    expect(result.shortfall, isTrue);
  });

  test('donors that are already negative give nothing', () {
    final result = run(balances({
      BudgetCategory.food: 0,
      BudgetCategory.petrol: 1,
      BudgetCategory.nightFoodStock: 1,
      BudgetCategory.buffer: -5000,
      BudgetCategory.outings: 200000,
    }));
    expect(result.moves.single.from, BudgetCategory.outings);
  });

  test('undo restores the exact state before the batch', () {
    final at = KolkataTime.at(d('2026-03-20'), 21);
    final allocations = {
      BudgetCategory.food: Money.rupees(4000),
      BudgetCategory.buffer: Money.rupees(1200),
      BudgetCategory.outings: Money.rupees(900),
      BudgetCategory.trySomethingNew: Money.rupees(400),
    };
    final transactions = [spend(4100, BudgetCategory.food, at)];
    final before = Ledger.balances(allocations: allocations, transactions: transactions);
    final result = run(before);
    expect(result.moved, isTrue);
    final adjustments = persist(result.moves, 'batch-1', at);
    final during = Ledger.balances(allocations: allocations, transactions: transactions, adjustments: adjustments);
    expect(during, isNot(before));
    final undone = AdjustmentBatches.undo(adjustments, 'batch-1');
    final after = Ledger.balances(allocations: allocations, transactions: transactions, adjustments: undone);
    expect(after, before);
    expect(undone.every((adjustment) => adjustment.undone), isTrue);
  });

  test('undo of one batch leaves other batches intact', () {
    final at = KolkataTime.at(d('2026-03-20'), 21);
    final first = persist([
      AdjustmentDraft(from: BudgetCategory.buffer, to: BudgetCategory.food, amount: Money(100), reason: AdjustmentReason.autoRefill, auto: true),
    ], 'one', at);
    final second = persist([
      AdjustmentDraft(from: BudgetCategory.outings, to: BudgetCategory.petrol, amount: Money(200), reason: AdjustmentReason.autoRefill, auto: true),
    ], 'two', at);
    final undone = AdjustmentBatches.undo([...first, ...second], 'one');
    final result = Ledger.balances(adjustments: undone);
    expect(result[BudgetCategory.food], Money.zero);
    expect(result[BudgetCategory.petrol], Money(200));
  });

  test('property: donors never go negative, floors and reserves are never donors, money is conserved', () {
    final random = Random(99);
    for (var iteration = 0; iteration < 3000; iteration++) {
      final start = {
        for (final category in BudgetCategory.values) category: Money(random.nextInt(300000) - 60000),
      };
      final reserved = Money(random.nextInt(100000));
      final result = run(start, daysLeft: 1 + random.nextInt(31), reserved: reserved);
      final after = Ledger.applyDrafts(start, result.moves);
      expect(Ledger.total(after), Ledger.total(start));
      for (final move in result.moves) {
        expect(
          [BudgetCategory.buffer, BudgetCategory.trySomethingNew, BudgetCategory.outings, BudgetCategory.essentialsStock],
          contains(move.from),
        );
        expect(BudgetCategory.essentials, contains(move.to));
      }
      for (final category in [BudgetCategory.buffer, BudgetCategory.trySomethingNew, BudgetCategory.outings]) {
        if (!start[category]!.isNegative) {
          expect(after[category]!.isNegative, isFalse);
        }
      }
      if (result.moves.any((move) => move.from == BudgetCategory.essentialsStock)) {
        expect(after[BudgetCategory.essentialsStock]! >= reserved, isTrue);
      }
      for (final category in [BudgetCategory.misc, BudgetCategory.goals, BudgetCategory.bikeFund, BudgetCategory.recurringFund]) {
        expect(after[category], start[category]);
      }
    }
  });
}
