import 'category.dart';

final class CategoryWeights {
  factory CategoryWeights(Map<BudgetCategory, int> basisPoints) {
    final keys = basisPoints.keys.toSet();
    if (keys.length != BudgetCategory.weighted.length ||
        !keys.containsAll(BudgetCategory.weighted)) {
      throw ArgumentError.value(
        basisPoints,
        'basisPoints',
        'must cover exactly ${BudgetCategory.weighted}',
      );
    }
    if (basisPoints.values.any((value) => value < 0)) {
      throw ArgumentError.value(basisPoints, 'basisPoints', 'must not be negative');
    }
    final sum = basisPoints.values.fold(0, (total, value) => total + value);
    if (sum != total) {
      throw ArgumentError.value(sum, 'basisPoints', 'must sum to $total');
    }
    return CategoryWeights._({
      for (final category in BudgetCategory.weighted) category: basisPoints[category]!,
    });
  }

  factory CategoryWeights.fromPercent(Map<BudgetCategory, int> percent) {
    final sum = percent.values.fold(0, (total, value) => total + value);
    if (sum != 100) {
      throw ArgumentError.value(sum, 'percent', 'must sum to 100');
    }
    return CategoryWeights({
      for (final entry in percent.entries) entry.key: entry.value * 100,
    });
  }

  const CategoryWeights._(this._basisPoints);

  static const total = 10000;

  final Map<BudgetCategory, int> _basisPoints;

  int operator [](BudgetCategory category) => _basisPoints[category] ?? 0;

  Map<BudgetCategory, int> get basisPoints => Map.unmodifiable(_basisPoints);

  Map<BudgetCategory, int> get blendedBasisPoints => {
        for (final category in BudgetCategory.blended) category: this[category],
      };

  @override
  bool operator ==(Object other) =>
      other is CategoryWeights &&
      BudgetCategory.weighted.every((category) => other[category] == this[category]);

  @override
  int get hashCode => Object.hashAll(BudgetCategory.weighted.map((category) => this[category]));

  @override
  String toString() => 'CategoryWeights(${_basisPoints.entries.map((entry) => '${entry.key.name}: ${entry.value}').join(', ')})';
}
