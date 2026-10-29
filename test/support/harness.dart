import 'dart:io';

import 'package:budget_engine/budget_engine.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fintrack/app/app.dart';
import 'package:fintrack/app/profile_state.dart';
import 'package:fintrack/app/state.dart';
import 'package:fintrack/data/budget_repository.dart';
import 'package:fintrack/data/database.dart';
import 'package:fintrack/domain/cycle_planning.dart';
import 'package:fintrack/domain/preferences.dart';
import 'package:fintrack/platform/authenticator.dart';
import 'package:fintrack/platform/file_bridge.dart';
import 'package:fintrack/platform/photo_picker.dart';
import 'package:fintrack/platform/secure_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class FakeClock {
  FakeClock(this.now);

  DateTime now;

  DateTime call() => now;
}

final class FakeAuthenticator implements Authenticator {
  FakeAuthenticator([this.outcome = AuthOutcome.success]);

  AuthOutcome outcome;
  var calls = 0;

  @override
  Future<AuthOutcome> authenticate(String reason) async {
    calls += 1;
    return outcome;
  }
}

final class FakeFileBridge implements FileBridge {
  final saved = <String, Uint8List>{};
  Uint8List? toPick;
  var shared = 0;

  @override
  Future<Uint8List?> pickFile() async => toPick;

  @override
  Future<String?> saveToDownloads(String name, Uint8List bytes) async {
    saved[name] = bytes;
    return 'Download/$name';
  }

  @override
  Future<void> share(String name, Uint8List bytes) async => shared += 1;
}

final class FakePhotoPicker implements PhotoPicker {
  FakePhotoPicker([this.bytes]);

  Uint8List? bytes;

  @override
  Future<Uint8List?> pick(PhotoSource source) async => bytes;
}

final class FakeSecureWindow implements SecureWindow {
  bool? secure;

  @override
  Future<void> setSecure(bool secure) async => this.secure = secure;
}

DateTime ist(int year, int month, int day, int hour, [int minute = 0, int second = 0]) =>
    KolkataTime.at(CivilDate(year, month, day), hour, minute).add(Duration(seconds: second));

AppDatabase memoryDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

OnboardingInput standardInput(
  CivilDate depositDate, {
  bool cardEnabled = false,
  int deposit = 12000,
  List<SupplyDraft> supplies = const [],
  List<RecurringDraft> recurring = const [],
  int leftover = 0,
}) =>
    OnboardingInput(
      deposit: Money.rupees(deposit),
      depositDate: depositDate,
      anchorDay: 5,
      foodFloorPerDay: Money.rupees(150),
      petrolFloorPerCycle: Money.rupees(1200),
      nightFoodStock: Money.rupees(750),
      weights: CategoryWeights.fromPercent({
        BudgetCategory.food: 60,
        BudgetCategory.petrol: 14,
        BudgetCategory.outings: 9,
        BudgetCategory.trySomethingNew: 4,
        BudgetCategory.misc: 3,
        BudgetCategory.buffer: 10,
      }),
      bank: Money.rupees(deposit + leftover),
      cash: Money.zero,
      excluded: Money.zero,
      leftover: Money.rupees(leftover),
      recurring: recurring,
      supplies: supplies,
      cardEnabled: cardEnabled,
    );

Future<void> seed(
  AppDatabase db,
  FakeClock clock, {
  bool cardEnabled = false,
  List<SupplyDraft> supplies = const [],
  List<RecurringDraft> recurring = const [],
}) =>
    BudgetRepository(db).completeOnboarding(
      input: standardInput(KolkataTime.dateOf(clock.now), cardEnabled: cardEnabled, supplies: supplies, recurring: recurring),
      now: clock.now,
      preferences: const AppPreferences(),
    );

Future<void> pumpApp(
  WidgetTester tester, {
  required AppDatabase db,
  required FakeClock clock,
  FakeAuthenticator? authenticator,
  FakeFileBridge? files,
  Directory? scratch,
  FakePhotoPicker? photos,
}) async {
  await tester.binding.setSurfaceSize(const Size(420, 1600));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(clock.call),
      authenticatorProvider.overrideWithValue(authenticator ?? FakeAuthenticator()),
      secureWindowProvider.overrideWithValue(FakeSecureWindow()),
      fileBridgeProvider.overrideWithValue(files ?? FakeFileBridge()),
      scratchDirectoryProvider.overrideWithValue(Future.value(scratch ?? Directory.systemTemp)),
      backupIterationsProvider.overrideWithValue(1000),
      photoPickerProvider.overrideWithValue(photos ?? FakePhotoPicker()),
    ],
    child: const FintrackApp(),
  ));
  await settle(tester);
}

Future<void> settle(WidgetTester tester, {int frames = 30}) async {
  for (var frame = 0; frame < frames; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await settle(tester, frames: 5);
}

String ringText(WidgetTester tester) =>
    tester.widget<Text>(find.descendant(of: find.byKey(const Key('ring-amount')), matching: find.byType(Text))).data!;

String leftText(WidgetTester tester, BudgetCategory category) => tester
    .widget<Text>(find.descendant(of: find.byKey(Key('left-${category.name}')), matching: find.byType(Text)))
    .data!;

Future<ProviderContainer> startContainer(AppDatabase db, FakeClock clock) async {
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    clockProvider.overrideWithValue(clock.call),
    authenticatorProvider.overrideWithValue(FakeAuthenticator()),
    secureWindowProvider.overrideWithValue(FakeSecureWindow()),
  ]);
  await container.read(budgetProvider.future);
  return container;
}

Future<void> settleReal(WidgetTester tester, bool Function() done, {int attempts = 100}) async {
  for (var attempt = 0; attempt < attempts && !done(); attempt++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await settle(tester, frames: 10);
}

final tinyPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0,
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
  0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);
