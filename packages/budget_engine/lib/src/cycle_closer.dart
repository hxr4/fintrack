import 'category.dart';
import 'money.dart';
import 'policy.dart';

final class CarryForward {
  const CarryForward({
    required this.openingBalances,
    required this.carryInToPool,
    required this.sweptToBuffer,
    required this.bufferOverflow,
  });

  final Map<BudgetCategory, Money> openingBalances;
  final Money carryInToPool;
  final Money sweptToBuffer;
  final Money bufferOverflow;

  Money get total => Money.sum(openingBalances.values) + carryInToPool;
}

abstract final class CycleCloser {
  static const _keptFunds = [
    BudgetCategory.bikeFund,
    BudgetCategory.recurringFund,
    BudgetCategory.goals,
  ];

  static const _sweptCategories = [
    BudgetCategory.food,
    BudgetCategory.petrol,
    BudgetCategory.outings,
    BudgetCategory.trySomethingNew,
    BudgetCategory.misc,
    BudgetCategory.unlogged,
  ];

  static CarryForward close({
    required Map<BudgetCategory, Money> closingBalances,
    required Money nightFoodTarget,
    required Money essentialsTarget,
    required Money bufferAllocation,
    BudgetPolicy policy = const BudgetPolicy(),
  }) {
    Money balanceOf(BudgetCategory category) => closingBalances[category] ?? Money.zero;
    final opening = BudgetCategory.filled(Money.zero);
    var toBuffer = Money.zero;

    void keepUpTo(BudgetCategory category, Money target) {
      final balance = balanceOf(category);
      final kept = balance.positivePart.atMost(target.positivePart);
      opening[category] = kept;
      toBuffer += balance - kept;
    }

    keepUpTo(BudgetCategory.nightFoodStock, nightFoodTarget);
    keepUpTo(BudgetCategory.essentialsStock, essentialsTarget);
    for (final category in _keptFunds) {
      final balance = balanceOf(category);
      opening[category] = balance.positivePart;
      toBuffer += balance - balance.positivePart;
    }
    for (final category in _sweptCategories) {
      toBuffer += balanceOf(category);
    }

    final candidate = balanceOf(BudgetCategory.buffer) + toBuffer;
    final cap = bufferAllocation.positivePart.times(policy.bufferCarryCycles);
    final bufferKept = candidate.positivePart.atMost(cap);
    opening[BudgetCategory.buffer] = bufferKept;

    return CarryForward(
      openingBalances: Map.unmodifiable(opening),
      carryInToPool: candidate - bufferKept,
      sweptToBuffer: toBuffer,
      bufferOverflow: (candidate - bufferKept).positivePart,
    );
  }
}
