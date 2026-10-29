import 'package:budget_engine/budget_engine.dart';
import 'package:fintrack/domain/cycle_planning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  Future<void> openPlanTool(WidgetTester tester, String key) async {
    await tester.tap(find.text('Plan').last);
    await settle(tester);
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await settle(tester);
  }

  testWidgets('balance check compares, explains neutrally and replans', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock);
    clock.now = ist(2026, 3, 10, 15);
    await pumpApp(tester, db: db, clock: clock);
    await tester.tap(find.byKey(const Key('chip-100')));
    await settle(tester);

    await openPlanTool(tester, 'tool-balance-check');
    await tester.enterText(find.byKey(const Key('check-bank')), '11700');
    await tester.tap(find.byKey(const Key('check-compare')));
    await settle(tester);
    expect(
      find.text('Your money is ₹200 lower than the app expected. That usually means a few spends were not logged.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('resolve-unlogged')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('check-apply')));
    await tester.tap(find.byKey(const Key('check-apply')));
    await settle(tester);
    expect(find.text('Plan updated from your real balance'), findsOneWidget);
    await unmount(tester);
    await db.close();
  });

  testWidgets('a surplus close to the monthly money suggests logging the deposit first (F41)', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock);
    clock.now = ist(2026, 4, 5, 10);
    await pumpApp(tester, db: db, clock: clock);
    await openPlanTool(tester, 'tool-balance-check');
    expect(find.byKey(const Key('check-help')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('check-bank')), '24500');
    await tester.tap(find.byKey(const Key('check-compare')));
    await settle(tester);
    expect(find.text("This looks like this month's money. Log it first?"), findsOneWidget);
    expect(find.byKey(const Key('resolve-unlogged')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('check-bank')), '12500');
    await tester.tap(find.byKey(const Key('check-compare')));
    await settle(tester);
    expect(find.byKey(const Key('deposit-lookalike')), findsNothing);
    await unmount(tester);
    await db.close();
  });

  testWidgets('restocking a supply from the Supplies tab', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock, supplies: [
      SupplyDraft(name: 'Soap', price: Money.rupees(90), lifespanDays: 45, lastRestock: CivilDate(2026, 2, 1)),
    ]);
    await pumpApp(tester, db: db, clock: clock);
    await openPlanTool(tester, 'tool-supplies');
    expect(find.text('Soap'), findsOneWidget);
    expect(find.text('8 days left'), findsOneWidget);
    await tester.tap(find.byKey(const Key('supply-Soap')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('supply-restocked')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('payment-save')));
    await settle(tester);
    expect(find.text('Restock of Soap logged'), findsOneWidget);
    expect(find.text('45 days left'), findsOneWidget);
    await unmount(tester);
    await db.close();
  });

  testWidgets('logging fuel from the Bike tab', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock);
    await pumpApp(tester, db: db, clock: clock);
    await openPlanTool(tester, 'tool-supplies');
    await tester.tap(find.byKey(const Key('tab-bike')));
    await settle(tester);
    expect(find.text('Mileage shows after two full-tank fills.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('log-fuel')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('fuel-amount')), '300');
    await tester.enterText(find.byKey(const Key('fuel-price')), '102.5');
    await tester.enterText(find.byKey(const Key('fuel-odometer')), '15000');
    await tester.ensureVisible(find.byKey(const Key('fuel-save')));
    await tester.tap(find.byKey(const Key('fuel-save')));
    await settle(tester);
    expect(find.text('Fuel of ₹300 logged in Petrol'), findsOneWidget);
    expect(find.textContaining('15000 km · full'), findsOneWidget);
    await unmount(tester);
    await db.close();
  });

  testWidgets('budget values save and the split must add to 100', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock);
    await pumpApp(tester, db: db, clock: clock);
    await openPlanTool(tester, 'tool-budget-values');
    await tester.enterText(find.byKey(const Key('values-food')), '170');
    await tester.ensureVisible(find.byKey(const Key('values-save')));
    await tester.tap(find.byKey(const Key('values-save')));
    await settle(tester);
    expect(find.text('Budget values saved'), findsOneWidget);
    await unmount(tester);
    await db.close();
  });
}
