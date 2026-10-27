import 'category.dart';
import 'cycle_calendar.dart';
import 'deposit.dart';
import 'generosity.dart';
import 'largest_remainder.dart';
import 'money.dart';
import 'policy.dart';
import 'settings.dart';
import 'weight_blender.dart';
import 'weights.dart';

final class SupplyReserve {
  SupplyReserve({required this.itemId, required this.increment, required this.daysUntilDue}) {
    if (increment.isNegative) {
      throw ArgumentError.value(increment, 'increment', 'must not be negative');
    }
  }

  final String itemId;
  final Money increment;
  final int daysUntilDue;
}

final class ReserveInputs {
  const ReserveInputs({
    this.nightFoodCarried = Money.zero,
    this.supplies = const [],
    this.bikeFundIncrement = Money.zero,
    this.recurringIncrement = Money.zero,
  });

  final Money nightFoodCarried;
  final List<SupplyReserve> supplies;
  final Money bikeFundIncrement;
  final Money recurringIncrement;
}

final class PlanInput {
  const PlanInput({
    required this.window,
    required this.cycleDeposits,
    required this.settings,
    this.policy = const BudgetPolicy(),
    this.carryInToPool = Money.zero,
    this.previousInstallmentTotals = const [],
    this.completedCycleSpends = const [],
    this.previousWeights,
    this.reserves = const ReserveInputs(),
  });

  final CycleWindow window;
  final List<Deposit> cycleDeposits;
  final BudgetSettings settings;
  final BudgetPolicy policy;
  final Money carryInToPool;
  final List<Money> previousInstallmentTotals;
  final List<Map<BudgetCategory, Money>> completedCycleSpends;
  final CategoryWeights? previousWeights;
  final ReserveInputs reserves;
}

final class CyclePlan {
  const CyclePlan({
    required this.window,
    required this.allocations,
    required this.weights,
    required this.installments,
    required this.carryInToPool,
    required this.baseline,
    required this.delta,
    required this.foodFloor,
    required this.petrolFloor,
    required this.supplyAllocations,
    required this.deferredSupplies,
    required this.shortfall,
    required this.uncoveredDebt,
  });

  final CycleWindow window;
  final Map<BudgetCategory, Money> allocations;
  final CategoryWeights weights;
  final Money installments;
  final Money carryInToPool;
  final Money baseline;
  final Money delta;
  final Money foodFloor;
  final Money petrolFloor;
  final Map<String, Money> supplyAllocations;
  final Map<String, Money> deferredSupplies;
  final Money shortfall;
  final Money uncoveredDebt;

  Money get total => Money.sum(allocations.values);

  Money get fundsAvailable => (installments + carryInToPool).positivePart;

  bool get hasShortfall => shortfall.isPositive;

  Money get poolAtStart =>
      Money.sum(BudgetCategory.spendablePool.map((category) => allocations[category]!));

  Money get baseDaily => poolAtStart.floorDiv(window.length);
}

