import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/rupees.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final wall = KolkataTime.wallClock(transaction.occurredAt);
    final time = '${wall.hour.toString().padLeft(2, '0')}:${wall.minute.toString().padLeft(2, '0')}';
    final subtitle = [
      time,
      S.methodName(transaction.method),
      if (transaction.note.isNotEmpty) transaction.note,
    ].join(' · ');
    return Dismissible(
      key: Key('txn-${transaction.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: palette.cardBorder,
        child: Icon(Icons.delete_outline, color: palette.text),
      ),
      onDismissed: (_) async {
        final controller = ref.read(budgetProvider.notifier);
        final messenger = ScaffoldMessenger.of(context);
        final entry = await controller.deleteTransaction(transaction);
        messenger.showSnackBar(SnackBar(
          content: const Text(S.deleted),
          action: SnackBarAction(label: S.undo, onPressed: () => controller.restore(entry)),
        ));
      },
      child: ListTile(
        leading: Icon(CategoryIcons.of(transaction.category), color: palette.mutedText),
        title: Text(S.categoryName(transaction.category)),
        subtitle: Text(subtitle),
        trailing: Text(Rupees.format(transaction.amount), style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

String dayLabel(CivilDate day, CivilDate today, String Function(CivilDate) format) {
  if (day == today) {
    return S.today;
  }
  if (day == today.addDays(-1)) {
    return S.yesterday;
  }
  return format(day);
}
