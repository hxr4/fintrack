import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  final window = windowFrom('2026-04-05');

  Map<CivilDate, Money> steady(String from, int days, int rupees) => {
        for (var offset = 0; offset < days; offset++) d(from).addDays(offset): Money.rupees(rupees),
      };

  test('runway uses the trailing seven-day average and reports days short', () {
    final runway = RunwayCalculator.compute(
      pool: Money.rupees(3000),
      today: d('2026-04-15'),
      window: window,
      poolSpendByDay: steady('2026-04-05', 10, 200),
      baseDaily: Money.rupees(250),
    );
    expect(runway.averageDailySpend, Money.rupees(200));
    expect(runway.coveredDays, 15);
    expect(runway.daysLeft, 20);
    expect(runway.daysShort, 5);
    expect(runway.runsOutOn, d('2026-04-30'));
  });

  test('days spare when spending is below pace', () {
    final runway = RunwayCalculator.compute(
      pool: Money.rupees(5000),
      today: d('2026-04-15'),
      window: window,
      poolSpendByDay: steady('2026-04-05', 10, 100),
      baseDaily: Money.rupees(250),
    );
    expect(runway.daysSpare, 30);
    expect(runway.isShort, isFalse);
  });

  test('day one falls back to base daily', () {
    final runway = RunwayCalculator.compute(
      pool: Money.rupees(7500),
      today: d('2026-04-05'),
      window: window,
      poolSpendByDay: const {},
      baseDaily: Money.rupees(250),
    );
    expect(runway.averageDailySpend, Money.rupees(250));
    expect(runway.daysSpare, 0);
  });

  test('early in the cycle only the days so far are averaged', () {
    final runway = RunwayCalculator.compute(
      pool: Money.rupees(7000),
      today: d('2026-04-07'),
      window: window,
      poolSpendByDay: {d('2026-04-05'): Money.rupees(300), d('2026-04-06'): Money.rupees(100)},
      baseDaily: Money.rupees(250),
    );
    expect(runway.averageDailySpend, Money.rupees(200));
  });

  test('a quiet week is comfortable instead of dividing by zero', () {
    final runway = RunwayCalculator.compute(
      pool: Money.rupees(3000),
      today: d('2026-04-20'),
      window: window,
      poolSpendByDay: const {},
      baseDaily: Money.rupees(250),
    );
    expect(runway.isComfortable, isTrue);
    expect(runway.runsOutOn, isNull);
  });
}
