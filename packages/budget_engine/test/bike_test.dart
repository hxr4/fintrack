import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  final plan = BikeServicePlan(
    intervalKm: 3000,
    intervalMonths: 4,
    cost: Money.rupees(1500),
    lastServiceDate: d('2026-01-10'),
    lastServiceKm: 9000,
  );

  test('service is due by whichever comes first, date or distance', () {
    final due = BikeSchedule.serviceDue(
      plan: plan,
      today: d('2026-03-25'),
      currentKm: 10800,
      ridingKm: 800,
      ridingDays: 19,
    );
    expect(due.dueByDate, d('2026-05-10'));
    expect(due.dueByKm, 12000);
    expect(due.kmLeft, 1200);
    expect(due.daysLeft, 28);
    expect(due.isDue, isFalse);
  });

  test('without a riding rate the date decides', () {
    final due = BikeSchedule.serviceDue(plan: plan, today: d('2026-03-25'), currentKm: 10800);
    expect(due.daysLeft, 46);
  });

  test('overdue by distance is due now', () {
    final due = BikeSchedule.serviceDue(plan: plan, today: d('2026-03-25'), currentKm: 12100, ridingKm: 800, ridingDays: 19);
    expect(due.isDue, isTrue);
    expect(due.daysLeft, 0);
  });

  test('month interval clamps to the month length', () {
    expect(BikeServicePlan(intervalMonths: 4, lastServiceDate: d('2025-10-31')).dueByDate, d('2026-02-28'));
  });

  test('service fund catches up before the service is due', () {
    expect(
      BikeSchedule.fundIncrement(serviceCost: Money.rupees(1500), fundBalance: Money.zero, daysUntilDue: 28, cycleLength: 31),
      Money.rupees(1500),
    );
    expect(
      BikeSchedule.fundIncrement(serviceCost: Money.rupees(1500), fundBalance: Money.zero, daysUntilDue: 90, cycleLength: 31),
      Money(51667),
    );
    expect(
      BikeSchedule.fundIncrement(serviceCost: Money.rupees(1500), fundBalance: Money.rupees(1500), daysUntilDue: 90, cycleLength: 31),
      Money.zero,
    );
  });
}
