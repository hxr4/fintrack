import 'dart:math';

import 'package:budget_engine/budget_engine.dart';

import '../domain/cycle_planning.dart';
import '../domain/preferences.dart';
import 'budget_repository.dart';
import 'ledger_actions.dart';

final class DemoSeeder {
  DemoSeeder(this.repository, {int seed = 7}) : _random = Random(seed);

  final BudgetRepository repository;
  final Random _random;

  Future<void> seed({required DateTime now}) async {
    final today = KolkataTime.dateOf(now);
    final firstStart = CivilDate.clamped(today.year, today.month - 3, 5);
    final secondStart = CivilDate.clamped(today.year, today.month - 2, 5);
    final thirdStart = CivilDate.clamped(today.year, today.month - 1, 8);
    await repository.completeOnboarding(
      input: OnboardingInput(
        deposit: Money.rupees(11000),
        depositDate: firstStart,
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
        bank: Money.rupees(11000),
        cash: Money.zero,
        excluded: Money.zero,
        recurring: [RecurringDraft(name: 'Music subscription', amount: Money.rupees(119), everyMonths: 1)],
        supplies: [
          SupplyDraft(name: 'Soap', price: Money.rupees(90), lifespanDays: 40, lastRestock: firstStart.addDays(-20)),
          SupplyDraft(name: 'Shampoo', price: Money.rupees(180), lifespanDays: 60, lastRestock: firstStart.addDays(-10)),
        ],
        cardEnabled: false,
      ),
      now: KolkataTime.at(firstStart, 12),
      preferences: const AppPreferences(),
    );
    final settings = (await repository.loadBudgetSettings())!;
    final actions = LedgerActions(repository);
    var ledger = (await repository.loadLedger())!;
    final deposits = {secondStart: Money.rupees(12000), thirdStart: Money.rupees(13000)};
    var odometer = 18000;
    ledger = await actions.saveBike(
      ledger,
      ledger.bike.withService(BikeServicePlan(
        intervalKm: 3000,
        intervalMonths: 4,
        cost: Money.rupees(1500),
        lastServiceDate: firstStart.addDays(-30),
        lastServiceKm: 17200,
      )),
    );
    for (var day = firstStart; day.isBefore(today); day = day.addDays(1)) {
      final deposit = deposits[day];
      if (deposit != null) {
        ledger = await actions.logDeposit(
          ledger,
          settings,
          KolkataTime.at(day, 11),
          amount: deposit,
          date: day,
          kind: DepositKind.installment,
        );
      }
      ledger = await actions.releaseWeeklyHolds(ledger, settings, KolkataTime.at(day, 5));
      odometer += 20 + _random.nextInt(25);
      if (day.day % 4 == 0) {
        final fuel = await actions.logFuel(
          ledger,
          settings,
          KolkataTime.at(day, 18),
          amount: Money.rupees(250 + _random.nextInt(150)),
          pricePerLitre: Money(10450),
          odometerKm: odometer,
          fullTank: _random.nextInt(3) != 0,
          method: PaymentMethod.upi,
        );
        ledger = fuel.ledger;
      }
      for (final (category, rupees, hour) in _spending()) {
        final outcome = await actions.log(
          ledger,
          settings,
          KolkataTime.at(day, hour),
          amount: Money.rupees(rupees),
          category: category,
          method: _random.nextInt(3) == 0 ? PaymentMethod.cash : PaymentMethod.upi,
          source: TransactionSource.manual,
        );
        ledger = outcome.ledger;
        final batch = outcome.batch;
        if (batch != null) {
          ledger = await actions.markSummarySeen(ledger, batch.id);
        }
      }
    }
  }

  List<(BudgetCategory, int, int)> _spending() => [
        for (var meal = 0; meal < 1 + _random.nextInt(3); meal++)
          (BudgetCategory.food, 30 + _random.nextInt(120), 9 + _random.nextInt(12)),
        if (_random.nextInt(10) == 0) (BudgetCategory.outings, 250 + _random.nextInt(350), 20),
        if (_random.nextInt(20) == 0) (BudgetCategory.trySomethingNew, 100 + _random.nextInt(200), 19),
        if (_random.nextInt(25) == 0) (BudgetCategory.misc, 100 + _random.nextInt(150), 12),
        if (_random.nextInt(8) == 0) (BudgetCategory.nightFoodStock, 40 + _random.nextInt(80), 23),
      ];
}
