import 'package:budget_engine/budget_engine.dart';

enum BatchKind { refill, release, correction, fundCover }

final class BatchRecord {
  const BatchRecord({
    required this.id,
    required this.kind,
    required this.createdAt,
    required this.moved,
    required this.held,
    required this.shortfall,
    required this.targets,
    required this.suggestReplan,
    required this.seen,
    required this.undone,
  });

  final String id;
  final BatchKind kind;
  final DateTime createdAt;
  final Money moved;
  final Money held;
  final Money shortfall;
  final List<BudgetCategory> targets;
  final bool suggestReplan;
  final bool seen;
  final bool undone;

  BatchRecord copyWith({bool? seen, bool? undone}) => BatchRecord(
        id: id,
        kind: kind,
        createdAt: createdAt,
        moved: moved,
        held: held,
        shortfall: shortfall,
        targets: targets,
        suggestReplan: suggestReplan,
        seen: seen ?? this.seen,
        undone: undone ?? this.undone,
      );
}

final class CycleRecord {
  const CycleRecord({
    required this.id,
    required this.window,
    required this.weights,
    required this.installments,
    required this.carryIn,
    required this.baseline,
    required this.delta,
    required this.foodFloor,
    required this.petrolFloor,
    required this.shortfall,
    required this.baseDaily,
  });

  final int id;
  final CycleWindow window;
  final CategoryWeights weights;
  final Money installments;
  final Money carryIn;
  final Money baseline;
  final Money delta;
  final Money foodFloor;
  final Money petrolFloor;
  final Money shortfall;
  final Money baseDaily;

  CycleRecord copyWith({Money? baseDaily, Money? petrolFloor, Money? foodFloor, CycleWindow? window}) => CycleRecord(
        id: id,
        window: window ?? this.window,
        weights: weights,
        installments: installments,
        carryIn: carryIn,
        baseline: baseline,
        delta: delta,
        foodFloor: foodFloor ?? this.foodFloor,
        petrolFloor: petrolFloor ?? this.petrolFloor,
        shortfall: shortfall,
        baseDaily: baseDaily ?? this.baseDaily,
      );

  CycleRecord withBaseDaily(Money value) => copyWith(baseDaily: value);
}

final class NamedSupply {
  const NamedSupply({required this.name, required this.state});

  final String name;
  final SupplyItemState state;

  NamedSupply withState(SupplyItemState next) => NamedSupply(name: name, state: next);
}

final class NamedRecurringCost {
  const NamedRecurringCost({required this.name, required this.state});

  final String name;
  final RecurringCostState state;
}

final class LinkedFuelFill {
  const LinkedFuelFill({required this.fill, required this.transactionId});

  final FuelFill fill;
  final String transactionId;
}

final class BikeProfile {
  const BikeProfile({this.service = const BikeServicePlan(), this.insuranceExpiry, this.pucExpiry});

  final BikeServicePlan service;
  final CivilDate? insuranceExpiry;
  final CivilDate? pucExpiry;

  static const empty = BikeProfile();

  BikeProfile withService(BikeServicePlan next) =>
      BikeProfile(service: next, insuranceExpiry: insuranceExpiry, pucExpiry: pucExpiry);
}

final class AnchorRecord {
  const AnchorRecord({required this.at, required this.bank, required this.cash, required this.excluded});

  final DateTime at;
  final Money bank;
  final Money cash;
  final Money excluded;

  BalanceAnchor get anchor => BalanceAnchor(at: at, total: bank + cash - excluded);
}

final class LedgerData {
  const LedgerData({
    required this.cycle,
    required this.opening,
    required this.planAllocations,
    required this.extraAllocations,
    required this.deposits,
    required this.transactions,
    required this.adjustments,
    required this.holds,
    required this.batches,
    required this.supplies,
    required this.recurring,
    required this.learnedKeywords,
    this.fuelFills = const [],
    this.bike = BikeProfile.empty,
    this.latestAnchor,
  });

  final CycleRecord cycle;
  final Map<BudgetCategory, Money> opening;
  final Map<BudgetCategory, Money> planAllocations;
  final Map<BudgetCategory, Money> extraAllocations;
  final List<Deposit> deposits;
  final List<Transaction> transactions;
  final List<Adjustment> adjustments;
  final List<Hold> holds;
  final List<BatchRecord> batches;
  final List<NamedSupply> supplies;
  final List<NamedRecurringCost> recurring;
  final Map<String, BudgetCategory> learnedKeywords;
  final List<LinkedFuelFill> fuelFills;
  final BikeProfile bike;
  final AnchorRecord? latestAnchor;

  Map<BudgetCategory, Money> get allocations => {
        for (final category in BudgetCategory.values)
          category: (planAllocations[category] ?? Money.zero) + (extraAllocations[category] ?? Money.zero),
      };

  Map<BudgetCategory, Money> get balances => Ledger.balances(
        opening: opening,
        allocations: allocations,
        transactions: transactions,
        adjustments: adjustments,
      );

  Map<BudgetCategory, Money> get held => Holds.heldByCategory(holds);

  int? get latestOdometer {
    if (fuelFills.isEmpty) {
      return bike.service.lastServiceKm;
    }
    final fromFills = fuelFills.map((linked) => linked.fill.odometerKm).reduce((a, b) => a > b ? a : b);
    final fromService = bike.service.lastServiceKm ?? 0;
    return fromFills > fromService ? fromFills : fromService;
  }

  FuelSummary fuelSummary(CivilDate today) =>
      FuelLog.summarise(fuelFills.map((linked) => linked.fill), today: today);

  ServiceDue serviceDue(CivilDate today) {
    final summary = fuelSummary(today);
    return BikeSchedule.serviceDue(
      plan: bike.service,
      today: today,
      currentKm: latestOdometer,
      ridingKm: summary.ridingKm,
      ridingDays: summary.ridingDays,
    );
  }

  LedgerData copyWith({
    CycleRecord? cycle,
    Map<BudgetCategory, Money>? extraAllocations,
    List<Deposit>? deposits,
    List<Transaction>? transactions,
    List<Adjustment>? adjustments,
    List<Hold>? holds,
    List<BatchRecord>? batches,
    List<NamedSupply>? supplies,
    List<NamedRecurringCost>? recurring,
    Map<String, BudgetCategory>? learnedKeywords,
    List<LinkedFuelFill>? fuelFills,
    BikeProfile? bike,
    AnchorRecord? latestAnchor,
  }) =>
      LedgerData(
        cycle: cycle ?? this.cycle,
        opening: opening,
        planAllocations: planAllocations,
        extraAllocations: extraAllocations ?? this.extraAllocations,
        deposits: deposits ?? this.deposits,
        transactions: transactions ?? this.transactions,
        adjustments: adjustments ?? this.adjustments,
        holds: holds ?? this.holds,
        batches: batches ?? this.batches,
        supplies: supplies ?? this.supplies,
        recurring: recurring ?? this.recurring,
        learnedKeywords: learnedKeywords ?? this.learnedKeywords,
        fuelFills: fuelFills ?? this.fuelFills,
        bike: bike ?? this.bike,
        latestAnchor: latestAnchor ?? this.latestAnchor,
      );
}
