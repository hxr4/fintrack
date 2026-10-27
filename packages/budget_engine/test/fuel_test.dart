import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

FuelFill fill(String id, String date, int odometer, int rupees, int pricePaise, {bool full = true}) => FuelFill(
      id: id,
      date: d(date),
      amount: Money.rupees(rupees),
      pricePerLitre: Money(pricePaise),
      odometerKm: odometer,
      fullTank: full,
    );

void main() {
  final fills = [
    fill('f1', '2026-03-01', 10000, 500, 10000),
    fill('f2', '2026-03-06', 10180, 200, 10000, full: false),
    fill('f3', '2026-03-10', 10400, 300, 10000),
    fill('f4', '2026-03-20', 10800, 450, 11250),
  ];

  test('litres are derived from amount and price in whole millilitres', () {
    expect(FuelFill.litresFor(amount: Money.rupees(250), pricePerLitre: Money(10237)), 2442);
  });

  test('mileage runs full to full and includes partial fills in between', () {
    final segments = FuelLog.segments(fills);
    expect(segments, hasLength(2));
    expect(segments.first.distanceKm, 400);
    expect(segments.first.fuelMl, 5000);
    expect(segments.first.kmPerLitreTenths, 800);
    expect(segments.first.costPerKm, Money(125));
    expect(segments.last.kmPerLitreTenths, 1000);
  });

  test('fills before the first full tank are ignored', () {
    final segments = FuelLog.segments([
      fill('p', '2026-02-25', 9900, 100, 10000, full: false),
      ...fills,
    ]);
    expect(segments.first.fromFillId, 'f1');
  });

  test('summary averages recent segments, riding rate and a petrol suggestion', () {
    final summary = FuelLog.summarise(fills, today: d('2026-03-25'));
    expect(summary.averageKmPerLitreTenths, 889);
    expect(summary.averageCostPerKm, Money(119));
    expect(summary.kmPerDayTenths, 421);
    expect(summary.suggestedPerCycle(30), Money.rupees(1500));
  });

  test('no full-to-full pair means no mileage yet', () {
    final summary = FuelLog.summarise([fills.first], today: d('2026-03-25'));
    expect(summary.latest, isNull);
    expect(summary.averageKmPerLitreTenths, isNull);
    expect(summary.suggestedPerCycle(30), isNull);
  });
}
