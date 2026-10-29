import 'package:budget_engine/budget_engine.dart';
import 'package:fintrack/app/state.dart';
import 'package:fintrack/data/budget_repository.dart';
import 'package:fintrack/data/demo_seeder.dart';
import 'package:fintrack/domain/cycle_planning.dart';
import 'package:fintrack/domain/ledger_data.dart';
import 'package:fintrack/domain/preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  late FakeClock clock;

  Future<ProviderContainer> start({List<SupplyDraft> supplies = const [], List<RecurringDraft> recurring = const []}) async {
    final db = memoryDatabase();
    clock = FakeClock(ist(2026, 3, 5, 10));
    await seed(db, clock, supplies: supplies, recurring: recurring);
    final container = await startContainer(db, clock);
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    return container;
  }

  AppState read(ProviderContainer container) => container.read(budgetProvider).requireValue;
  BudgetController controller(ProviderContainer container) => container.read(budgetProvider.notifier);

  group('supplies', () {
    final soap = SupplyDraft(name: 'Soap', price: Money.rupees(90), lifespanDays: 45, lastRestock: CivilDate(2026, 2, 20));

    test('onboarding sets money aside per item and marks the date as a guess', () async {
      final container = await start(supplies: [soap]);
      final supply = read(container).ledger!.supplies.single;
      expect(supply.state.saved, Money(8719));
      expect(supply.state.lastRestockEstimated, isTrue);
      expect(read(container).ledger!.planAllocations[BudgetCategory.essentialsStock], Money(8719));
    });

    test('a restock logs an Essentials stock spend, uses the savings and resets the clock', () async {
      final container = await start(supplies: [soap]);
      clock.now = ist(2026, 3, 30, 18);
      final id = read(container).ledger!.supplies.single.state.id;
      await controller(container).restock(supplyId: id, paid: Money.rupees(95), method: PaymentMethod.upi);
      final ledger = read(container).ledger!;
      final supply = ledger.supplies.single;
      expect(supply.state.lastRestock, CivilDate(2026, 3, 30));
      expect(supply.state.saved, Money.zero);
      expect(supply.state.price, Money.rupees(95));
      expect(supply.state.lifespanDays, 45);
      expect(ledger.transactions.last.category, BudgetCategory.essentialsStock);
      expect(ledger.transactions.last.note, 'Soap');
      expect(ledger.balances[BudgetCategory.essentialsStock], Money.zero);
      expect(ledger.batches.where((batch) => batch.kind == BatchKind.fundCover), hasLength(1));
    });

    test('items can be added, edited and removed', () async {
      final container = await start();
      await controller(container).upsertSupply(NamedSupply(
        name: 'Toothpaste',
        state: SupplyItemState(id: 's1', price: Money.rupees(60), lifespanDays: 30, lastRestock: CivilDate(2026, 3, 1)),
      ));
      expect(read(container).ledger!.supplies.single.name, 'Toothpaste');
      await controller(container).deleteSupply('s1');
      expect(read(container).ledger!.supplies, isEmpty);
    });
  });

  group('fuel and bike', () {
    test('a fuel fill logs a Petrol spend and the fill, and deleting the spend removes the fill', () async {
      final container = await start();
      clock.now = ist(2026, 3, 6, 18);
      final outcome = await controller(container).logFuel(
        amount: Money.rupees(300),
        pricePerLitre: Money(10000),
        odometerKm: 12000,
        fullTank: true,
        method: PaymentMethod.upi,
      );
      var ledger = read(container).ledger!;
      expect(ledger.fuelFills.single.fill.litresMl, 3000);
      expect(ledger.transactions.last.category, BudgetCategory.petrol);
      final entry = await controller(container).deleteTransaction(outcome.transaction);
      expect(read(container).ledger!.fuelFills, isEmpty);
      await controller(container).restore(entry);
      ledger = read(container).ledger!;
      expect(ledger.fuelFills, hasLength(1));
      expect(ledger.transactions.where((transaction) => transaction.id == outcome.transaction.id), hasLength(1));
    });

    test('two full fills give mileage', () async {
      final container = await start();
      clock.now = ist(2026, 3, 6, 18);
      await controller(container).logFuel(
        amount: Money.rupees(300),
        pricePerLitre: Money(10000),
        odometerKm: 12000,
        fullTank: true,
        method: PaymentMethod.upi,
      );
      clock.now = ist(2026, 3, 12, 18);
      await controller(container).logFuel(
        amount: Money.rupees(400),
        pricePerLitre: Money(10000),
        odometerKm: 12200,
        fullTank: true,
        method: PaymentMethod.upi,
      );
      final summary = read(container).ledger!.fuelSummary(CivilDate(2026, 3, 12));
      expect(summary.averageKmPerLitreTenths, 500);
    });

    test('recording a service spends from Bike fund, covers the rest from Buffer and resets the schedule', () async {
      final container = await start();
      final ledger = read(container).ledger!;
      await controller(container).saveBike(ledger.bike.withService(BikeServicePlan(
        intervalKm: 3000,
        cost: Money.rupees(1500),
        lastServiceKm: 9000,
        lastServiceDate: CivilDate(2026, 1, 1),
      )));
      final bufferBefore = read(container).ledger!.balances[BudgetCategory.buffer]!;
      clock.now = ist(2026, 3, 20, 11);
      await controller(container).payService(amount: Money.rupees(1000), odometerKm: 12100, method: PaymentMethod.cash);
      final after = read(container).ledger!;
      expect(after.bike.service.lastServiceKm, 12100);
      expect(after.bike.service.lastServiceDate, CivilDate(2026, 3, 20));
      expect(after.balances[BudgetCategory.bikeFund], Money.zero);
      expect(after.balances[BudgetCategory.buffer], bufferBefore - Money.rupees(1000));
    });

    test('the next cycle sets money aside for the service', () async {
      final container = await start();
      await controller(container).saveBike(read(container).ledger!.bike.withService(BikeServicePlan(
        intervalMonths: 3,
        cost: Money.rupees(1500),
        lastServiceDate: CivilDate(2026, 2, 1),
      )));
      clock.now = ist(2026, 4, 5, 10);
      await controller(container).logDeposit(amount: Money.rupees(12000), date: CivilDate(2026, 4, 5), kind: DepositKind.installment);
      final plan = read(container).ledger!.planAllocations;
      expect(plan[BudgetCategory.bikeFund], Money.rupees(1500));
    });
  });

  group('recurring costs', () {
    test('each cycle sets aside its share, and paying it spends from Recurring fund', () async {
      final container = await start(
        recurring: [RecurringDraft(name: 'Music', amount: Money.rupees(119), everyMonths: 1)],
      );
      final ledger = read(container).ledger!;
      expect(ledger.planAllocations[BudgetCategory.recurringFund], Money.rupees(119));
      await controller(container).payRecurring(
        costId: ledger.recurring.single.state.id,
        amount: Money.rupees(119),
        method: PaymentMethod.upi,
      );
      expect(read(container).ledger!.balances[BudgetCategory.recurringFund], Money.zero);
    });
  });

  group('balance check', () {
    ReportedBalance reported(int bank, {int cash = 0}) =>
        ReportedBalance(at: clock.now, bank: Money.rupees(bank), cash: Money.rupees(cash));

    test('lower than expected is logged as unlogged and taken from flexible money', () async {
      final container = await start();
      clock.now = ist(2026, 3, 10, 20);
      await controller(container).log(
        amount: Money.rupees(500),
        category: BudgetCategory.food,
        method: PaymentMethod.upi,
        source: TransactionSource.manual,
      );
      final comparison = await controller(container).previewBalance(reported(11300));
      expect(comparison!.expected, Money.rupees(11500));
      expect(comparison.difference, Money.rupees(-200));
      final outcome = await controller(container).applyBalanceCheck(
        reported: reported(11300),
        resolution: BalanceResolution.unlogged,
      );
      final ledger = read(container).ledger!;
      expect(outcome.uncovered, Money.zero);
      expect(ledger.balances[BudgetCategory.unlogged], Money.zero);
      expect(Ledger.total(ledger.balances), Money.rupees(11300));
      expect(ledger.latestAnchor!.bank, Money.rupees(11300));
      final again = await controller(container).previewBalance(reported(11300));
      expect(again!.matches, isTrue);
    });

    test('spreading puts corrections in the categories spent in', () async {
      final container = await start();
      clock.now = ist(2026, 3, 10, 20);
      await controller(container).log(
        amount: Money.rupees(500),
        category: BudgetCategory.food,
        method: PaymentMethod.upi,
        source: TransactionSource.manual,
      );
      await controller(container).applyBalanceCheck(reported: reported(11400), resolution: BalanceResolution.distribute);
      final corrections = read(container).ledger!.transactions.where((transaction) => transaction.isCorrection).toList();
      expect(corrections.single.category, BudgetCategory.food);
      expect(corrections.single.amount, Money.rupees(100));
    });

    test('higher than expected goes to Buffer', () async {
      final container = await start();
      final buffer = read(container).ledger!.balances[BudgetCategory.buffer]!;
      clock.now = ist(2026, 3, 10, 20);
      await controller(container).applyBalanceCheck(reported: reported(12300), resolution: BalanceResolution.unlogged);
      expect(read(container).ledger!.balances[BudgetCategory.buffer], buffer + Money.rupees(300));
    });

    test('leaving it as it is changes nothing', () async {
      final container = await start();
      final before = read(container).ledger!;
      clock.now = ist(2026, 3, 10, 20);
      await controller(container).applyBalanceCheck(reported: reported(11000), resolution: BalanceResolution.ignore);
      final after = read(container).ledger!;
      expect(after.balances, before.balances);
      expect(after.latestAnchor!.at, before.latestAnchor!.at);
    });

    test('excluded money is not counted', () async {
      final container = await start();
      clock.now = ist(2026, 3, 10, 20);
      final comparison = await controller(container).previewBalance(
        ReportedBalance(at: clock.now, bank: Money.rupees(20000), cash: Money.zero, excluded: Money.rupees(8000)),
      );
      expect(comparison!.matches, isTrue);
    });
  });

  group('budget values', () {
    test('floors apply now, the deposit day moves the expected end, the split waits for the next cycle', () async {
      final container = await start();
      final settings = read(container).settings!;
      clock.now = ist(2026, 3, 10, 12);
      await controller(container).updateBudgetValues(settings.copyWith(
        petrolFloorPerCycle: Money.rupees(1500),
        foodFloorPerDay: Money.rupees(180),
        anchorDay: 7,
        defaultWeights: CategoryWeights.fromPercent({
          BudgetCategory.food: 62,
          BudgetCategory.petrol: 12,
          BudgetCategory.outings: 9,
          BudgetCategory.trySomethingNew: 4,
          BudgetCategory.misc: 3,
          BudgetCategory.buffer: 10,
        }),
      ));
      final state = read(container);
      expect(state.settings!.foodFloorPerDay, Money.rupees(180));
      expect(state.ledger!.cycle.window.nextStart, CivilDate(2026, 4, 7));
      expect(state.ledger!.cycle.petrolFloor, Money.rupees(1650));
      expect(state.ledger!.cycle.weights[BudgetCategory.food], 6000);
      final reloaded = await BudgetRepository(container.read(databaseProvider)).loadBudgetSettings();
      expect(reloaded!.defaultWeights[BudgetCategory.food], 6200);
    });
  });

  group('first balance check right after onboarding (F42)', () {
    for (final hour in [9, 15]) {
      for (final leftover in [0, 2000]) {
        test('onboarding at $hour:00 with ₹$leftover already in hand agrees with the first check', () async {
          final db = memoryDatabase();
          clock = FakeClock(ist(2026, 3, 10, hour));
          await BudgetRepository(db).completeOnboarding(
            input: standardInput(CivilDate(2026, 3, 10), leftover: leftover),
            now: clock.now,
            preferences: const AppPreferences(),
          );
          final container = await startContainer(db, clock);
          addTearDown(() async {
            container.dispose();
            await db.close();
          });
          final ledger = read(container).ledger!;
          final total = Money.rupees(12000 + leftover);
          expect(ledger.cycle.carryIn, Money.rupees(leftover));
          expect(Ledger.total(ledger.balances), total);
          expect(ledger.latestAnchor!.anchor.total, total);

          clock.now = clock.now.add(const Duration(minutes: 5));
          final first = await controller(container).previewBalance(
            ReportedBalance(at: clock.now, bank: total, cash: Money.zero),
          );
          expect(first!.matches, isTrue);

          clock.now = clock.now.add(const Duration(hours: 2));
          await controller(container).log(
            amount: Money.rupees(150),
            category: BudgetCategory.food,
            method: PaymentMethod.cash,
            source: TransactionSource.manual,
          );
          final afterSpend = await controller(container).previewBalance(
            ReportedBalance(at: clock.now, bank: total - Money.rupees(150), cash: Money.zero),
          );
          expect(afterSpend!.matches, isTrue);
          expect(Ledger.total(read(container).ledger!.balances), total - Money.rupees(150));
        });
      }
    }

    test('onboarding numbers that do not add up are reported as a gap', () {
      final input = standardInput(CivilDate(2026, 3, 10), leftover: 500);
      expect(input.balancesGap, Money.zero);
      final mismatched = OnboardingInput(
        deposit: input.deposit,
        depositDate: input.depositDate,
        anchorDay: input.anchorDay,
        foodFloorPerDay: input.foodFloorPerDay,
        petrolFloorPerCycle: input.petrolFloorPerCycle,
        nightFoodStock: input.nightFoodStock,
        weights: input.weights,
        bank: Money.rupees(11000),
        cash: Money.zero,
        excluded: Money.zero,
        leftover: Money.zero,
        recurring: const [],
        supplies: const [],
        cardEnabled: false,
      );
      expect(mismatched.balancesGap, Money.rupees(-1000));
    });
  });

  test('the demo seeder builds three months that load cleanly', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final now = ist(2026, 6, 20, 10);
    await DemoSeeder(BudgetRepository(db)).seed(now: now);
    final repository = BudgetRepository(db);
    final ledger = (await repository.loadLedger())!;
    final history = await repository.loadHistory(includingCycleId: ledger.cycle.id);
    expect(history.installmentTotals, [Money.rupees(11000), Money.rupees(12000), Money.rupees(13000)]);
    expect(ledger.cycle.window.start, CivilDate(2026, 5, 8));
    expect(ledger.transactions, isNotEmpty);
    expect(ledger.fuelFills, isNotEmpty);
    expect(ledger.allocations.values.every((amount) => !amount.isNegative), isTrue);
    expect((await repository.loadPreferences()).onboarded, isTrue);
  });
}
