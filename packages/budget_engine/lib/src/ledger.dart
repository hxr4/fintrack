import 'adjustment.dart';
import 'category.dart';
import 'money.dart';
import 'transaction.dart';

abstract final class Ledger {
  static Map<BudgetCategory, Money> balances({
    Map<BudgetCategory, Money> opening = const {},
    Map<BudgetCategory, Money> allocations = const {},
    Iterable<Transaction> transactions = const [],
    Iterable<Adjustment> adjustments = const [],
  }) {
    final result = BudgetCategory.filled(Money.zero);
    void add(BudgetCategory category, Money amount) {
      result[category] = result[category]! + amount;
    }

    opening.forEach(add);
    allocations.forEach(add);
    for (final transaction in transactions) {
      add(transaction.category, -transaction.amount);
    }
    for (final adjustment in adjustments.where((adjustment) => !adjustment.undone)) {
      add(adjustment.from, -adjustment.amount);
      add(adjustment.to, adjustment.amount);
    }
    return result;
  }

  static Map<BudgetCategory, Money> applyDrafts(
    Map<BudgetCategory, Money> balances,
    Iterable<AdjustmentDraft> drafts,
  ) {
    final result = Map<BudgetCategory, Money>.of(balances);
    for (final draft in drafts) {
      result[draft.from] = (result[draft.from] ?? Money.zero) - draft.amount;
      result[draft.to] = (result[draft.to] ?? Money.zero) + draft.amount;
    }
    return result;
  }

  static Money total(Map<BudgetCategory, Money> balances) => Money.sum(balances.values);

  static Money pool(
    Map<BudgetCategory, Money> balances, {
    Map<BudgetCategory, Money> held = const {},
  }) =>
      Money.sum(BudgetCategory.spendablePool.map(
        (category) => (balances[category] ?? Money.zero) - (held[category] ?? Money.zero),
      ));
}
