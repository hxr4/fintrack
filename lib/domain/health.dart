import 'package:budget_engine/budget_engine.dart';

enum HealthState { comfortable, tight, limit, neutral }

final class CategoryHealth {
  const CategoryHealth({required this.state, required this.coveredByFloor});

  final HealthState state;
  final bool coveredByFloor;

  static const comfortableRatioPercent = 90;
  static const tightRatioPercent = 50;

  static CategoryHealth of({
    required BudgetCategory category,
    required Money left,
    required Money total,
    required int daysLeft,
    required int cycleLength,
  }) {
    if (!_tracksPace(category)) {
      return const CategoryHealth(state: HealthState.neutral, coveredByFloor: false);
    }
    final state = stateFor(left: left, total: total, daysLeft: daysLeft, cycleLength: cycleLength);
    if (category == BudgetCategory.food && state == HealthState.limit) {
      return const CategoryHealth(state: HealthState.tight, coveredByFloor: true);
    }
    return CategoryHealth(state: state, coveredByFloor: false);
  }

  static HealthState stateFor({
    required Money left,
    required Money total,
    required int daysLeft,
    required int cycleLength,
  }) {
    if (!left.isPositive || !total.isPositive) {
      return HealthState.limit;
    }
    final ratioPercent = (left.paise * cycleLength * 100) ~/ (total.paise * (daysLeft < 1 ? 1 : daysLeft));
    if (ratioPercent >= comfortableRatioPercent) {
      return HealthState.comfortable;
    }
    if (ratioPercent >= tightRatioPercent) {
      return HealthState.tight;
    }
    return HealthState.limit;
  }

  static bool _tracksPace(BudgetCategory category) => switch (category.tier) {
        CategoryTier.essential || CategoryTier.flexible => true,
        _ => false,
      };
}
