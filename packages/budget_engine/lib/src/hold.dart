import 'adjustment.dart';
import 'category.dart';
import 'money.dart';

final class HoldDraft {
  HoldDraft({required this.category, required this.amount}) {
    if (amount.isZero) {
      throw ArgumentError.value(amount, 'amount', 'must not be zero');
    }
  }

  final BudgetCategory category;
  final Money amount;

  bool get isPlacement => amount.isPositive;
}

final class Hold {
  Hold.fromDraft({
    required this.id,
    required this.batchId,
    required this.commitmentId,
    required this.createdAt,
    required this.draft,
    this.undone = false,
  });

  final String id;
  final String batchId;
  final String commitmentId;
  final DateTime createdAt;
  final HoldDraft draft;
  final bool undone;

  BudgetCategory get category => draft.category;
  Money get amount => draft.amount;

  Hold markUndone() => Hold.fromDraft(
        id: id,
        batchId: batchId,
        commitmentId: commitmentId,
        createdAt: createdAt,
        draft: draft,
        undone: true,
      );
}

final class HoldCommitment {
  const HoldCommitment({
    required this.id,
    required this.placedAt,
    required this.lastActivityAt,
    required this.remaining,
  });

  final String id;
  final DateTime placedAt;
  final DateTime lastActivityAt;
  final Map<BudgetCategory, Money> remaining;

  Money get total => Money.sum(remaining.values);
}

final class HoldRelease {
  const HoldRelease({required this.commitmentId, required this.moves, required this.holds});

  final String commitmentId;
  final List<AdjustmentDraft> moves;
  final List<HoldDraft> holds;

  Money get moved => Money.sum(moves.map((move) => move.amount));
  Money get released => -Money.sum(holds.map((hold) => hold.amount));
}

abstract final class Holds {
  static const donorOrder = [
    BudgetCategory.buffer,
    BudgetCategory.trySomethingNew,
    BudgetCategory.outings,
    BudgetCategory.essentialsStock,
  ];

  static Map<BudgetCategory, Money> heldByCategory(Iterable<Hold> holds) {
    final held = BudgetCategory.filled(Money.zero);
    for (final hold in holds.where((hold) => !hold.undone)) {
      held[hold.category] = held[hold.category]! + hold.amount;
    }
    return {for (final entry in held.entries) entry.key: entry.value.positivePart};
  }

  static Money totalHeld(Iterable<Hold> holds) => Money.sum(heldByCategory(holds).values);

  static Map<BudgetCategory, Money> spendable(
    Map<BudgetCategory, Money> balances,
    Map<BudgetCategory, Money> held,
  ) =>
      {
        for (final category in BudgetCategory.values)
          category: (balances[category] ?? Money.zero) - (held[category] ?? Money.zero),
      };

  static List<HoldCommitment> commitments(Iterable<Hold> holds) {
    final grouped = <String, List<Hold>>{};
    for (final hold in holds.where((hold) => !hold.undone)) {
      grouped.putIfAbsent(hold.commitmentId, () => []).add(hold);
    }
    final result = <HoldCommitment>[];
    for (final entry in grouped.entries) {
      final remaining = BudgetCategory.filled(Money.zero);
      for (final hold in entry.value) {
        remaining[hold.category] = remaining[hold.category]! + hold.amount;
      }
      final placements = entry.value.where((hold) => hold.draft.isPlacement);
      if (placements.isEmpty) {
        continue;
      }
      final commitment = HoldCommitment(
        id: entry.key,
        placedAt: placements.map((hold) => hold.createdAt).reduce((a, b) => a.isBefore(b) ? a : b),
        lastActivityAt: entry.value.map((hold) => hold.createdAt).reduce((a, b) => a.isAfter(b) ? a : b),
        remaining: {
          for (final category in donorOrder)
            if (remaining[category]!.isPositive) category: remaining[category]!,
        },
      );
      if (commitment.total.isPositive) {
        result.add(commitment);
      }
    }
    result.sort((a, b) {
      final byTime = a.placedAt.compareTo(b.placedAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    return result;
  }

  static HoldRelease release({
    required HoldCommitment commitment,
    required Money amount,
    required Map<BudgetCategory, Money> balances,
    BudgetCategory to = BudgetCategory.food,
  }) {
    final moves = <AdjustmentDraft>[];
    final drafts = <HoldDraft>[];
    var left = amount;
    for (final category in donorOrder) {
      if (!left.isPositive) {
        break;
      }
      final portion = Money.min(commitment.remaining[category] ?? Money.zero, left);
      if (!portion.isPositive) {
        continue;
      }
      drafts.add(HoldDraft(category: category, amount: -portion));
      final movable = Money.min(portion, (balances[category] ?? Money.zero).positivePart);
      if (movable.isPositive) {
        moves.add(AdjustmentDraft(
          from: category,
          to: to,
          amount: movable,
          reason: AdjustmentReason.holdRelease,
          auto: true,
        ));
        balances[category] = balances[category]! - movable;
        balances[to] = (balances[to] ?? Money.zero) + movable;
      }
      left -= portion;
    }
    return HoldRelease(commitmentId: commitment.id, moves: moves, holds: drafts);
  }
}

final class UndoResult {
  const UndoResult({required this.adjustments, required this.holds, required this.undoneBatches});

  final List<Adjustment> adjustments;
  final List<Hold> holds;
  final Set<String> undoneBatches;
}

abstract final class BatchUndo {
  static UndoResult undo({
    required List<Adjustment> adjustments,
    required List<Hold> holds,
    required String batchId,
  }) {
    final batches = {batchId};
    var grew = true;
    while (grew) {
      grew = false;
      for (final hold in holds) {
        if (!hold.undone && batches.contains(hold.commitmentId) && batches.add(hold.batchId)) {
          grew = true;
        }
      }
    }
    return UndoResult(
      adjustments: [
        for (final adjustment in adjustments)
          batches.contains(adjustment.batchId) ? adjustment.markUndone() : adjustment,
      ],
      holds: [
        for (final hold in holds) batches.contains(hold.batchId) ? hold.markUndone() : hold,
      ],
      undoneBatches: batches,
    );
  }
}
