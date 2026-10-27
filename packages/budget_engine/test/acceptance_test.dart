import 'dart:math';

import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

final class SimulatedCycle {
  SimulatedCycle({
    required this.plan,
    required this.actualWindow,
    required this.opening,
    required this.transactions,
    required this.adjustments,
    required this.closing,
    required this.awaitingDays,
  });

  final CyclePlan plan;
  final CycleWindow actualWindow;
  final Map<BudgetCategory, Money> opening;
  final List<Transaction> transactions;
  final List<Adjustment> adjustments;
  final Map<BudgetCategory, Money> closing;
  final int awaitingDays;
}

List<(BudgetCategory, int, int)> dailySpending(Random random) => [
      for (var meal = 0; meal < 1 + random.nextInt(3); meal++) (BudgetCategory.food, 30 + random.nextInt(140), 9 + random.nextInt(13)),
      if (random.nextInt(4) == 0) (BudgetCategory.petrol, 150 + random.nextInt(200), 18),
      if (random.nextInt(10) == 0) (BudgetCategory.outings, 300 + random.nextInt(400), 20),
      if (random.nextInt(20) == 0) (BudgetCategory.trySomethingNew, 120 + random.nextInt(200), 19),
      if (random.nextInt(30) == 0) (BudgetCategory.misc, 100 + random.nextInt(200), 12),
      if (random.nextInt(7) == 0) (BudgetCategory.nightFoodStock, 50 + random.nextInt(100), 25),
    ];

List<SimulatedCycle> simulate(int seed) {
  final random = Random(seed);
  final settings = standardSettings();
  final deposits = [(11000, '2026-01-05'), (12000, '2026-02-05'), (13000, '2026-03-09')];
  final history = <Money>[];
  final completedSpends = <Map<BudgetCategory, Money>>[];
  var opening = BudgetCategory.filled(Money.zero);
  var carry = Money.zero;
  CategoryWeights? previousWeights;
  final cycles = <SimulatedCycle>[];
  var batch = 0;

  for (var index = 0; index < deposits.length; index++) {
    final (rupees, date) = deposits[index];
    final start = d(date);
    final planned = CycleCalendar.windowStartingOn(start, anchorDay: settings.anchorDay, policy: policy);
    final actualNextStart = index + 1 < deposits.length ? d(deposits[index + 1].$2) : planned.nextStart;
    final actualWindow = CycleWindow(start: start, nextStart: actualNextStart);
    final plan = AllocationPlanner.plan(PlanInput(
      window: planned,
      cycleDeposits: [installment(rupees, date)],
      settings: settings,
      carryInToPool: carry,
      previousInstallmentTotals: List.of(history),
      completedCycleSpends: List.of(completedSpends),
      previousWeights: previousWeights,
      reserves: ReserveInputs(nightFoodCarried: opening[BudgetCategory.nightFoodStock]!),
    ));

    expect(plan.total, (Money.rupees(rupees) + carry).positivePart);
    expect(Ledger.total(opening) + plan.total, Ledger.total(opening) + Money.rupees(rupees) + carry);
    expect(plan.allocations.values.every((amount) => !amount.isNegative), isTrue);
    expect(plan.hasShortfall, isFalse);
    expect(plan.allocations[BudgetCategory.food]! >= plan.foodFloor, isTrue);
    expect(plan.allocations[BudgetCategory.petrol]! >= plan.petrolFloor, isTrue);
    expect(
      opening[BudgetCategory.nightFoodStock]! + plan.allocations[BudgetCategory.nightFoodStock]!,
      settings.nightFoodStockTarget,
    );

    final transactions = <Transaction>[];
    final adjustments = <Adjustment>[];
    var awaitingDays = 0;
    for (var day = start; day < actualNextStart; day = day.addDays(1)) {
      final awaiting = CycleCalendar.isAwaitingDeposit(planned, day);
      if (awaiting) {
        awaitingDays += 1;
      }
      final daysLeft = awaiting
          ? CycleCalendar.awaitingPlanDays(expectedStart: planned.nextStart, today: day, policy: policy)
          : planned.daysLeftIncluding(day);
      final startOfDay = Ledger.balances(
        opening: opening,
        allocations: plan.allocations,
        transactions: transactions,
        adjustments: adjustments,
      );
      final allowance = DailyAllowanceCalculator.compute(
        poolAtStartOfDay: Ledger.pool(startOfDay),
        spentToday: Money.zero,
        daysLeft: daysLeft,
        baseDaily: plan.baseDaily,
      );
      expect(allowance.allowance.isNegative, isFalse);

      for (final (category, amount, hour) in dailySpending(random)) {
        final at = KolkataTime.at(day, hour);
        expect(KolkataTime.allowanceDateOf(at, boundaryHour: settings.dayBoundaryHour), day);
        transactions.add(spend(amount, category, at));
        final before = Ledger.balances(
          opening: opening,
          allocations: plan.allocations,
          transactions: transactions,
          adjustments: adjustments,
        );
        final result = AutoAdjuster.run(
          balances: before,
          foodFloorPerDay: settings.foodFloorPerDay,
          petrolFloorForCycle: plan.petrolFloor,
          cycleLength: planned.length,
          daysLeft: daysLeft,
        );
        if (result.moved) {
          adjustments.addAll(persist(result.moves, 'batch-${batch++}', at));
        }
        final after = Ledger.balances(
          opening: opening,
          allocations: plan.allocations,
          transactions: transactions,
          adjustments: adjustments,
        );
        expect(
          Ledger.total(after),
          Ledger.total(opening) + plan.total - Money.sum(transactions.map((transaction) => transaction.amount)),
        );
        for (final essential in BudgetCategory.essentials) {
          if (!before[essential]!.isPositive && !result.uncovered.containsKey(essential)) {
            expect(after[essential]!.isNegative, isFalse, reason: '$essential on $day');
          }
        }
        for (final donor in [BudgetCategory.buffer, BudgetCategory.trySomethingNew, BudgetCategory.outings]) {
          if (!before[donor]!.isNegative) {
            expect(after[donor]!.isNegative, isFalse, reason: '$donor on $day');
          }
        }
      }
    }

    final closing = Ledger.balances(
      opening: opening,
      allocations: plan.allocations,
      transactions: transactions,
      adjustments: adjustments,
    );
    cycles.add(SimulatedCycle(
      plan: plan,
      actualWindow: actualWindow,
      opening: opening,
      transactions: transactions,
      adjustments: adjustments,
      closing: closing,
      awaitingDays: awaitingDays,
    ));

    final carryForward = CycleCloser.close(
      closingBalances: closing,
      nightFoodTarget: settings.nightFoodStockTarget,
      essentialsTarget: Money.zero,
      bufferAllocation: plan.allocations[BudgetCategory.buffer]!,
    );
    expect(carryForward.total, Ledger.total(closing));
    expect(carryForward.openingBalances.values.every((amount) => !amount.isNegative), isTrue);

    history.add(plan.installments);
    completedSpends.add({
      for (final category in BudgetCategory.blended)
        category: Money.sum(transactions.where((transaction) => transaction.category == category).map((transaction) => transaction.amount)),
    });
    previousWeights = plan.weights;
    opening = Map.of(carryForward.openingBalances);
    carry = carryForward.carryInToPool;
  }
  return cycles;
}

