import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  test('month lengths including leap years', () {
    expect(CivilDate.daysInMonth(2026, 2), 28);
    expect(CivilDate.daysInMonth(2028, 2), 29);
    expect(CivilDate.daysInMonth(2100, 2), 28);
    expect(CivilDate.daysInMonth(2000, 2), 29);
    expect(CivilDate.daysInMonth(2026, 4), 30);
    expect(CivilDate.daysInMonth(2026, 12), 31);
  });

  test('invalid dates are rejected', () {
    expect(() => CivilDate(2026, 2, 29), throwsArgumentError);
    expect(() => CivilDate(2026, 13, 1), throwsArgumentError);
  });

  test('clamped construction caps the day and normalises the month', () {
    expect(CivilDate.clamped(2026, 2, 31), d('2026-02-28'));
    expect(CivilDate.clamped(2028, 2, 31), d('2028-02-29'));
    expect(CivilDate.clamped(2026, 13, 31), d('2027-01-31'));
  });

  test('adding days crosses month, year and leap day', () {
    expect(d('2026-12-31').addDays(1), d('2027-01-01'));
    expect(d('2028-02-28').addDays(1), d('2028-02-29'));
    expect(d('2028-03-01').addDays(-1), d('2028-02-29'));
    expect(d('2026-03-01').addDays(-1), d('2026-02-28'));
  });

  test('days until counts calendar days', () {
    expect(d('2026-01-05').daysUntil(d('2026-02-05')), 31);
    expect(d('2028-02-05').daysUntil(d('2028-03-05')), 29);
    expect(d('2026-12-25').daysUntil(d('2027-01-05')), 11);
  });

  test('parsing and formatting round trip', () {
    expect(d('2026-03-09').toString(), '2026-03-09');
  });
}
