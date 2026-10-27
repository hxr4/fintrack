import 'money.dart';

abstract final class LargestRemainder {
  static Map<K, int> splitInt<K>(int total, Map<K, int> weights) {
    if (total < 0) {
      throw ArgumentError.value(total, 'total', 'must not be negative');
    }
    if (weights.values.any((weight) => weight < 0)) {
      throw ArgumentError.value(weights, 'weights', 'must not be negative');
    }
    final keys = weights.keys.toList();
    final weightSum = weights.values.fold(0, (sum, weight) => sum + weight);
    if (total == 0) {
      return {for (final key in keys) key: 0};
    }
    if (weightSum == 0) {
      throw ArgumentError.value(weights, 'weights', 'must not all be zero');
    }
    final shares = <K, int>{};
    final remainders = <K, int>{};
    var assigned = 0;
    for (final key in keys) {
      final product = total * weights[key]!;
      shares[key] = product ~/ weightSum;
      remainders[key] = product % weightSum;
      assigned += shares[key]!;
    }
    final ranked = List<int>.generate(keys.length, (index) => index)
      ..sort((a, b) {
        final byRemainder = remainders[keys[b]]!.compareTo(remainders[keys[a]]!);
        return byRemainder != 0 ? byRemainder : a.compareTo(b);
      });
    var leftover = total - assigned;
    for (final index in ranked) {
      if (leftover == 0) {
        break;
      }
      shares[keys[index]] = shares[keys[index]]! + 1;
      leftover -= 1;
    }
    return shares;
  }

  static Map<K, Money> split<K>(Money total, Map<K, int> weights) {
    final shares = splitInt(total.paise, weights);
    return {for (final entry in shares.entries) entry.key: Money(entry.value)};
  }

  static Map<K, Money> splitByAmounts<K>(Money total, Map<K, Money> basis) {
    return split(total, {
      for (final entry in basis.entries) entry.key: entry.value.positivePart.paise,
    });
  }
}
