import 'category.dart';
import 'largest_remainder.dart';
import 'money.dart';
import 'policy.dart';
import 'weights.dart';

abstract final class WeightBlender {
  static CategoryWeights blend({
    required CategoryWeights defaults,
    required List<Map<BudgetCategory, Money>> completedCycleSpends,
    required BudgetPolicy policy,
    CategoryWeights? previous,
  }) {
    if (completedCycleSpends.length < policy.blendingStartsAfterCompletedCycles) {
      return defaults;
    }
    final bufferWeight = defaults[BudgetCategory.buffer];
    final blendedTotal = CategoryWeights.total - bufferWeight;
    final defaultShares = LargestRemainder.splitInt(blendedTotal, defaults.blendedBasisPoints);
    final window = completedCycleSpends.sublist(
      completedCycleSpends.length - policy.blendingWindowCycles.clamp(1, completedCycleSpends.length),
    );
    final cycleShares = [
      for (final spend in window) _sharesOf(spend, blendedTotal, defaultShares),
    ];
    final medianShares = {
      for (final category in BudgetCategory.blended)
        category: _medianInt([for (final shares in cycleShares) shares[category]!]),
    };
    final actualShares = _normalise(blendedTotal, medianShares, defaultShares);
    final mixed = {
      for (final category in BudgetCategory.blended)
        category: policy.blendActualPercent * actualShares[category]! +
            (100 - policy.blendActualPercent) * defaultShares[category]!,
    };
    var blended = _normalise(blendedTotal, mixed, defaultShares);
    if (previous != null && previous[BudgetCategory.buffer] == bufferWeight) {
      blended = _capChange(blended, previous.blendedBasisPoints, policy.maxWeightChangeBasisPoints, blendedTotal);
    }
    return CategoryWeights({...blended, BudgetCategory.buffer: bufferWeight});
  }

  static Map<BudgetCategory, int> _sharesOf(
    Map<BudgetCategory, Money> spend,
    int total,
    Map<BudgetCategory, int> fallback,
  ) {
    final basis = {
      for (final category in BudgetCategory.blended)
        category: (spend[category] ?? Money.zero).positivePart.paise,
    };
    if (basis.values.every((value) => value == 0)) {
      return fallback;
    }
    return LargestRemainder.splitInt(total, basis);
  }

  static Map<BudgetCategory, int> _normalise(
    int total,
    Map<BudgetCategory, int> basis,
    Map<BudgetCategory, int> fallback,
  ) {
    if (basis.values.every((value) => value == 0)) {
      return fallback;
    }
    return LargestRemainder.splitInt(total, basis);
  }

  static int _medianInt(List<int> values) {
    final sorted = [...values]..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) ~/ 2;
  }

  static Map<BudgetCategory, int> _capChange(
    Map<BudgetCategory, int> target,
    Map<BudgetCategory, int> previous,
    int maxChange,
    int total,
  ) {
    final previousSum = previous.values.fold(0, (sum, value) => sum + value);
    if (previousSum != total) {
      return target;
    }
    int lower(BudgetCategory category) {
      final bound = previous[category]! - maxChange;
      return bound < 0 ? 0 : bound;
    }

    int upper(BudgetCategory category) => previous[category]! + maxChange;
    final capped = <BudgetCategory, int>{
      for (final category in BudgetCategory.blended)
        category: target[category]!.clamp(lower(category), upper(category)),
    };
    var residual = total - capped.values.fold<int>(0, (sum, value) => sum + value);
    final order = [...BudgetCategory.blended]
      ..sort((a, b) {
        final gapA = target[a]! - capped[a]!;
        final gapB = target[b]! - capped[b]!;
        final byGap = residual > 0 ? gapB.compareTo(gapA) : gapA.compareTo(gapB);
        return byGap != 0 ? byGap : a.index.compareTo(b.index);
      });
    for (final category in order) {
      if (residual == 0) {
        break;
      }
      if (residual > 0) {
        final room = upper(category) - capped[category]!;
        final give = room < residual ? room : residual;
        capped[category] = capped[category]! + give;
        residual -= give;
      } else {
        final room = capped[category]! - lower(category);
        final take = room < -residual ? room : -residual;
        capped[category] = capped[category]! - take;
        residual += take;
      }
    }
    return capped;
  }
}
