import 'dart:math';

import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

Map<BudgetCategory, Money> spendOf(int food, int petrol, int outings, int treats, int misc) => {
      BudgetCategory.food: Money.rupees(food),
      BudgetCategory.petrol: Money.rupees(petrol),
      BudgetCategory.outings: Money.rupees(outings),
      BudgetCategory.trySomethingNew: Money.rupees(treats),
      BudgetCategory.misc: Money.rupees(misc),
    };

void main() {
  final defaults = standardSettings().defaultWeights;

  test('weights must sum to 100 percent', () {
    expect(
      () => CategoryWeights.fromPercent({
        BudgetCategory.food: 60,
        BudgetCategory.petrol: 14,
        BudgetCategory.outings: 9,
        BudgetCategory.trySomethingNew: 4,
        BudgetCategory.misc: 3,
        BudgetCategory.buffer: 9,
      }),
      throwsArgumentError,
    );
  });

  test('weights must cover exactly the weighted categories', () {
    expect(() => CategoryWeights({BudgetCategory.food: 10000}), throwsArgumentError);
  });

  test('defaults are used until three cycles have completed', () {
    final spends = [spendOf(7000, 1500, 1000, 300, 200), spendOf(7000, 1500, 1000, 300, 200)];
    expect(
      WeightBlender.blend(defaults: defaults, completedCycleSpends: spends, policy: policy),
      defaults,
    );
  });

  test('blends 70 percent actual with 30 percent defaults and keeps Buffer fixed', () {
    final spends = List.filled(3, spendOf(7000, 1500, 1000, 300, 200));
    final blended = WeightBlender.blend(
      defaults: defaults,
      completedCycleSpends: spends,
      previous: defaults,
      policy: policy,
    );
    expect(blended.basisPoints, {
      BudgetCategory.food: 6210,
      BudgetCategory.petrol: 1365,
      BudgetCategory.outings: 900,
      BudgetCategory.trySomethingNew: 309,
      BudgetCategory.misc: 216,
      BudgetCategory.buffer: 1000,
    });
  });

  test('an unused Buffer does not shrink', () {
    final spends = List.filled(5, spendOf(9000, 1000, 0, 0, 0));
    var weights = defaults;
    for (var cycle = 0; cycle < 6; cycle++) {
      weights = WeightBlender.blend(
        defaults: defaults,
        completedCycleSpends: spends,
        previous: weights,
        policy: policy,
      );
      expect(weights[BudgetCategory.buffer], 1000);
    }
  });

  test('each weight moves at most 3 points per cycle', () {
    final spends = List.filled(3, spendOf(3000, 1000, 5000, 500, 500));
    final blended = WeightBlender.blend(
      defaults: defaults,
      completedCycleSpends: spends,
      previous: defaults,
      policy: policy,
    );
    for (final category in BudgetCategory.weighted) {
      expect((blended[category] - defaults[category]).abs(), lessThanOrEqualTo(300), reason: category.name);
    }
    expect(blended[BudgetCategory.outings], 1200);
    expect(blended[BudgetCategory.food], 5700);
  });

  test('median of the last three cycles ignores one outlier cycle', () {
    final normal = spendOf(7000, 1500, 1000, 300, 200);
    final outlier = spendOf(2000, 500, 7000, 300, 200);
    final blended = WeightBlender.blend(
      defaults: defaults,
      completedCycleSpends: [normal, outlier, normal],
      previous: defaults,
      policy: policy,
    );
    final steady = WeightBlender.blend(
      defaults: defaults,
      completedCycleSpends: [normal, normal, normal],
      previous: defaults,
      policy: policy,
    );
    expect(blended, steady);
  });

  test('property: blended weights stay valid, capped and deterministic', () {
    final random = Random(7);
    var previous = defaults;
    for (var run = 0; run < 500; run++) {
      final spends = List.generate(
        3 + random.nextInt(3),
        (_) => spendOf(random.nextInt(9000), random.nextInt(3000), random.nextInt(4000), random.nextInt(1500), random.nextInt(1500)),
      );
      final blended = WeightBlender.blend(
        defaults: defaults,
        completedCycleSpends: spends,
        previous: previous,
        policy: policy,
      );
      expect(BudgetCategory.weighted.fold(0, (sum, category) => sum + blended[category]), 10000);
      expect(blended[BudgetCategory.buffer], 1000);
      for (final category in BudgetCategory.weighted) {
        expect(blended[category], greaterThanOrEqualTo(0));
        expect((blended[category] - previous[category]).abs(), lessThanOrEqualTo(300));
      }
      expect(
        WeightBlender.blend(defaults: defaults, completedCycleSpends: spends, previous: previous, policy: policy),
        blended,
      );
      previous = blended;
    }
  });
}
