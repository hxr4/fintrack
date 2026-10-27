import 'adjustment.dart';
import 'category.dart';
import 'donors.dart';
import 'money.dart';
import 'policy.dart';

final class DailyAllowance {
  const DailyAllowance({
    required this.poolAtStartOfDay,
    required this.daysLeft,
    required this.allowance,
    required this.ringAmount,
    required this.banked,
    required this.spentToday,
  });

  final Money poolAtStartOfDay;
  final int daysLeft;
  final Money allowance;
  final Money ringAmount;
  final Money banked;
  final Money spentToday;

  Money get remainingToday => ringAmount - spentToday;
  bool get isSoftCapped => banked.isPositive;
  bool get isOverToday => spentToday > ringAmount;
}

abstract final class DailyAllowanceCalculator {
  static Money poolAtStartOfDay({
    required Map<BudgetCategory, Money> balancesNow,
    required Map<BudgetCategory, Money> spentTodayByCategory,
  }) =>
      Money.sum(BudgetCategory.spendablePool.map((category) =>
          (balancesNow[category] ?? Money.zero) + (spentTodayByCategory[category] ?? Money.zero)));

  static Money baseDaily({required Money poolAtCycleStart, required int cycleLength}) =>
      poolAtCycleStart.positivePart.floorDiv(cycleLength);

  static DailyAllowance compute({
    required Money poolAtStartOfDay,
    required Money spentToday,
    required int daysLeft,
    required Money baseDaily,
    BudgetPolicy policy = const BudgetPolicy(),
  }) {
    if (daysLeft < 1) {
      throw ArgumentError.value(daysLeft, 'daysLeft', 'must be at least 1');
    }
    final allowance = poolAtStartOfDay.positivePart.floorDiv(daysLeft);
    final softCapExceeded = allowance.times(policy.softCapDenominator) >
        baseDaily.times(policy.softCapNumerator);
    final ring = softCapExceeded ? baseDaily : allowance;
    final banked = softCapExceeded
        ? (poolAtStartOfDay - baseDaily.times(daysLeft)).positivePart
        : Money.zero;
    return DailyAllowance(
      poolAtStartOfDay: poolAtStartOfDay,
      daysLeft: daysLeft,
      allowance: allowance,
      ringAmount: ring,
      banked: banked,
      spentToday: spentToday,
    );
  }
}

abstract final class BankedMover {
  static List<AdjustmentDraft> move({
    required Money amount,
    required BudgetCategory to,
    required Money banked,
    required Map<BudgetCategory, Money> balances,
    required Money foodFloorPerDay,
    required int daysLeft,
  }) {
    if (to != BudgetCategory.buffer && to != BudgetCategory.goals) {
      throw ArgumentError.value(to, 'to', 'banked money moves to Buffer or Goals');
    }
    if (!amount.isPositive || amount > banked) {
      throw ArgumentError.value(amount, 'amount', 'must be positive and at most $banked');
    }
    final working = Map<BudgetCategory, Money>.of(balances);
    final drawdown = Donors.draw(
      balances: working,
      needed: amount,
      order: [
        const DonorLimit(BudgetCategory.trySomethingNew),
        const DonorLimit(BudgetCategory.outings),
        DonorLimit(BudgetCategory.food, foodFloorPerDay.times(daysLeft)),
      ],
    );
    if (drawdown.remaining.isPositive) {
      throw StateError('Banked money is not available without touching the food floor');
    }
    return drawdown.toAdjustments(to: to, reason: AdjustmentReason.bankedMove, auto: false);
  }
}
