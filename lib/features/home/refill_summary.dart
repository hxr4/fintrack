import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/ledger_data.dart';
import '../../domain/rupees.dart';
import '../common/widgets.dart';

class RefillSummaryCard extends ConsumerWidget {
  const RefillSummaryCard({super.key, required this.batch});

  final BatchRecord batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final controller = ref.read(budgetProvider.notifier);
    return SectionCard(
      key: const Key('refill-summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.summaryMoved(Rupees.format(batch.moved), batch.targets),
            style: textTheme.titleMedium?.copyWith(color: palette.text),
          ),
          if (batch.held.isPositive)
            Text(S.summaryHolding(Rupees.format(batch.held)), style: textTheme.titleSmall?.copyWith(color: palette.text)),
          const SizedBox(height: 6),
          Text(S.summaryExplain, style: textTheme.bodySmall?.copyWith(color: palette.mutedText)),
          if (batch.shortfall.isPositive) ...[
            const SizedBox(height: 6),
            Text(S.summaryShortfall(Rupees.format(batch.shortfall)), style: textTheme.bodySmall?.copyWith(color: palette.tight)),
          ],
          if (batch.suggestReplan) ...[
            const SizedBox(height: 12),
            Text(S.replanTitle, style: textTheme.titleSmall?.copyWith(color: palette.text)),
            Text(S.replanBody, style: textTheme.bodySmall?.copyWith(color: palette.mutedText)),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    controller.markSummarySeen(batch.id);
                    context.push('/balance-check');
                  },
                  child: const Text(S.balanceCheck),
                ),
                OutlinedButton(onPressed: () => _later(context), child: const Text(S.familySummary)),
              ],
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                key: const Key('refill-undo'),
                onPressed: () => controller.undoBatch(batch.id),
                child: const Text(S.undo),
              ),
              FilledButton.tonal(
                key: const Key('refill-ok'),
                onPressed: () => controller.markSummarySeen(batch.id),
                child: const Text(S.gotIt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _later(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(S.comingLater)));
  }
}