void main() {
  test('deposits of 11,000, 12,000 and 13,000 in sequence, the last one late', () {
    final cycles = simulate(1);
    expect(cycles.map((cycle) => cycle.plan.delta), [Money.zero, Money.rupees(1000), Money.rupees(1500)]);
    expect(cycles.map((cycle) => cycle.plan.window.length), [31, 28, 27]);
    expect(cycles[1].actualWindow.nextStart, d('2026-03-09'));
    expect(cycles[1].awaitingDays, 4);
    expect(cycles[2].plan.window, CycleWindow(start: d('2026-03-09'), nextStart: d('2026-04-05')));
  });

  test('invariants hold across many simulated quarters', () {
    var refills = 0;
    for (var seed = 0; seed < 60; seed++) {
      final cycles = simulate(seed);
      refills += cycles.fold(0, (sum, cycle) => sum + cycle.adjustments.length);
    }
    expect(refills, greaterThan(0), reason: 'the simulation should exercise auto-adjust');
  });

  test('results are deterministic for the same inputs', () {
    final first = simulate(5);
    final second = simulate(5);
    for (var index = 0; index < first.length; index++) {
      expect(second[index].plan.allocations, first[index].plan.allocations);
      expect(second[index].closing, first[index].closing);
      expect(second[index].adjustments.length, first[index].adjustments.length);
    }
  });

  test('undoing every auto-adjust batch restores the exact pre-adjust balances', () {
    final cycle = [
      for (var seed = 0; seed < 60; seed++) ...simulate(seed),
    ].firstWhere((cycle) => cycle.adjustments.length > 1);
    var adjustments = cycle.adjustments;
    for (final batchId in cycle.adjustments.map((adjustment) => adjustment.batchId).toSet()) {
      adjustments = AdjustmentBatches.undo(adjustments, batchId);
    }
    expect(
      Ledger.balances(
        opening: cycle.opening,
        allocations: cycle.plan.allocations,
        transactions: cycle.transactions,
        adjustments: adjustments,
      ),
      Ledger.balances(
        opening: cycle.opening,
        allocations: cycle.plan.allocations,
        transactions: cycle.transactions,
      ),
    );
  });
}
