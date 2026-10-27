import 'package:budget_engine/budget_engine.dart';
import 'package:fintrack/app/state.dart';
import 'package:fintrack/domain/category_prediction.dart';
import 'package:fintrack/domain/health.dart';
import 'package:fintrack/domain/log_parser.dart';
import 'package:fintrack/domain/rupees.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  group('rupees', () {
    test('Indian digit grouping', () {
      expect(Rupees.format(Money.rupees(12000)), '₹12,000');
      expect(Rupees.format(Money.rupees(120000)), '₹1,20,000');
      expect(Rupees.format(Money.rupees(12345678)), '₹1,23,45,678');
      expect(Rupees.format(const Money(31586)), '₹316');
      expect(Rupees.format(const Money(-2500)), '-₹25');
    });

    test('parsing accepts whole rupees and paise only', () {
      expect(Rupees.parse('1,200'), Money.rupees(1200));
      expect(Rupees.parse('₹ 40.5'), const Money(4050));
      expect(Rupees.parse('40.555'), isNull);
      expect(Rupees.parse('abc'), isNull);
    });
  });

  group('type-to-log parser', () {
    test('amount then word', () {
      final entry = LogParser.parse('40 lunch')!;
      expect(entry.amount, Money.rupees(40));
      expect(entry.category, BudgetCategory.food);
      expect(entry.note, 'lunch');
    });

    test('word then amount, and an unknown word', () {
      final entry = LogParser.parse('xerox 25')!;
      expect(entry.category, BudgetCategory.misc);
      final unknown = LogParser.parse('120 stuff')!;
      expect(unknown.category, isNull);
      expect(unknown.keyword, 'stuff');
    });

    test('learned corrections win over built-in keywords', () {
      final entry = LogParser.parse('60 tea', learned: {'tea': BudgetCategory.outings})!;
      expect(entry.category, BudgetCategory.outings);
    });

    test('no amount means nothing to confirm', () {
      expect(LogParser.parse('lunch'), isNull);
    });
  });

  group('category prediction', () {
    test('late night predicts night food stock', () {
      expect(
        CategoryPrediction.predict(now: ist(2026, 3, 11, 1, 30), recent: const [], boundaryHour: 4),
        BudgetCategory.nightFoodStock,
      );
    });

    test('defaults to Food and learns the habit for that time of day', () {
      final recent = [
        for (var day = 1; day <= 3; day++)
          Transaction(
            id: 'p$day',
            amount: Money.rupees(300),
            category: BudgetCategory.petrol,
            method: PaymentMethod.upi,
            occurredAt: ist(2026, 3, day, 18),
            source: TransactionSource.manual,
          ),
      ];
      expect(CategoryPrediction.predict(now: ist(2026, 3, 5, 9), recent: recent, boundaryHour: 4), BudgetCategory.food);
      expect(CategoryPrediction.predict(now: ist(2026, 3, 5, 18), recent: recent, boundaryHour: 4), BudgetCategory.petrol);
    });
  });

  group('health', () {
    test('Food at the limit is amber and covered by the floor, never red', () {
      final health = CategoryHealth.of(
        category: BudgetCategory.food,
        left: Money.zero,
        total: Money.rupees(6000),
        daysLeft: 10,
        cycleLength: 30,
      );
      expect(health.state, HealthState.tight);
      expect(health.coveredByFloor, isTrue);
    });

    test('other categories can reach the limit', () {
      expect(
        CategoryHealth.of(category: BudgetCategory.outings, left: Money.zero, total: Money.rupees(900), daysLeft: 10, cycleLength: 30).state,
        HealthState.limit,
      );
    });

    test('pace ratio decides comfortable and tight', () {
      expect(CategoryHealth.stateFor(left: Money.rupees(500), total: Money.rupees(1000), daysLeft: 15, cycleLength: 30), HealthState.comfortable);
      expect(CategoryHealth.stateFor(left: Money.rupees(300), total: Money.rupees(1000), daysLeft: 15, cycleLength: 30), HealthState.tight);
      expect(CategoryHealth.stateFor(left: Money.rupees(100), total: Money.rupees(1000), daysLeft: 15, cycleLength: 30), HealthState.limit);
    });

    test('Goals and Buffer are neutral', () {
      expect(
        CategoryHealth.of(category: BudgetCategory.goals, left: Money.zero, total: Money.zero, daysLeft: 1, cycleLength: 30).state,
        HealthState.neutral,
      );
    });
  });

  group('lock timer', () {
    test('locks only after 30 seconds in the background', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final lock = container.read(lockProvider.notifier);
      lock.unlock();
      final start = DateTime.utc(2026, 3, 10, 8);
      lock.onBackground(start);
      lock.onForeground(start.add(const Duration(seconds: 29)));
      expect(container.read(lockProvider), isFalse);
      lock.onBackground(start);
      lock.onForeground(start.add(const Duration(seconds: 30)));
      expect(container.read(lockProvider), isTrue);
    });
  });
}
