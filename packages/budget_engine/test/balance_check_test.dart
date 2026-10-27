import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

Map<BudgetCategory, Money> balances(Map<BudgetCategory, int> paise) => {
      ...BudgetCategory.filled(Money.zero),
      for (final entry in paise.entries) entry.key: Money(entry.value),
    };

void main() {
  final anchorAt = KolkataTime.at(d('2026-03-05'), 9);
  final checkAt = KolkataTime.at(d('2026-03-15'), 20);
  final anchor = BalanceAnchor(at: anchorAt, total: Money(1000000));
  final transactions = [
    spend(400, BudgetCategory.food, KolkataTime.at(d('2026-03-06'), 13)),
    spend(350, BudgetCategory.petrol, KolkataTime.at(d('2026-03-08'), 18)),
    spend(250, BudgetCategory.outings, KolkataTime.at(d('2026-03-12'), 21)),
    spend(999, BudgetCategory.food, KolkataTime.at(d('2026-03-04'), 13)),
  ];

  BalanceComparison compareWith(int bank, int cash, {int excluded = 0}) => BalanceCheck.compare(
        anchor: anchor,
        deposits: const [],
        transactions: transactions,
        reported: ReportedBalance(at: checkAt, bank: Money(bank), cash: Money(cash), excluded: Money(excluded)),
      );

  BalanceCorrection resolve(BalanceComparison comparison, BalanceResolution resolution, Map<BudgetCategory, Money> current) =>
      BalanceCheck.resolve(
        comparison: comparison,
        resolution: resolution,
        balances: current,
        cycleSpendByCategory: {BudgetCategory.food: Money(60000), BudgetCategory.petrol: Money(40000)},
        cycleAllocations: const {},
        foodFloorPerDay: Money.rupees(150),
        petrolFloorRemaining: Money.rupees(800),
        daysLeft: 21,
      );

  test('expected balance counts only activity since the last check', () {
    final comparison = compareWith(800000, 50000);
    expect(comparison.expected, Money(900000));
    expect(comparison.actual, Money(850000));
    expect(comparison.difference, Money(-50000));
  });

  test('bank and cash are compared as one total, minus money outside the budget', () {
    expect(compareWith(1300000, 0, excluded: 450000).difference, Money(-50000));
    expect(compareWith(0, 900000).matches, isTrue);
  });

  test('unlogged shortfall is logged and covered from flexible money first', () {
    final current = balances({
      BudgetCategory.trySomethingNew: 20000,
      BudgetCategory.outings: 20000,
      BudgetCategory.misc: 5000,
      BudgetCategory.buffer: 100000,
      BudgetCategory.food: 600000,
    });
    final correction = resolve(compareWith(800000, 50000), BalanceResolution.unlogged, current);
    expect(correction.transactions.single.category, BudgetCategory.unlogged);
    expect(correction.transactions.single.amount, Money(50000));
    expect(correction.transactions.single.method, PaymentMethod.unrecorded);
    expect(correction.adjustments.map((move) => (move.from, move.amount)), [
      (BudgetCategory.trySomethingNew, Money(20000)),
      (BudgetCategory.outings, Money(20000)),
      (BudgetCategory.misc, Money(5000)),
      (BudgetCategory.buffer, Money(5000)),
    ]);
    final after = Ledger.applyDrafts(
      {...current, BudgetCategory.unlogged: current[BudgetCategory.unlogged]! - Money(50000)},
      correction.adjustments,
    );
    expect(after[BudgetCategory.unlogged], Money.zero);
    expect(after[BudgetCategory.food], Money(600000));
    expect(correction.newAnchor!.total, Money(850000));
    expect(correction.uncovered, Money.zero);
  });

  test('held money is skipped when covering unlogged spending', () {
    final correction = BalanceCheck.resolve(
      comparison: compareWith(800000, 50000),
      resolution: BalanceResolution.unlogged,
      balances: balances({BudgetCategory.trySomethingNew: 20000, BudgetCategory.buffer: 100000}),
      cycleSpendByCategory: const {},
      cycleAllocations: const {},
      foodFloorPerDay: Money.rupees(150),
      petrolFloorRemaining: Money.zero,
      daysLeft: 21,
      held: {BudgetCategory.trySomethingNew: Money(20000)},
    );
    expect(correction.adjustments.single.from, BudgetCategory.buffer);
  });

  test('after resolving, the next check from the new anchor matches', () {
    final correction = resolve(compareWith(800000, 50000), BalanceResolution.unlogged, balances({BudgetCategory.buffer: 900000}));
    final next = BalanceCheck.compare(
      anchor: correction.newAnchor!,
      deposits: const [],
      transactions: transactions,
      reported: ReportedBalance(at: checkAt.add(const Duration(minutes: 1)), bank: Money(800000), cash: Money(50000)),
    );
    expect(next.matches, isTrue);
  });

  test('covering unlogged spending never takes Food below its floor', () {
    final correction = resolve(
      compareWith(0, 0),
      BalanceResolution.unlogged,
      balances({BudgetCategory.food: 400000, BudgetCategory.petrol: 100000}),
    );
    final foodTaken = Money.sum(correction.adjustments
        .where((move) => move.from == BudgetCategory.food)
        .map((move) => move.amount));
    expect(Money(400000) - foodTaken, Money.rupees(150).times(21));
    expect(correction.uncovered.isPositive, isTrue);
  });

  test('a surplus goes to Buffer through a correction credit', () {
    final correction = resolve(compareWith(900000, 50000), BalanceResolution.unlogged, balances({}));
    expect(correction.transactions.single.amount, Money(-50000));
    expect(correction.adjustments.single.to, BudgetCategory.buffer);
    expect(correction.adjustments.single.amount, Money(50000));
  });

  test('distribute splits the difference by this cycle\'s spending shares', () {
    final correction = resolve(compareWith(800000, 50000), BalanceResolution.distribute, balances({}));
    expect(
      {for (final transaction in correction.transactions) transaction.category: transaction.amount},
      {BudgetCategory.food: Money(30000), BudgetCategory.petrol: Money(20000)},
    );
    expect(correction.adjustments, isEmpty);
  });

  test('ignore changes nothing and keeps the old anchor', () {
    final correction = resolve(compareWith(800000, 50000), BalanceResolution.ignore, balances({}));
    expect(correction.transactions, isEmpty);
    expect(correction.adjustments, isEmpty);
    expect(correction.newAnchor, isNull);
  });
}
