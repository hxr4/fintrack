import 'dart:io';

import 'package:budget_engine/budget_engine.dart';
import 'package:drift/native.dart';
import 'package:fintrack/data/database.dart';
import 'package:fintrack/platform/authenticator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  testWidgets('full onboarding lands on home with the ring and category cards', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await pumpApp(tester, db: db, clock: clock);

    expect(find.byKey(const Key('onboard-next')), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboard-next')));
    await settle(tester);

    await tester.enterText(find.byKey(const Key('field-deposit')), '12000');
    await tester.tap(find.byKey(const Key('onboard-next')));
    await settle(tester);

    expect(find.byKey(const Key('field-food-floor')), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboard-next')));
    await settle(tester);

    await tester.tap(find.byKey(const Key('onboard-next')));
    await settle(tester);

    await tester.enterText(find.byKey(const Key('field-bank')), '12000');
    await tester.tap(find.byKey(const Key('onboard-next')));
    await settle(tester);

    await tester.tap(find.byKey(const Key('onboard-next')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('onboard-next')));
    await settle(tester);

    await tester.tap(find.byKey(const Key('field-card')));
    await tester.tap(find.byKey(const Key('onboard-next')));
    await settle(tester, frames: 60);

    expect(find.byKey(const Key('ring-amount')), findsOneWidget);
    expect(ringText(tester), '₹316');
    expect(tester.widget<Text>(find.byKey(const Key('cycle-line'))).data, 'Day 1 of 26, 26 left');
    for (final category in [BudgetCategory.food, BudgetCategory.petrol, BudgetCategory.goals]) {
      expect(find.byKey(Key('card-${category.name}')), findsOneWidget);
    }
    expect(find.byKey(const Key('card-bikeFund')), findsNothing);
    expect(find.byKey(const Key('card-recurringFund')), findsNothing);
    expect(find.byKey(const Key('add-goals')), findsNothing);
    expect(leftText(tester, BudgetCategory.food), '₹6,750');
    await unmount(tester);
    await db.close();
  });

  testWidgets('a quick-add chip logs in one tap and the ring updates at once', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock);
    await pumpApp(tester, db: db, clock: clock);

    expect(ringText(tester), '₹316');
    expect(find.text('+40 Food'), findsOneWidget);
    await tester.tap(find.byKey(const Key('chip-40')));
    await settle(tester);

    expect(ringText(tester), '₹276');
    expect(leftText(tester, BudgetCategory.food), '₹6,710');
    expect(find.text('Logged ₹40 in Food'), findsOneWidget);
    await unmount(tester);
    await db.close();
  });

  testWidgets('long press on a chip opens the add sheet prefilled', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock);
    await pumpApp(tester, db: db, clock: clock);

    await tester.longPress(find.byKey(const Key('chip-100')));
    await settle(tester);
    expect(tester.widget<Text>(find.byKey(const Key('add-amount'))).data, '₹100');
    expect(tester.widget<ChoiceChip>(find.byKey(const Key('add-category-food'))).selected, isTrue);
    await unmount(tester);
    await db.close();
  });

  testWidgets('add sheet logs with category plus, amount and save; card is hidden until enabled', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock);
    await pumpApp(tester, db: db, clock: clock);

    await tester.tap(find.byKey(const Key('add-petrol')));
    await settle(tester);
    expect(find.byKey(const Key('method-cash')), findsOneWidget);
    expect(find.byKey(const Key('method-upi')), findsOneWidget);
    expect(find.byKey(const Key('method-card')), findsNothing);
    await tester.tap(find.byKey(const Key('pad-2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pad-00')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('add-save')));
    await settle(tester);
    expect(leftText(tester, BudgetCategory.petrol), '₹1,375');
    await unmount(tester);
    await db.close();

    final cardDb = memoryDatabase();
    await seed(cardDb, clock, cardEnabled: true);
    await pumpApp(tester, db: cardDb, clock: clock);
    await tester.tap(find.byKey(const Key('add-food')));
    await settle(tester);
    expect(find.byKey(const Key('method-card')), findsOneWidget);
    await unmount(tester);
    await cardDb.close();
  });

  testWidgets('typing "40 lunch" asks for confirmation before logging to Food', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock);
    await pumpApp(tester, db: db, clock: clock);

    await tester.enterText(find.byKey(const Key('type-to-log')), '40 lunch');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(find.text('₹40 · Food'), findsOneWidget);
    expect(leftText(tester, BudgetCategory.food), '₹6,750');
    await tester.tap(find.byKey(const Key('confirm-save')));
    await settle(tester);
    expect(leftText(tester, BudgetCategory.food), '₹6,710');
    await unmount(tester);
    await db.close();
  });

  testWidgets('Food at zero shows "moved and holding" once, with a replan prompt and undo', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock);
    await pumpApp(tester, db: db, clock: clock);

    await tester.tap(find.byKey(const Key('add-food')));
    await settle(tester);
    for (final key in ['7', '0', '0', '0']) {
      await tester.tap(find.byKey(Key('pad-$key')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('add-save')));
    await settle(tester);

    expect(find.byKey(const Key('refill-summary')), findsOneWidget);
    expect(find.text('Moved ₹1,300 into Food'), findsOneWidget);
    expect(find.text('Holding ₹1,288 for the coming weeks'), findsOneWidget);
    expect(find.text('Food ran out early this cycle'), findsOneWidget);
    expect(leftText(tester, BudgetCategory.food), '₹1,050');

    await tester.tap(find.byKey(const Key('refill-undo')));
    await settle(tester);
    expect(find.byKey(const Key('refill-summary')), findsNothing);
    expect(leftText(tester, BudgetCategory.food), '-₹250');
    await unmount(tester);
    await db.close();
  });

  testWidgets('the summary goes away for good after Got it', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 20, 14));
    await seed(db, clock);
    await pumpApp(tester, db: db, clock: clock);
    await tester.tap(find.byKey(const Key('add-food')));
    await settle(tester);
    for (final key in ['7', '0', '0', '0']) {
      await tester.tap(find.byKey(Key('pad-$key')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('add-save')));
    await settle(tester);
    expect(find.text('Food ran out early this cycle'), findsOneWidget);
    await tester.tap(find.byKey(const Key('refill-ok')));
    await settle(tester);
    expect(find.byKey(const Key('refill-summary')), findsNothing);
    await unmount(tester);

    await pumpApp(tester, db: db, clock: clock);
    expect(find.byKey(const Key('refill-summary')), findsNothing);
    expect(leftText(tester, BudgetCategory.food), isNot('-₹250'));
    await unmount(tester);
    await db.close();
  });

  testWidgets('the app opens locked, unlocks with the device check, and the lock button locks again', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock);
    final authenticator = FakeAuthenticator(AuthOutcome.failed);
    await pumpApp(tester, db: db, clock: clock, authenticator: authenticator);

    expect(find.byKey(const Key('unlock-button')), findsOneWidget);
    expect(find.byKey(const Key('ring-amount')), findsNothing);
    authenticator.outcome = AuthOutcome.success;
    await tester.tap(find.byKey(const Key('unlock-button')));
    await settle(tester);
    expect(find.byKey(const Key('ring-amount')), findsOneWidget);

    authenticator.outcome = AuthOutcome.failed;
    await tester.tap(find.byKey(const Key('lock-button')));
    await settle(tester);
    expect(find.byKey(const Key('ring-amount')), findsNothing);
    expect(find.text('Not unlocked. Try again.'), findsOneWidget);
    await unmount(tester);
    await db.close();
  });

  testWidgets('late-night mode shows night food stock and predicts it', (tester) async {
    final db = memoryDatabase();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    await seed(db, clock);
    clock.now = ist(2026, 3, 11, 1, 30);
    await pumpApp(tester, db: db, clock: clock);

    expect(find.byKey(const Key('late-night')), findsOneWidget);
    expect(find.text('Night food stock has ₹750 left'), findsOneWidget);
    expect(find.text('+40 Night food'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('cycle-line'))).data, 'Day 1 of 26, 26 left');
    await unmount(tester);
    await db.close();
  });

  testWidgets('state survives closing and reopening the app', (tester) async {
    final directory = Directory.systemTemp.createTempSync('fintrack-test');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File('${directory.path}/fintrack.sqlite');
    final clock = FakeClock(ist(2026, 3, 10, 14));

    final first = AppDatabase(NativeDatabase(file));
    await seed(first, clock);
    await pumpApp(tester, db: first, clock: clock);
    await tester.tap(find.byKey(const Key('chip-100')));
    await settle(tester);
    expect(ringText(tester), '₹216');
    await unmount(tester);
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    await pumpApp(tester, db: second, clock: clock);
    expect(ringText(tester), '₹216');
    expect(leftText(tester, BudgetCategory.food), '₹6,650');
    await unmount(tester);
    await second.close();
  });
}
