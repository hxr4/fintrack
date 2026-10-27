import 'package:budget_engine/budget_engine.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fintrack/app/app.dart';
import 'package:fintrack/app/state.dart';
import 'package:fintrack/data/budget_repository.dart';
import 'package:fintrack/data/database.dart';
import 'package:fintrack/domain/cycle_planning.dart';
import 'package:fintrack/domain/preferences.dart';
import 'package:fintrack/platform/authenticator.dart';
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

final class FakeSecureWindow implements SecureWindow {
  bool? secure;

  @override
  Future<void> setSecure(bool secure) async => this.secure = secure;
}

DateTime ist(int year, int month, int day, int hour, [int minute = 0]) =>
    KolkataTime.at(CivilDate(year, month, day), hour, minute);

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
      bank: Money.rupees(12000),
      cash: Money.zero,
      excluded: Money.zero,
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
}) async {
  await tester.binding.setSurfaceSize(const Size(420, 1600));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(clock.call),
      authenticatorProvider.overrideWithValue(authenticator ?? FakeAuthenticator()),
      secureWindowProvider.overrideWithValue(FakeSecureWindow()),
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
