import 'package:budget_engine/budget_engine.dart';

import 'ledger_data.dart';

final class SupplyDraft {
  const SupplyDraft({required this.name, required this.price, required this.lifespanDays, required this.lastRestock});

  final String name;
  final Money price;
  final int lifespanDays;
  final CivilDate lastRestock;
}

final class RecurringDraft {
  const RecurringDraft({required this.name, required this.amount, required this.everyMonths});

  final String name;
  final Money amount;
  final int everyMonths;
}

final class OnboardingInput {
  const OnboardingInput({
    required this.deposit,
    required this.depositDate,
    required this.anchorDay,
    required this.foodFloorPerDay,
    required this.petrolFloorPerCycle,
    required this.nightFoodStock,
    required this.weights,
    required this.bank,
    required this.cash,
    required this.excluded,
    required this.recurring,
    required this.supplies,
    required this.cardEnabled,
  });

  final Money deposit;
  final CivilDate depositDate;
  final int anchorDay;
  final Money foodFloorPerDay;
  final Money petrolFloorPerCycle;
  final Money nightFoodStock;
  final CategoryWeights weights;
  final Money bank;
  final Money cash;
  final Money excluded;
  final List<RecurringDraft> recurring;
  final List<SupplyDraft> supplies;
  final bool cardEnabled;

  BudgetSettings toSettings({int dayBoundaryHour = 4}) => BudgetSettings(
        foodFloorPerDay: foodFloorPerDay,
        petrolFloorPerCycle: petrolFloorPerCycle,
        nightFoodStockTarget: nightFoodStock,
        anchorDay: anchorDay,
        dayBoundaryHour: dayBoundaryHour,
        defaultWeights: weights,
      );
}

final class CycleHistory {
  const CycleHistory({required this.installmentTotals, required this.spends, required this.lastWeights});

  final List<Money> installmentTotals;
  final List<Map<BudgetCategory, Money>> spends;
  final CategoryWeights? lastWeights;

  static const empty = CycleHistory(installmentTotals: [], spends: [], lastWeights: null);
}

final class NewCyclePlan {
  const NewCyclePlan({required this.plan, required this.opening, required this.deposit});

  final CyclePlan plan;
  final Map<BudgetCategory, Money> opening;
  final Deposit deposit;
}

abstract final class CyclePlanning {
  static const policy = BudgetPolicy();

  static NewCyclePlan plan({
    required Deposit deposit,
    required CivilDate start,
    required BudgetSettings settings,
    required List<SupplyItemState> supplies,
    required List<RecurringCostState> recurring,
    required CycleHistory history,
    Map<BudgetCategory, Money> opening = const {},
    Money carryInToPool = Money.zero,
  }) {
    if (!deposit.isInstallment) {
      throw ArgumentError.value(deposit.kind, 'deposit', 'a cycle starts with an installment');
    }
    final window = CycleCalendar.windowStartingOn(start, anchorDay: settings.anchorDay, policy: policy);
    final plan = AllocationPlanner.plan(PlanInput(
      window: window,
      cycleDeposits: [deposit],
      settings: settings,
      policy: policy,
      carryInToPool: carryInToPool,
      previousInstallmentTotals: history.installmentTotals,
      completedCycleSpends: history.spends,
      previousWeights: history.lastWeights,
      reserves: ReserveInputs(
        nightFoodCarried: opening[BudgetCategory.nightFoodStock] ?? Money.zero,
        supplies: ReserveCalculator.supplyReserves(supplies, window),
        recurringIncrement: ReserveCalculator.recurringIncrement(recurring),
      ),
    ));
    return NewCyclePlan(plan: plan, opening: opening, deposit: deposit);
  }

  static CarryForward close({required LedgerData ledger, required BudgetSettings settings}) => CycleCloser.close(
        closingBalances: ledger.balances,
        nightFoodTarget: settings.nightFoodStockTarget,
        essentialsTarget: ReserveCalculator.essentialsTarget(ledger.supplies.map((supply) => supply.state)),
        bufferAllocation: ledger.planAllocations[BudgetCategory.buffer] ?? Money.zero,
        policy: policy,
      );

  static Map<BudgetCategory, Money> blendedSpend(Iterable<Transaction> transactions) => {
        for (final category in BudgetCategory.blended)
          category: Money.sum(transactions
              .where((transaction) => transaction.category == category && !transaction.isCorrection)
              .map((transaction) => transaction.amount)),
      };
}
