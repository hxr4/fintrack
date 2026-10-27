import 'category.dart';
import 'civil_date.dart';
import 'largest_remainder.dart';
import 'money.dart';
import 'policy.dart';
import 'transaction.dart';

final class PurchaseRequest {
  PurchaseRequest({
    required this.item,
    required this.price,
    required this.today,
    this.alreadySaved = Money.zero,
    this.targetDate,
  }) {
    if (!price.isPositive) {
      throw ArgumentError.value(price, 'price', 'must be positive');
    }
    if (targetDate != null && !targetDate!.isAfter(today)) {
      throw ArgumentError.value(targetDate, 'targetDate', 'must be after today');
    }
  }

  final String item;
  final Money price;
  final CivilDate today;
  final Money alreadySaved;
  final CivilDate? targetDate;

  Money get stillNeeded => (price - alreadySaved).positivePart;
}

final class SavingsCapacity {
  const SavingsCapacity({
    required this.flexibleBalances,
    required this.daysLeftInCycle,
    required this.buffer,
    required this.banked,
    required this.typicalOutingCost,
    required this.typicalTreatCost,
  });

  final Map<BudgetCategory, Money> flexibleBalances;
  final int daysLeftInCycle;
  final Money buffer;
  final Money banked;
  final Money typicalOutingCost;
  final Money typicalTreatCost;

  Money get flexibleDaily => Money.sum(BudgetCategory.flexibleSavingsSources
          .map((category) => (flexibleBalances[category] ?? Money.zero).positivePart))
      .floorDiv(daysLeftInCycle);
}

final class PurchaseScenario {
  const PurchaseScenario({
    required this.pace,
    required this.dailySaving,
    required this.fromBanked,
    required this.fromBuffer,
    required this.days,
    required this.reachedOn,
    required this.cuts,
    required this.outingsSkipped,
    required this.treatsSkipped,
    required this.meetsTarget,
  });

  final ScenarioPace pace;
  final Money dailySaving;
  final Money fromBanked;
  final Money fromBuffer;
  final int? days;
  final CivilDate? reachedOn;
  final Map<BudgetCategory, Money> cuts;
  final int outingsSkipped;
  final int treatsSkipped;
  final bool? meetsTarget;

  bool get isFeasible => days != null;
}

final class TargetFeasibility {
  const TargetFeasibility({
    required this.feasible,
    required this.earliestDate,
    required this.extraIncomeNeeded,
  });

  final bool feasible;
  final CivilDate? earliestDate;
  final Money extraIncomeNeeded;
}

final class PurchasePlan {
  const PurchasePlan({required this.request, required this.scenarios, required this.target});

  final PurchaseRequest request;
  final List<PurchaseScenario> scenarios;
  final TargetFeasibility? target;

  PurchaseScenario scenario(ScenarioPace pace) =>
      scenarios.firstWhere((scenario) => scenario.pace == pace);
}

abstract final class PurchasePlanner {
  static Money typicalCost(
    Iterable<Transaction> transactions,
    BudgetCategory category, {
    required Money fallback,
  }) {
    final amounts = transactions
        .where((transaction) => transaction.category == category && !transaction.isCorrection)
        .map((transaction) => transaction.amount)
        .toList()
      ..sort();
    if (amounts.isEmpty) {
      return fallback;
    }
    final middle = amounts.length ~/ 2;
    return amounts.length.isOdd ? amounts[middle] : (amounts[middle - 1] + amounts[middle]).floorDiv(2);
  }

  static PurchasePlan plan({
    required PurchaseRequest request,
    required SavingsCapacity capacity,
    BudgetPolicy policy = const BudgetPolicy(),
  }) {
    final flexibleDaily = capacity.flexibleDaily;
    final needed = request.stillNeeded;
    final daysToTarget = request.targetDate == null ? null : request.today.daysUntil(request.targetDate!);
    final scenarios = [
      for (final rule in policy.scenarios)
        _scenario(rule, request, capacity, flexibleDaily, needed, daysToTarget),
    ];
    return PurchasePlan(
      request: request,
      scenarios: scenarios,
      target: daysToTarget == null
          ? null
          : _feasibility(request, capacity, flexibleDaily, needed, daysToTarget),
    );
  }

  static PurchaseScenario _scenario(
    ScenarioRule rule,
    PurchaseRequest request,
    SavingsCapacity capacity,
    Money flexibleDaily,
    Money needed,
    int? daysToTarget,
  ) {
    final fromBanked = rule.usesBanked ? Money.min(capacity.banked.positivePart, needed) : Money.zero;
    final fromBuffer = Money.min(
      capacity.buffer.positivePart.times(rule.bufferPercent).floorDiv(100),
      needed - fromBanked,
    );
    final remaining = needed - fromBanked - fromBuffer;
    final dailySaving = flexibleDaily.times(rule.flexiblePercent).floorDiv(100);
    final int? days;
    if (remaining.isZero) {
      days = 0;
    } else if (dailySaving.isPositive) {
      days = remaining.ceilDiv(dailySaving.paise).paise;
    } else {
      days = null;
    }
    final cuts = remaining.isZero
        ? {for (final category in BudgetCategory.flexibleSavingsSources) category: Money.zero}
        : _cuts(remaining, capacity);
    return PurchaseScenario(
      pace: rule.pace,
      dailySaving: dailySaving,
      fromBanked: fromBanked,
      fromBuffer: fromBuffer,
      days: days,
      reachedOn: days == null ? null : request.today.addDays(days),
      cuts: cuts,
      outingsSkipped: _count(cuts[BudgetCategory.outings]!, capacity.typicalOutingCost),
      treatsSkipped: _count(cuts[BudgetCategory.trySomethingNew]!, capacity.typicalTreatCost),
      meetsTarget: daysToTarget == null || days == null ? (daysToTarget == null ? null : false) : days <= daysToTarget,
    );
  }

  static Map<BudgetCategory, Money> _cuts(Money amount, SavingsCapacity capacity) {
    final basis = {
      for (final category in BudgetCategory.flexibleSavingsSources)
        category: (capacity.flexibleBalances[category] ?? Money.zero).positivePart,
    };
    if (basis.values.every((value) => value.isZero)) {
      return {for (final category in BudgetCategory.flexibleSavingsSources) category: Money.zero};
    }
    return LargestRemainder.splitByAmounts(amount, basis);
  }

  static int _count(Money amount, Money unit) {
    if (!unit.isPositive || !amount.isPositive) {
      return 0;
    }
    return (amount + unit.floorDiv(2)).wholeTimesIn(unit);
  }

  static TargetFeasibility _feasibility(
    PurchaseRequest request,
    SavingsCapacity capacity,
    Money flexibleDaily,
    Money needed,
    int daysToTarget,
  ) {
    final lumps = capacity.banked.positivePart + capacity.buffer.positivePart;
    final maximum = lumps + flexibleDaily.times(daysToTarget);
    if (maximum >= needed) {
      return const TargetFeasibility(feasible: true, earliestDate: null, extraIncomeNeeded: Money.zero);
    }
    final afterLumps = (needed - lumps).positivePart;
    return TargetFeasibility(
      feasible: false,
      earliestDate: flexibleDaily.isPositive
          ? request.today.addDays(afterLumps.ceilDiv(flexibleDaily.paise).paise)
          : null,
      extraIncomeNeeded: needed - maximum,
    );
  }
}
