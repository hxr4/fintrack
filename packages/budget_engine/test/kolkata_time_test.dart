import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  test('IST date flips at 18:30 UTC', () {
    expect(KolkataTime.dateOf(DateTime.utc(2026, 3, 4, 18, 29)), d('2026-03-04'));
    expect(KolkataTime.dateOf(DateTime.utc(2026, 3, 4, 18, 30)), d('2026-03-05'));
  });

  test('year end in IST happens before UTC year end', () {
    expect(KolkataTime.dateOf(DateTime.utc(2026, 12, 31, 19)), d('2027-01-01'));
  });

  test('device local time zone does not matter', () {
    final instant = DateTime.utc(2026, 6, 1, 20);
    expect(KolkataTime.dateOf(instant.toLocal()), KolkataTime.dateOf(instant));
  });

  test('allowance day rolls over at the boundary hour, not midnight', () {
    final lateSnack = KolkataTime.at(d('2026-03-06'), 1, 30);
    final morning = KolkataTime.at(d('2026-03-06'), 4);
    expect(KolkataTime.dateOf(lateSnack), d('2026-03-06'));
    expect(KolkataTime.allowanceDateOf(lateSnack, boundaryHour: 4), d('2026-03-05'));
    expect(KolkataTime.allowanceDateOf(morning, boundaryHour: 4), d('2026-03-06'));
    expect(KolkataTime.isLateNight(lateSnack, boundaryHour: 4), isTrue);
    expect(KolkataTime.isLateNight(morning, boundaryHour: 4), isFalse);
  });

  test('start of an IST date is 18:30 UTC on the previous day', () {
    expect(KolkataTime.startOfDate(d('2026-03-05')), DateTime.utc(2026, 3, 4, 18, 30));
  });

  group('allowance day boundary at 04:00', () {
    final evening = d('2026-03-05');
    final next = d('2026-03-06');
    final cases = <(String, DateTime, CivilDate, bool)>[
      ('23:59', KolkataTime.at(evening, 23, 59), evening, false),
      ('00:00', KolkataTime.at(next, 0), evening, true),
      ('03:59', KolkataTime.at(next, 3, 59), evening, true),
      ('04:00', KolkataTime.at(next, 4), next, false),
    ];
    for (final (label, instant, allowanceDay, lateNight) in cases) {
      test(label, () {
        expect(KolkataTime.allowanceDateOf(instant, boundaryHour: 4), allowanceDay);
        expect(KolkataTime.isLateNight(instant, boundaryHour: 4), lateNight);
      });
    }

    test('03:59:59.999 is still the previous allowance day', () {
      final instant = KolkataTime.at(next, 4).subtract(const Duration(milliseconds: 1));
      expect(KolkataTime.allowanceDateOf(instant, boundaryHour: 4), evening);
    });

    test('the boundary also holds across a month and year end', () {
      expect(KolkataTime.allowanceDateOf(KolkataTime.at(d('2027-01-01'), 3, 59), boundaryHour: 4), d('2026-12-31'));
      expect(KolkataTime.allowanceDateOf(KolkataTime.at(d('2028-03-01'), 0), boundaryHour: 4), d('2028-02-29'));
    });
  });
}
