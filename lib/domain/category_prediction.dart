import 'package:budget_engine/budget_engine.dart';

abstract final class CategoryPrediction {
  static const loggable = [
    BudgetCategory.food,
    BudgetCategory.petrol,
    BudgetCategory.nightFoodStock,
    BudgetCategory.essentialsStock,
    BudgetCategory.outings,
    BudgetCategory.trySomethingNew,
    BudgetCategory.misc,
    BudgetCategory.buffer,
  ];

  static int _bucketOf(int hour) {
    if (hour >= 4 && hour < 11) {
      return 0;
    }
    if (hour >= 11 && hour < 16) {
      return 1;
    }
    if (hour >= 16 && hour < 20) {
      return 2;
    }
    return 3;
  }

  static BudgetCategory predict({
    required DateTime now,
    required Iterable<Transaction> recent,
    required int boundaryHour,
    int minimumMatches = 3,
  }) {
    if (KolkataTime.isLateNight(now, boundaryHour: boundaryHour)) {
      return BudgetCategory.nightFoodStock;
    }
    final bucket = _bucketOf(KolkataTime.wallClock(now).hour);
    final cutoff = now.subtract(const Duration(days: 30));
    final counts = <BudgetCategory, int>{};
    for (final transaction in recent) {
      if (transaction.isCorrection || transaction.occurredAt.isBefore(cutoff)) {
        continue;
      }
      if (_bucketOf(KolkataTime.wallClock(transaction.occurredAt).hour) != bucket) {
        continue;
      }
      counts[transaction.category] = (counts[transaction.category] ?? 0) + 1;
    }
    BudgetCategory best = BudgetCategory.food;
    var bestCount = minimumMatches - 1;
    for (final category in loggable) {
      final count = counts[category] ?? 0;
      if (count > bestCount) {
        best = category;
        bestCount = count;
      }
    }
    return best;
  }
}
