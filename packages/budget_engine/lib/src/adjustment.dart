import 'category.dart';
import 'money.dart';

enum AdjustmentReason { autoRefill, holdRelease, bankedMove, balanceCheck, goalSaving, manual }

final class AdjustmentDraft {
  AdjustmentDraft({
    required this.from,
    required this.to,
    required this.amount,
    required this.reason,
    required this.auto,
  }) {
    if (!amount.isPositive) {
      throw ArgumentError.value(amount, 'amount', 'must be positive');
    }
    if (from == to) {
      throw ArgumentError.value(to, 'to', 'must differ from source');
    }
  }

  final BudgetCategory from;
  final BudgetCategory to;
  final Money amount;
  final AdjustmentReason reason;
  final bool auto;
}

final class Adjustment {
  Adjustment.fromDraft({
    required this.id,
    required this.batchId,
    required this.createdAt,
    required this.draft,
    this.undone = false,
  });

  final String id;
  final String batchId;
  final DateTime createdAt;
  final AdjustmentDraft draft;
  final bool undone;

  BudgetCategory get from => draft.from;
  BudgetCategory get to => draft.to;
  Money get amount => draft.amount;
  AdjustmentReason get reason => draft.reason;
  bool get auto => draft.auto;

  Adjustment markUndone() => Adjustment.fromDraft(
        id: id,
        batchId: batchId,
        createdAt: createdAt,
        draft: draft,
        undone: true,
      );
}

abstract final class AdjustmentBatches {
  static List<Adjustment> undo(List<Adjustment> adjustments, String batchId) => [
        for (final adjustment in adjustments)
          adjustment.batchId == batchId ? adjustment.markUndone() : adjustment,
      ];
}
