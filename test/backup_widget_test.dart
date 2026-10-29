import 'dart:io';

import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  testWidgets('create a backup, then restore it on a clean install from onboarding', (tester) async {
    final scratch = Directory.systemTemp.createTempSync('fintrack-ui-backup');
    addTearDown(() => scratch.deleteSync(recursive: true));
    final files = FakeFileBridge();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    final original = memoryDatabase();
    await seed(original, clock);
    await pumpApp(tester, db: original, clock: clock, files: files, scratch: scratch);
    await tester.tap(find.byKey(const Key('chip-100')));
    await settle(tester);
    final ring = ringText(tester);
    final food = leftText(tester, BudgetCategory.food);

    await tester.tap(find.byKey(const Key('open-profile')));
    await settle(tester);
    await tester.ensureVisible(find.byKey(const Key('open-settings')));
    await tester.tap(find.byKey(const Key('open-settings')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('open-backup')));
    await settle(tester);
    expect(find.byKey(const Key('backup-warning')), findsOneWidget);
    expect(find.text('No backup yet'), findsOneWidget);
    await tester.tap(find.byKey(const Key('create-backup')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('passphrase')), 'my long passphrase');
    await tester.enterText(find.byKey(const Key('passphrase-again')), 'my long passphrase');
    await tester.tap(find.byKey(const Key('passphrase-ok')));
    await settleReal(tester, () => files.saved.isNotEmpty);
    expect(files.saved, hasLength(1));
    expect(find.textContaining('Saved to Download/fintrack-backup-2026-03-10-1400.ftbackup'), findsOneWidget);
    expect(find.text('Last backup: 10 Mar'), findsOneWidget);
    await unmount(tester);
    await original.close();

    final fresh = memoryDatabase();
    files.toPick = files.saved.values.single;
    await pumpApp(tester, db: fresh, clock: clock, files: files, scratch: scratch);
    await tester.tap(find.byKey(const Key('onboarding-restore')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('passphrase')), 'my long passphrase');
    await tester.tap(find.byKey(const Key('passphrase-ok')));
    await settleReal(tester, () => find.byKey(const Key('ring-amount')).evaluate().isNotEmpty);
    expect(ringText(tester), ring);
    expect(leftText(tester, BudgetCategory.food), food);
    await unmount(tester);
    await fresh.close();
  });

  testWidgets('a wrong passphrase on restore says so and stays on onboarding', (tester) async {
    final scratch = Directory.systemTemp.createTempSync('fintrack-ui-backup');
    addTearDown(() => scratch.deleteSync(recursive: true));
    final files = FakeFileBridge();
    final clock = FakeClock(ist(2026, 3, 10, 14));
    final original = memoryDatabase();
    await seed(original, clock);
    await pumpApp(tester, db: original, clock: clock, files: files, scratch: scratch);
    await tester.tap(find.byKey(const Key('open-profile')));
    await settle(tester);
    await tester.ensureVisible(find.byKey(const Key('open-settings')));
    await tester.tap(find.byKey(const Key('open-settings')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('open-backup')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('create-backup')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('passphrase')), 'my long passphrase');
    await tester.enterText(find.byKey(const Key('passphrase-again')), 'my long passphrase');
    await tester.tap(find.byKey(const Key('passphrase-ok')));
    await settleReal(tester, () => files.saved.isNotEmpty);
    await unmount(tester);
    await original.close();

    final fresh = memoryDatabase();
    files.toPick = files.saved.values.single;
    await pumpApp(tester, db: fresh, clock: clock, files: files, scratch: scratch);
    await tester.tap(find.byKey(const Key('onboarding-restore')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('passphrase')), 'not the passphrase');
    await tester.tap(find.byKey(const Key('passphrase-ok')));
    await settleReal(tester, () => find.text('The passphrase is wrong, or the file has been changed.').evaluate().isNotEmpty);
    expect(find.text('The passphrase is wrong, or the file has been changed.'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-restore')), findsOneWidget);
    await unmount(tester);
    await fresh.close();
  });
}
