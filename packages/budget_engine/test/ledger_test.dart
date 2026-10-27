import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  test('balance is opening plus allocation plus moves in minus moves out minus spend', () {
    final at = KolkataTime.at(d('2026-03-10'), 12);
    final adjustments = persist([
      AdjustmentDraft(
        from: BudgetCategory.buffer,
        to: BudgetCategory.food,
        amount: Money.rupees(100),
        reason: AdjustmentReason.manual,
        auto: false,
      ),
    ], 'b', at);
    final result = Ledger.balances(
      opening: {BudgetCategory.buffer: Money.rupees(500)},
      allocations: {BudgetCategory.food: Money.rupees(1000), BudgetCategory.buffer: Money.rupees(200)},
      transactions: [spend(40, BudgetCategory.food, at)],
      adjustments: adjustments,
    );
    expect(result[BudgetCategory.food], Money.rupees(1060));
    expect(result[BudgetCategory.buffer], Money.rupees(600));
    expect(Ledger.total(result), Money.rupees(1660));
  });

  test('undone adjustments are ignored', () {
    final at = KolkataTime.at(d('2026-03-10'), 12);
    final adjustments = AdjustmentBatches.undo(
      persist([
        AdjustmentDraft(
          from: BudgetCategory.buffer,
          to: BudgetCategory.food,
          amount: Money.rupees(100),
          reason: AdjustmentReason.manual,
          auto: false,
        ),
      ], 'b', at),
      'b',
    );
    final result = Ledger.balances(
      allocations: {BudgetCategory.buffer: Money.rupees(100)},
      adjustments: adjustments,
    );
    expect(result[BudgetCategory.buffer], Money.rupees(100));
    expect(result[BudgetCategory.food], Money.zero);
  });

  test('card is a payment method and corrections are restricted', () {
    final at = KolkataTime.at(d('2026-03-10'), 12);
    expect(spend(50, BudgetCategory.petrol, at, method: PaymentMethod.card).method, PaymentMethod.card);
    expect(() => spend(50, BudgetCategory.unlogged, at), throwsArgumentError);
    expect(
      () => Transaction(
        id: 'x',
        amount: Money.rupees(-5),
        category: BudgetCategory.food,
        method: PaymentMethod.cash,
        occurredAt: at,
        source: TransactionSource.manual,
      ),
      throwsArgumentError,
    );
    expect(
      () => Transaction(
        id: 'x',
        amount: Money.rupees(5),
        category: BudgetCategory.food,
        method: PaymentMethod.unrecorded,
        occurredAt: at,
        source: TransactionSource.manual,
      ),
      throwsArgumentError,
    );
  });
}
