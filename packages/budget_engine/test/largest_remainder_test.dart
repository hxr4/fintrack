import 'dart:math';

import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

void main() {
  test('parts always sum exactly to the whole', () {
    final parts = LargestRemainder.splitInt(100, {'a': 1, 'b': 1, 'c': 1});
    expect(parts.values.reduce((a, b) => a + b), 100);
    expect(parts, {'a': 34, 'b': 33, 'c': 33});
  });

  test('ties go to the earlier key', () {
    expect(LargestRemainder.splitInt(1, {'x': 1, 'y': 1}), {'x': 1, 'y': 0});
  });

  test('largest remainder wins the leftover units', () {
    expect(LargestRemainder.splitInt(10, {'a': 1, 'b': 2, 'c': 4}), {'a': 1, 'b': 3, 'c': 6});
  });

  test('zero total gives zeros even with zero weights', () {
    expect(LargestRemainder.splitInt(0, {'a': 0, 'b': 0}), {'a': 0, 'b': 0});
  });

  test('positive total with all-zero weights is rejected', () {
    expect(() => LargestRemainder.splitInt(5, {'a': 0}), throwsArgumentError);
  });

  test('property: random splits are exact, non-negative and deterministic', () {
    final random = Random(42);
    for (var run = 0; run < 2000; run++) {
      final total = random.nextInt(5000000);
      final weights = {
        for (var key = 0; key < 1 + random.nextInt(9); key++) key: random.nextInt(10000),
      };
      if (weights.values.every((weight) => weight == 0)) {
        weights[0] = 1;
      }
      final parts = LargestRemainder.splitInt(total, weights);
      expect(parts.values.reduce((a, b) => a + b), total);
      expect(parts.values.every((part) => part >= 0), isTrue);
      expect(LargestRemainder.splitInt(total, weights), parts);
    }
  });
}
