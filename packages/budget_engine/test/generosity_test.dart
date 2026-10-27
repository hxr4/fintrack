import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  test('first cycle has no delta', () {
    expect(
      Generosity.delta(currentInstallments: Money.rupees(11000), previousInstallmentTotals: [], policy: policy),
      Money.zero,
    );
  });

  test('11,000 then 12,000 then 13,000 gives +1,000 then +1,500', () {
    expect(
      Generosity.delta(
        currentInstallments: Money.rupees(12000),
        previousInstallmentTotals: [Money.rupees(11000)],
        policy: policy,
      ),
      Money.rupees(1000),
    );
    expect(
      Generosity.delta(
        currentInstallments: Money.rupees(13000),
        previousInstallmentTotals: [Money.rupees(11000), Money.rupees(12000)],
        policy: policy,
      ),
      Money.rupees(1500),
    );
  });

  test('baseline uses only the last three cycles', () {
    expect(
      Generosity.baseline(
        currentInstallments: Money.rupees(12000),
        previousInstallmentTotals: [
          Money.rupees(20000),
          Money.rupees(11000),
          Money.rupees(13000),
          Money.rupees(12000),
        ],
        policy: policy,
      ),
      Money.rupees(12000),
    );
  });

  test('even-length median rounds down to whole paise', () {
    expect(Generosity.median([const Money(101), const Money(100)]), const Money(100));
  });

  test('positive split follows the brief shares exactly', () {
    final split = Generosity.splitPositive(Money.rupees(1000), policy);
    expect(split[BudgetCategory.food], Money.rupees(500));
    expect(split[BudgetCategory.outings], Money.rupees(200));
    expect(split[BudgetCategory.trySomethingNew], Money.rupees(100));
    expect(split[BudgetCategory.buffer], Money.rupees(100));
    expect(split[BudgetCategory.goals], Money.rupees(100));
  });

  group('deposits as a list', () {
    test('an installment can never get the extra income split', () {
      expect(() => ExtraIncome.split(installment(500, '2026-03-10'), policy), throwsArgumentError);
    });

    test('extra income splits by the positive delta rule and sums exactly', () {
      final split = ExtraIncome.split(extra(777, '2026-03-10'), policy);
      expect(Money.sum(split.values), Money.rupees(777));
    });

    test('installment totals sum several transfers in one cycle', () {
      final deposits = [
        installment(3000, '2026-03-05', id: 'w1'),
        installment(3000, '2026-03-12', id: 'w2'),
        extra(500, '2026-03-13'),
        installment(3000, '2026-03-19', id: 'w3'),
      ];
      expect(deposits.installmentTotal, Money.rupees(9000));
      expect(deposits.extraTotal, Money.rupees(500));
    });

    test('extras never change the baseline or the delta', () {
      final settings = standardSettings();
      PlanInput input(List<Deposit> deposits) => PlanInput(
            window: windowFrom('2026-03-05'),
            cycleDeposits: deposits,
            settings: settings,
            previousInstallmentTotals: [Money.rupees(12000)],
          );
      final without = AllocationPlanner.plan(input([installment(12000, '2026-03-05')]));
      final withExtra = AllocationPlanner.plan(input([installment(12000, '2026-03-05'), extra(2000, '2026-03-06')]));
      expect(withExtra.delta, without.delta);
      expect(withExtra.baseline, without.baseline);
      expect(withExtra.allocations, without.allocations);
    });

    test('a deposit must be positive', () {
      expect(
        () => Deposit(id: 'x', amount: Money.zero, receivedAt: DateTime.utc(2026), kind: DepositKind.extra),
        throwsArgumentError,
      );
    });
  });
}
