import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  group('cycle lengths', () {
    test('28 day cycle in February of a common year', () {
      expect(windowFrom('2026-02-05').length, 28);
    });

    test('29 day cycle in February of a leap year', () {
      final window = windowFrom('2028-02-05');
      expect(window.length, 29);
      expect(window.contains(d('2028-02-29')), isTrue);
    });

    test('30 day cycle', () {
      expect(windowFrom('2026-04-05').length, 30);
    });

    test('31 day cycle', () {
      expect(windowFrom('2026-01-05').length, 31);
    });

    test('cycle across the year end', () {
      final window = windowFrom('2026-12-05');
      expect(window.nextStart, d('2027-01-05'));
      expect(window.length, 31);
    });
  });

  group('cycle starting on the 31st', () {
    test('anchor 31 clamps per month without drifting to 28', () {
      final starts = <CivilDate>[d('2026-01-31')];
      for (var step = 0; step < 6; step++) {
        starts.add(CycleCalendar.expectedNextStart(starts.last, anchorDay: 31, policy: policy));
      }
      expect(starts, [
        d('2026-01-31'),
        d('2026-02-28'),
        d('2026-03-31'),
        d('2026-04-30'),
        d('2026-05-31'),
        d('2026-06-30'),
        d('2026-07-31'),
      ]);
    });

    test('leap year February ends on the 29th', () {
      expect(
        CycleCalendar.expectedNextStart(d('2028-01-31'), anchorDay: 31, policy: policy),
        d('2028-02-29'),
      );
    });

    test('deposit on the 31st with the default anchor of the 5th', () {
      final window = windowFrom('2026-01-31');
      expect(window.nextStart, d('2026-03-05'));
      expect(window.length, 33);
    });
  });

  group('late and early deposits', () {
    test('late deposit gives a shorter cycle, not a shifted one', () {
      final window = windowFrom('2026-03-09');
      expect(window.nextStart, d('2026-04-05'));
      expect(window.length, 27);
    });

    test('very late deposit skips to the following month', () {
      final window = windowFrom('2026-03-25');
      expect(window.nextStart, d('2026-05-05'));
    });

    test('early deposit before the anchor day still ends on the next anchor', () {
      final window = windowFrom('2026-02-28');
      expect(window.nextStart, d('2026-04-05'));
    });

    test('a cycle can end early when the next deposit arrives early', () {
      final window = windowFrom('2026-03-05').endingEarlyOn(d('2026-04-02'));
      expect(window.length, 28);
    });
  });

  group('awaiting deposit', () {
    final window = windowFrom('2026-02-05');

    test('awaiting starts on the expected next start', () {
      expect(CycleCalendar.isAwaitingDeposit(window, d('2026-03-04')), isFalse);
      expect(CycleCalendar.isAwaitingDeposit(window, d('2026-03-05')), isTrue);
    });

    test('plan days count to the grace date with a minimum of three', () {
      expect(CycleCalendar.awaitingPlanDays(expectedStart: d('2026-03-05'), today: d('2026-03-05'), policy: policy), 4);
      expect(CycleCalendar.awaitingPlanDays(expectedStart: d('2026-03-05'), today: d('2026-03-07'), policy: policy), 3);
      expect(CycleCalendar.awaitingPlanDays(expectedStart: d('2026-03-05'), today: d('2026-03-12'), policy: policy), 3);
    });
  });

  test('days left counts today', () {
    final window = windowFrom('2026-04-05');
    expect(window.daysLeftIncluding(d('2026-04-05')), 30);
    expect(window.daysLeftIncluding(d('2026-05-04')), 1);
    expect(() => window.daysLeftIncluding(d('2026-05-05')), throwsArgumentError);
  });
}
