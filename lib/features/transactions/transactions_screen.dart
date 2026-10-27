import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../common/transaction_tile.dart';
import '../common/widgets.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key, this.category});

  final BudgetCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider).value;
    final ledger = state?.ledger;
    final snapshot = state?.snapshot;
    if (ledger == null || snapshot == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final boundary = state!.settings!.dayBoundaryHour;
    final items = ledger.transactions
        .where((transaction) => !transaction.isCorrection && (category == null || transaction.category == category))
        .toList()
        .reversed
        .toList();
    final grouped = <CivilDate, List<Transaction>>{};
    for (final transaction in items) {
      grouped
          .putIfAbsent(KolkataTime.allowanceDateOf(transaction.occurredAt, boundaryHour: boundary), () => [])
          .add(transaction);
    }
    return Scaffold(
      appBar: AppBar(title: const Text(S.transactionsTitle)),
      body: items.isEmpty
          ? Center(child: Text(S.noTransactions, style: TextStyle(color: context.palette.mutedText)))
          : ListView(
              children: [
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      dayLabel(entry.key, snapshot.today, formatDate),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.palette.mutedText),
                    ),
                  ),
                  for (final transaction in entry.value) TransactionTile(transaction: transaction),
                ],
              ],
            ),
    );
  }
}