abstract final class AllocationPlanner {
  static CyclePlan plan(PlanInput input) {
    final settings = input.settings;
    final policy = input.policy;
    final window = input.window;
    final reserves = input.reserves;

    final installments = input.cycleDeposits.installmentTotal;
    final funds = installments + input.carryInToPool;
    final available = funds.positivePart;
    final uncoveredDebt = (-funds).positivePart;
    final baseline = Generosity.baseline(
      currentInstallments: installments,
      previousInstallmentTotals: input.previousInstallmentTotals,
      policy: policy,
    );
    final delta = installments - baseline;
    final weights = WeightBlender.blend(
      defaults: settings.defaultWeights,
      completedCycleSpends: input.completedCycleSpends,
      previous: input.previousWeights,
      policy: policy,
    );

    final foodFloor = settings.foodFloorPerDay.times(window.length);
    final petrolFloor = settings.petrolFloorPerCycle
        .times(window.length)
        .ceilDiv(policy.petrolFloorReferenceDays);
    final nightTopUp = (settings.nightFoodStockTarget - reserves.nightFoodCarried).positivePart;

    final supplies = {for (final item in reserves.supplies) item.itemId: item.increment};
    final suppliesTotal = Money.sum(supplies.values);
    final reserveTotal =
        nightTopUp + suppliesTotal + reserves.bikeFundIncrement + reserves.recurringIncrement;

    final allocations = BudgetCategory.filled(Money.zero);
    void add(BudgetCategory category, Money amount) {
      allocations[category] = allocations[category]! + amount;
    }

    add(BudgetCategory.nightFoodStock, nightTopUp);
    add(BudgetCategory.essentialsStock, suppliesTotal);
    add(BudgetCategory.bikeFund, reserves.bikeFundIncrement);
    add(BudgetCategory.recurringFund, reserves.recurringIncrement);

    final basePool = (available - delta - reserveTotal).positivePart;
    LargestRemainder.split(basePool, weights.basisPoints).forEach(add);
    if (delta.isPositive) {
      Generosity.splitPositive(delta, policy).forEach(add);
    }

    allocations[BudgetCategory.food] = allocations[BudgetCategory.food]!.atLeast(foodFloor);
    allocations[BudgetCategory.petrol] = allocations[BudgetCategory.petrol]!.atLeast(petrolFloor);

    var excess = Money.sum(allocations.values) - available;

    Money takeFrom(BudgetCategory category, Money keep) {
      if (!excess.isPositive) {
        return excess;
      }
      final spare = (allocations[category]! - keep).positivePart;
      final take = Money.min(spare, excess);
      allocations[category] = allocations[category]! - take;
      return excess - take;
    }

    final deferred = <String, Money>{};
    Money deferSupplies({required bool due}) {
      final candidates = reserves.supplies
          .where((item) => (item.daysUntilDue < window.length) == due)
          .toList()
        ..sort((a, b) {
          final byUrgency = b.daysUntilDue.compareTo(a.daysUntilDue);
          return byUrgency != 0 ? byUrgency : a.itemId.compareTo(b.itemId);
        });
      for (final item in candidates) {
        if (!excess.isPositive) {
          break;
        }
        final take = Money.min(supplies[item.itemId]!, excess);
        if (take.isPositive) {
          supplies[item.itemId] = supplies[item.itemId]! - take;
          deferred[item.itemId] = (deferred[item.itemId] ?? Money.zero) + take;
          allocations[BudgetCategory.essentialsStock] =
              allocations[BudgetCategory.essentialsStock]! - take;
          excess -= take;
        }
      }
      return excess;
    }

    for (final category in [
      BudgetCategory.trySomethingNew,
      BudgetCategory.outings,
      BudgetCategory.buffer,
      BudgetCategory.goals,
    ]) {
      excess = takeFrom(category, Money.zero);
    }
    excess = deferSupplies(due: false);
    excess = takeFrom(BudgetCategory.petrol, petrolFloor);
    excess = takeFrom(BudgetCategory.food, foodFloor);
    for (final category in [
      BudgetCategory.misc,
      BudgetCategory.recurringFund,
      BudgetCategory.bikeFund,
    ]) {
      excess = takeFrom(category, Money.zero);
    }
    excess = deferSupplies(due: true);
    for (final category in [
      BudgetCategory.petrol,
      BudgetCategory.nightFoodStock,
      BudgetCategory.food,
    ]) {
      excess = takeFrom(category, Money.zero);
    }

    if (!excess.isZero) {
      throw StateError('Allocation did not balance: $excess left over');
    }

    final dueSuppliesDeferred = Money.sum(reserves.supplies
        .where((item) => item.daysUntilDue < window.length)
        .map((item) => deferred[item.itemId] ?? Money.zero));
    final shortfall = (foodFloor - allocations[BudgetCategory.food]!).positivePart +
        (petrolFloor - allocations[BudgetCategory.petrol]!).positivePart +
        (nightTopUp - allocations[BudgetCategory.nightFoodStock]!).positivePart +
        (reserves.bikeFundIncrement - allocations[BudgetCategory.bikeFund]!).positivePart +
        (reserves.recurringIncrement - allocations[BudgetCategory.recurringFund]!).positivePart +
        dueSuppliesDeferred;

    return CyclePlan(
      window: window,
      allocations: Map.unmodifiable(allocations),
      weights: weights,
      installments: installments,
      carryInToPool: input.carryInToPool,
      baseline: baseline,
      delta: delta,
      foodFloor: foodFloor,
      petrolFloor: petrolFloor,
      supplyAllocations: Map.unmodifiable(supplies),
      deferredSupplies: Map.unmodifiable(deferred),
      shortfall: shortfall,
      uncoveredDebt: uncoveredDebt,
    );
  }
}
