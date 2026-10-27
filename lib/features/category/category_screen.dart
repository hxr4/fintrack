import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/ledger_data.dart';
import '../../domain/rupees.dart';
import '../add/add_sheet.dart';
import '../common/transaction_tile.dart';
import '../common/widgets.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.category});

  final BudgetCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider).value;
    final ledger = state?.ledger;
    final snapshot = state?.snapshot;
    if (ledger == null || snapshot == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final view = snapshot.view(category);
    final elapsedDays = snapshot.awaitingDeposit ? snapshot.cycleLength : snapshot.dayNumber;
    final expected = view.total.times(elapsedDays).floorDiv(snapshot.cycleLength);
    final transactions = ledger.transactions
        .where((transaction) => transaction.category == category && !transaction.isCorrection)
        .toList()
        .reversed
        .toList();
    final batchesById = {for (final batch in ledger.batches) batch.id: batch};
    final moves = ledger.adjustments
        .where((adjustment) => adjustment.from == category || adjustment.to == category)
        .toList()
        .reversed
        .toList();
    final holds = ledger.holds.where((hold) => hold.category == category).toList().reversed.toList();
    return Scaffold(
      appBar: AppBar(title: Text(S.categoryName(category))),
      floatingActionButton: view.isSpendable
          ? FloatingActionButton(
              onPressed: () => showAddSheet(context, category: category),
              child: const Icon(Icons.add),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.leftLabel, style: textTheme.labelMedium?.copyWith(color: palette.mutedText)),
                AnimatedMoney(view.left, style: textTheme.headlineMedium?.copyWith(color: palette.text, fontWeight: FontWeight.w600)),
                if (view.held.isPositive)
                  Text(S.heldLine(Rupees.format(view.held)), style: textTheme.bodySmall?.copyWith(color: palette.mutedText)),
                const SizedBox(height: 12),
                AnimatedBar(permille: view.leftPermille, color: palette.health(view.health.state)),
                const SizedBox(height: 8),
                if (category == BudgetCategory.goals)
                  Text(S.notSpendable, style: textTheme.labelSmall?.copyWith(color: palette.mutedText))
                else ...[
                  HealthTag(health: view.health.state, coveredByFloor: view.health.coveredByFloor),
                  const SizedBox(height: 8),
                  Text(
                    S.paceLine(Rupees.format(view.spent), Rupees.format(expected)),
                    style: textTheme.bodySmall?.copyWith(color: palette.mutedText),
                  ),
                ],
              ],
            ),
          ),
          if (category == BudgetCategory.essentialsStock || category == BudgetCategory.petrol) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('open-supplies'),
              onPressed: () => context.push(category == BudgetCategory.petrol ? '/supplies?tab=1' : '/supplies'),
              icon: Icon(category == BudgetCategory.petrol ? Icons.local_gas_station : Icons.inventory_2_outlined),
              label: Text(category == BudgetCategory.petrol ? S.logFuel : S.tabSupplies),
            ),
          ],
          if (moves.isNotEmpty || holds.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(S.moves, style: textTheme.titleSmall),
            for (final move in moves)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(move.to == category ? Icons.south_west : Icons.north_east, color: palette.mutedText),
                title: Text(
                  move.to == category
                      ? S.moveIn(Rupees.format(move.amount), move.from)
                      : S.moveOut(Rupees.format(move.amount), move.to),
                  style: move.undone ? TextStyle(decoration: TextDecoration.lineThrough, color: palette.mutedText) : null,
                ),
                subtitle: Text(formatDate(KolkataTime.dateOf(move.createdAt))),
                trailing: _undoButton(ref, batchesById[move.batchId], move.undone),
              ),
            for (final hold in holds)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.pause_circle_outline, color: palette.mutedText),
                title: Text(
                  hold.amount.isPositive ? S.holdPlaced(Rupees.format(hold.amount)) : S.holdReleased(Rupees.format(-hold.amount)),
                  style: hold.undone ? TextStyle(decoration: TextDecoration.lineThrough, color: palette.mutedText) : null,
                ),
                subtitle: Text(formatDate(KolkataTime.dateOf(hold.createdAt))),
              ),
          ],
          const SizedBox(height: 16),
          Text(S.spentThisCycle, style: textTheme.titleSmall),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(S.noTransactions, style: TextStyle(color: palette.mutedText)),
            ),
          for (final transaction in transactions) TransactionTile(transaction: transaction),
        ],
      ),
    );
  }

  Widget? _undoButton(WidgetRef ref, BatchRecord? batch, bool undone) {
    if (undone) {
      return const Text(S.undone);
    }
    if (batch == null || batch.kind != BatchKind.refill) {
      return null;
    }
    return TextButton(
      onPressed: () => ref.read(budgetProvider.notifier).undoBatch(batch.id),
      child: const Text(S.undo),
    );
  }
}
