import 'category.dart';
import 'deposit.dart';
import 'largest_remainder.dart';
import 'money.dart';
import 'policy.dart';

abstract final class Generosity {
  static Money baseline({
    required Money currentInstallments,
    required List<Money> previousInstallmentTotals,
    required BudgetPolicy policy,
  }) {
    if (previousInstallmentTotals.isEmpty) {
      return currentInstallments;
    }
    final window = previousInstallmentTotals.length > policy.baselineCycles
        ? previousInstallmentTotals.sublist(previousInstallmentTotals.length - policy.baselineCycles)
        : previousInstallmentTotals;
    return median(window);
  }

  static Money median(List<Money> values) {
    if (values.isEmpty) {
      throw ArgumentError.value(values, 'values', 'must not be empty');
    }
    final sorted = [...values]..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[middle];
    }
    return (sorted[middle - 1] + sorted[middle]).floorDiv(2);
  }

  static Money delta({
    required Money currentInstallments,
    required List<Money> previousInstallmentTotals,
    required BudgetPolicy policy,
  }) =>
      currentInstallments -
      baseline(
        currentInstallments: currentInstallments,
        previousInstallmentTotals: previousInstallmentTotals,
        policy: policy,
      );

  static Map<BudgetCategory, Money> splitPositive(Money amount, BudgetPolicy policy) {
    if (amount.isNegative) {
      throw ArgumentError.value(amount, 'amount', 'must not be negative');
    }
    return LargestRemainder.split(amount, policy.generosityShares);
  }
}

abstract final class ExtraIncome {
  static Map<BudgetCategory, Money> split(Deposit deposit, BudgetPolicy policy) {
    if (!deposit.isExtra) {
      throw ArgumentError.value(deposit.kind, 'deposit', 'only extra income gets the generosity split');
    }
    return Generosity.splitPositive(deposit.amount, policy);
  }
}
