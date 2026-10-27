import 'package:budget_engine/budget_engine.dart';

enum BatchKind { refill, release }

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

  CycleRecord withBaseDaily(Money value) => CycleRecord(
        id: id,
        window: window,
        weights: weights,
        installments: installments,
        carryIn: carryIn,
        baseline: baseline,
        delta: delta,
        foodFloor: foodFloor,
        petrolFloor: petrolFloor,
        shortfall: shortfall,
        baseDaily: value,
      );
}

final class NamedSupply {
  const NamedSupply({required this.name, required this.state});

  final String name;
  final SupplyItemState state;
}

final class NamedRecurringCost {
  const NamedRecurringCost({required this.name, required this.state});

  final String name;
  final RecurringCostState state;
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

  LedgerData copyWith({
    CycleRecord? cycle,
    Map<BudgetCategory, Money>? extraAllocations,
    List<Deposit>? deposits,
    List<Transaction>? transactions,
    List<Adjustment>? adjustments,
    List<Hold>? holds,
    List<BatchRecord>? batches,
    Map<String, BudgetCategory>? learnedKeywords,
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
        supplies: supplies,
        recurring: recurring,
        learnedKeywords: learnedKeywords ?? this.learnedKeywords,
      );
}
