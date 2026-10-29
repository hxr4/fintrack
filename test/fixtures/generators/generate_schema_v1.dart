import 'dart:io';

import 'package:budget_engine/budget_engine.dart';
import 'package:drift/native.dart';
import 'package:fintrack/app/state.dart';
import 'package:fintrack/data/budget_repository.dart';
import 'package:fintrack/data/database.dart';
import 'package:fintrack/domain/cycle_planning.dart';
import 'package:fintrack/domain/preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  test('write schema v1 fixture', () async {
    final target = File(Platform.environment['FIXTURE_OUT']!);
    if (target.existsSync()) {
      target.deleteSync();
    }
    final db = AppDatabase(NativeDatabase(target));
    final clock = FakeClock(ist(2026, 3, 5, 10));
    await BudgetRepository(db).completeOnboarding(
      input: OnboardingInput(
        deposit: Money.rupees(12000),
        depositDate: CivilDate(2026, 3, 5),
        anchorDay: 5,
        foodFloorPerDay: Money.rupees(150),
        petrolFloorPerCycle: Money.rupees(1200),
        nightFoodStock: Money.rupees(750),
        weights: standardInput(CivilDate(2026, 3, 5)).weights,
        bank: Money.rupees(12000),
        cash: Money.rupees(300),
        excluded: Money.rupees(300),
        recurring: [RecurringDraft(name: 'Music', amount: Money.rupees(119), everyMonths: 1)],
        supplies: [SupplyDraft(name: 'Soap', price: Money.rupees(90), lifespanDays: 45, lastRestock: CivilDate(2026, 2, 20))],
        cardEnabled: true,
      ),
      now: clock.now,
      preferences: const AppPreferences(),
    );
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(clock.call),
      authenticatorProvider.overrideWithValue(FakeAuthenticator()),
      secureWindowProvider.overrideWithValue(FakeSecureWindow()),
    ]);
    await container.read(budgetProvider.future);
    final controller = container.read(budgetProvider.notifier);
    clock.now = ist(2026, 3, 6, 13);
    await controller.log(
      amount: Money.rupees(80),
      category: BudgetCategory.food,
      method: PaymentMethod.upi,
      source: TransactionSource.typed,
      note: 'chai',
      learnKeyword: 'chai',
    );
    clock.now = ist(2026, 3, 7, 21);
    await controller.log(
      amount: Money.rupees(7000),
      category: BudgetCategory.food,
      method: PaymentMethod.card,
      source: TransactionSource.manual,
    );
    clock.now = ist(2026, 3, 8, 12);
    await controller.logDeposit(amount: Money.rupees(1000), date: CivilDate(2026, 3, 8), kind: DepositKind.extra);
    container.dispose();
    await db.close();
  });
}
