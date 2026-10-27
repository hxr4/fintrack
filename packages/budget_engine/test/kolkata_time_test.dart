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
}
