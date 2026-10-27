import 'dart:math';

import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

Map<BudgetCategory, Money> balances(Map<BudgetCategory, int> paise) => {
      ...BudgetCategory.filled(Money.zero),
      BudgetCategory.petrol: const Money(1),
      BudgetCategory.nightFoodStock: const Money(1),
      for (final entry in paise.entries) entry.key: Money(entry.value),
    };

AutoAdjustResult run(
  Map<BudgetCategory, Money> balances, {
  int daysLeft = 10,
  int dayOfCycle = 20,
  Money reserved = Money.zero,
  Iterable<Hold> holds = const [],
}) =>
    AutoAdjuster.run(
      balances: balances,
      foodFloorPerDay: Money.rupees(150),
      petrolFloorForCycle: Money.rupees(1240),
      cycleLength: 31,
      daysLeft: daysLeft,
      dayOfCycle: dayOfCycle,
      essentialsReservedForDue: reserved,
      holds: holds,
    );

void main() {
  final at = KolkataTime.at(d('2026-03-20'), 21);

  test('nothing moves while every essential is above zero, even if a projection looks bad', () {
    final result = run(balances({BudgetCategory.food: 100, BudgetCategory.buffer: 500000}));
    expect(result.moved, isFalse);
    expect(result.suggestReplan, isFalse);
  });

  test('Food at zero gets one week moved and the rest of the commitment held', () {
    final result = run(balances({
      BudgetCategory.food: -5000,
      BudgetCategory.buffer: 100000,
      BudgetCategory.trySomethingNew: 30000,
      BudgetCategory.outings: 40000,
      BudgetCategory.misc: 99999,
      BudgetCategory.goals: 99999,
    }));
    expect(result.moves.map((move) => (move.from, move.amount)), [
      (BudgetCategory.buffer, Money(100000)),
      (BudgetCategory.trySomethingNew, Money(10000)),
    ]);
    expect(result.newHolds.map((hold) => (hold.category, hold.amount)), [
      (BudgetCategory.trySomethingNew, Money(20000)),
      (BudgetCategory.outings, Money(25000)),
    ]);
    expect(result.totalMoved, Money.rupees(1100));
    expect(result.totalHeld, Money.rupees(450));
    expect(result.shortfall, isFalse);
    final after = Ledger.applyDrafts(
      balances({BudgetCategory.food: -5000, BudgetCategory.buffer: 100000, BudgetCategory.trySomethingNew: 30000, BudgetCategory.outings: 40000}),
      result.moves,
    );
    expect(after[BudgetCategory.food], Money.rupees(1050));
    expect(after[BudgetCategory.outings], Money(40000));
  });

  test('fewer than seven days left moves everything and holds nothing', () {
    final result = run(balances({BudgetCategory.food: 0, BudgetCategory.buffer: 200000}), daysLeft: 4);
    expect(result.totalMoved, Money.rupees(600));
    expect(result.newHolds, isEmpty);
  });

  test('a hold the donors cannot cover shows the shortfall immediately', () {
    final result = run(balances({BudgetCategory.food: 0, BudgetCategory.buffer: 120000}), daysLeft: 20);
    expect(result.totalMoved, Money.rupees(1050));
    expect(result.totalHeld, Money.rupees(150));
    expect(result.holdShortfall, Money.rupees(1800));
    expect(result.shortfall, isTrue);
  });

  test('Food reaching zero before day 10 suggests a replan', () {
    expect(run(balances({BudgetCategory.food: 0, BudgetCategory.buffer: 900000}), dayOfCycle: 6).suggestReplan, isTrue);
    expect(run(balances({BudgetCategory.food: 0, BudgetCategory.buffer: 900000}), dayOfCycle: 10).suggestReplan, isFalse);
    expect(
      run(balances({BudgetCategory.petrol: 0, BudgetCategory.food: 1, BudgetCategory.buffer: 900000}), dayOfCycle: 3).suggestReplan,
      isFalse,
    );
  });

  test('held money is not spendable by later refills', () {
    final event = persistEvent(
      batchId: 'e1',
      at: at,
      newHolds: [HoldDraft(category: BudgetCategory.buffer, amount: Money(80000))],
    );
    final result = run(
      balances({BudgetCategory.petrol: 0, BudgetCategory.food: 1, BudgetCategory.buffer: 100000, BudgetCategory.outings: 50000}),
      holds: event.holds,
    );
    expect(result.moves.map((move) => (move.from, move.amount)), [
      (BudgetCategory.buffer, Money(20000)),
      (BudgetCategory.outings, Money(20000)),
    ]);
  });

  test('Food at zero again releases from the existing hold before taking new money', () {
    final first = persistEvent(
      batchId: 'e1',
      at: at,
      newHolds: [HoldDraft(category: BudgetCategory.outings, amount: Money(50000))],
    );
    final result = run(
      balances({BudgetCategory.food: 0, BudgetCategory.outings: 60000, BudgetCategory.buffer: 200000}),
      daysLeft: 9,
      holds: first.holds,
    );
    expect(result.releases.single.commitmentId, 'e1');
    expect(result.releases.single.moved, Money(50000));
    expect(result.moves.single.from, BudgetCategory.buffer);
    expect(result.moves.single.amount, Money(55000));
    expect(result.totalMoved, Money.rupees(1050));
    expect(result.totalHeld, Money.rupees(300));
  });

  test('weekly rollover releases up to seven days of the hold', () {
    final placed = persistEvent(
      batchId: 'e1',
      at: KolkataTime.at(d('2026-03-08'), 20),
      newHolds: [
        HoldDraft(category: BudgetCategory.buffer, amount: Money(60000)),
        HoldDraft(category: BudgetCategory.outings, amount: Money(150000)),
      ],
    );
    final current = balances({BudgetCategory.food: 50000, BudgetCategory.buffer: 60000, BudgetCategory.outings: 150000});
    List<HoldRelease> dueOn(String date) => WeeklyHoldRelease.due(
          holds: placed.holds,
          balances: current,
          today: d(date),
          boundaryHour: 4,
          foodFloorPerDay: Money.rupees(150),
        );
    expect(dueOn('2026-03-14'), isEmpty);
    final release = dueOn('2026-03-15').single;
    expect(release.moves.map((move) => (move.from, move.amount)), [
      (BudgetCategory.buffer, Money(60000)),
      (BudgetCategory.outings, Money(45000)),
    ]);
    expect(release.released, Money.rupees(1050));
  });

  test('undo reverses the move and its hold together and restores the exact state', () {
    final allocations = {
      BudgetCategory.food: Money.rupees(4000),
      BudgetCategory.petrol: Money.rupees(1000),
      BudgetCategory.nightFoodStock: Money.rupees(750),
      BudgetCategory.buffer: Money.rupees(1200),
      BudgetCategory.outings: Money.rupees(900),
      BudgetCategory.trySomethingNew: Money.rupees(400),
    };
    final transactions = [spend(4100, BudgetCategory.food, at)];
    final before = Ledger.balances(allocations: allocations, transactions: transactions);
    final result = run(before);
    expect(result.moved, isTrue);
    expect(result.newHolds, isNotEmpty);
    final event = persistResult(result, 'batch-1', at);
    final during = Ledger.balances(allocations: allocations, transactions: transactions, adjustments: event.adjustments);
    expect(during, isNot(before));
    expect(Holds.totalHeld(event.holds).isPositive, isTrue);

    final undone = BatchUndo.undo(adjustments: event.adjustments, holds: event.holds, batchId: 'batch-1');
    expect(Ledger.balances(allocations: allocations, transactions: transactions, adjustments: undone.adjustments), before);
    expect(Holds.totalHeld(undone.holds), Money.zero);
  });

  test('undoing a refill also undoes later releases from its hold', () {
    final base = balances({BudgetCategory.food: 0, BudgetCategory.buffer: 400000});
    final refill = persistResult(run(base, daysLeft: 20), 'refill', KolkataTime.at(d('2026-03-08'), 20));
    final afterRefill = Ledger.balances(opening: base, adjustments: refill.adjustments);
    final releases = WeeklyHoldRelease.due(
      holds: refill.holds,
      balances: afterRefill,
      today: d('2026-03-15'),
      boundaryHour: 4,
      foodFloorPerDay: Money.rupees(150),
    );
    final weekly = persistEvent(batchId: 'week-2', at: KolkataTime.at(d('2026-03-15'), 9), releases: releases);
    final adjustments = [...refill.adjustments, ...weekly.adjustments];
    final holds = [...refill.holds, ...weekly.holds];
    expect(Holds.totalHeld(holds), Money.rupees(150 * 6));

    final releaseOnly = BatchUndo.undo(adjustments: adjustments, holds: holds, batchId: 'week-2');
    expect(releaseOnly.undoneBatches, {'week-2'});
    expect(Ledger.balances(opening: base, adjustments: releaseOnly.adjustments), afterRefill);
    expect(Holds.totalHeld(releaseOnly.holds), Money.rupees(150 * 13));

    final everything = BatchUndo.undo(adjustments: adjustments, holds: holds, batchId: 'refill');
    expect(everything.undoneBatches, {'refill', 'week-2'});
    expect(Ledger.balances(opening: base, adjustments: everything.adjustments), base);
    expect(Holds.totalHeld(everything.holds), Money.zero);
  });

  test('Petrol refills to its prorated remaining floor and Night food stock to zero', () {
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
    final result = run(balances({BudgetCategory.nightFoodStock: -3000, BudgetCategory.food: 1, BudgetCategory.buffer: 100000}));
    expect(result.totalMoved, Money(3000));
    expect(result.newHolds, isEmpty);
  });

  test('Essentials stock gives only what is not reserved for items due this cycle', () {
    final result = run(
      balances({BudgetCategory.food: 0, BudgetCategory.essentialsStock: 200000}),
      reserved: Money(120000),
    );
    expect(result.totalMoved, Money(80000));
    expect(result.uncovered[BudgetCategory.food], Money(25000));
    expect(result.holdShortfall, Money.rupees(450));
  });

  test('property: donors never go negative, holds stay within donors, money is conserved', () {
    final random = Random(99);
    for (var iteration = 0; iteration < 3000; iteration++) {
      final start = {
        for (final category in BudgetCategory.values) category: Money(random.nextInt(300000) - 60000),
      };
      final reserved = Money(random.nextInt(100000));
      final daysLeft = 1 + random.nextInt(31);
      final result = run(start, daysLeft: daysLeft, reserved: reserved, dayOfCycle: 1 + random.nextInt(31));
      final after = Ledger.applyDrafts(start, result.allMoves);
      expect(Ledger.total(after), Ledger.total(start));
      final held = Holds.heldByCategory(persistResult(result, 'p$iteration', at).holds);
      for (final move in result.moves) {
        expect(Holds.donorOrder, contains(move.from));
        expect(BudgetCategory.essentials, contains(move.to));
      }
      for (final hold in result.newHolds) {
        expect(Holds.donorOrder, contains(hold.category));
        expect(hold.amount.isPositive, isTrue);
      }
      for (final category in [BudgetCategory.buffer, BudgetCategory.trySomethingNew, BudgetCategory.outings]) {
        if (!start[category]!.isNegative) {
          expect((after[category]! - held[category]!).isNegative, isFalse);
        }
      }
      if (result.moves.any((move) => move.from == BudgetCategory.essentialsStock) ||
          result.newHolds.any((hold) => hold.category == BudgetCategory.essentialsStock)) {
        expect(after[BudgetCategory.essentialsStock]! - held[BudgetCategory.essentialsStock]! >= reserved, isTrue);
      }
      expect(
        result.totalHeld + result.holdShortfall,
        start[BudgetCategory.food]!.isPositive
            ? Money.zero
            : AutoAdjuster.foodHoldTarget(foodFloorPerDay: Money.rupees(150), daysLeft: daysLeft),
      );
      for (final category in [BudgetCategory.misc, BudgetCategory.goals, BudgetCategory.bikeFund, BudgetCategory.recurringFund]) {
        expect(after[category], start[category]);
      }
    }
  });
}
