import 'adjustment.dart';
import 'category.dart';
import 'donors.dart';
import 'money.dart';

final class AutoAdjustResult {
  const AutoAdjustResult({required this.moves, required this.uncovered});

  final List<AdjustmentDraft> moves;
  final Map<BudgetCategory, Money> uncovered;

  bool get moved => moves.isNotEmpty;
  bool get shortfall => uncovered.values.any((amount) => amount.isPositive);
  Money get totalMoved => Money.sum(moves.map((move) => move.amount));
}

abstract final class AutoAdjuster {
  static Money refillTarget({
    required BudgetCategory category,
    required Money foodFloorPerDay,
    required Money petrolFloorForCycle,
    required int cycleLength,
    required int daysLeft,
  }) =>
      switch (category) {
        BudgetCategory.food => foodFloorPerDay.times(daysLeft),
        BudgetCategory.petrol => petrolFloorForCycle.times(daysLeft).ceilDiv(cycleLength),
        BudgetCategory.nightFoodStock => Money.zero,
        _ => throw ArgumentError.value(category, 'category', 'is not essential'),
      };

  static AutoAdjustResult run({
    required Map<BudgetCategory, Money> balances,
    required Money foodFloorPerDay,
    required Money petrolFloorForCycle,
    required int cycleLength,
    required int daysLeft,
    Money essentialsReservedForDue = Money.zero,
  }) {
    final working = Map<BudgetCategory, Money>.of(balances);
    final moves = <AdjustmentDraft>[];
    final uncovered = <BudgetCategory, Money>{};
    for (final category in BudgetCategory.essentials) {
      final balance = working[category] ?? Money.zero;
      if (balance.isPositive) {
        continue;
      }
      final target = refillTarget(
        category: category,
        foodFloorPerDay: foodFloorPerDay,
        petrolFloorForCycle: petrolFloorForCycle,
        cycleLength: cycleLength,
        daysLeft: daysLeft,
      );
      final needed = target - balance;
      if (!needed.isPositive) {
        continue;
      }
      final drawdown = Donors.draw(
        balances: working,
        needed: needed,
        order: [
          const DonorLimit(BudgetCategory.buffer),
          const DonorLimit(BudgetCategory.trySomethingNew),
          const DonorLimit(BudgetCategory.outings),
          DonorLimit(BudgetCategory.essentialsStock, essentialsReservedForDue),
        ],
      );
      working[category] = balance + drawdown.taken;
      moves.addAll(drawdown.toAdjustments(
        to: category,
        reason: AdjustmentReason.autoRefill,
        auto: true,
      ));
      if (drawdown.remaining.isPositive) {
        uncovered[category] = drawdown.remaining;
      }
    }
    return AutoAdjustResult(moves: moves, uncovered: uncovered);
  }
}
