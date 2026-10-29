import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/budget_snapshot.dart';
import '../../domain/rupees.dart';
import '../add/add_sheet.dart';
import '../common/widgets.dart';
import '../profile/profile_screen.dart';
import 'allowance_ring.dart';
import 'category_card.dart';
import 'quick_log.dart';
import 'refill_summary.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(budgetProvider.select((value) => value.value?.snapshot));
    if (snapshot == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final content = ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Header(snapshot: snapshot),
        const SizedBox(height: 12),
        if (snapshot.pendingSummary != null) ...[
          RefillSummaryCard(batch: snapshot.pendingSummary!),
          const SizedBox(height: 12),
        ],
        if (snapshot.awaitingDeposit) ...[
          SectionCard(
            key: const Key('awaiting-banner'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.awaitingBannerTitle, style: textTheme.titleSmall?.copyWith(color: palette.text)),
                const SizedBox(height: 4),
                Text(S.awaitingBannerBody, style: textTheme.bodySmall?.copyWith(color: palette.mutedText)),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (snapshot.isLateNight) ...[
          _LateNightCard(snapshot: snapshot),
          const SizedBox(height: 12),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AllowanceRing(snapshot: snapshot),
            const SizedBox(width: 16),
            Expanded(
              child: RingSideBlock(
                snapshot: snapshot,
                onMoveBanked: () => _moveBanked(context, ref, snapshot),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(_runwayText(snapshot), key: const Key('runway-line'), style: textTheme.bodySmall?.copyWith(color: palette.mutedText)),
        const SizedBox(height: 12),
        QuickAddChips(predicted: snapshot.predictedCategory),
        const SizedBox(height: 12),
        const TypeToLogBar(),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: [
            for (final view in snapshot.categories)
              CategoryCard(
                view: view,
                onOpen: () => context.push('/category/${view.category.name}'),
                onAdd: view.isSpendable ? () => showAddSheet(context, category: view.category) : null,
              ),
          ],
        ),
        const SizedBox(height: 16),
        _IdeaCard(snapshot: snapshot),
      ],
    );
    return Scaffold(
      body: SafeArea(
        child: snapshot.isLateNight
            ? Stack(
                children: [
                  content,
                  IgnorePointer(child: Container(color: Colors.black.withValues(alpha: 0.18))),
                ],
              )
            : content,
      ),
    );
  }

  String _runwayText(BudgetSnapshot snapshot) {
    final runway = snapshot.runway;
    if (runway == null || runway.isComfortable) {
      return S.runwayComfortable;
    }
    final date = formatDate(runway.runsOutOn!);
    return runway.isShort ? S.runwayShort(date, runway.daysShort) : S.runwaySpare(date, runway.daysSpare);
  }

  Future<void> _moveBanked(BuildContext context, WidgetRef ref, BudgetSnapshot snapshot) async {
    final target = await showModalBottomSheet<BudgetCategory>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text(S.moveToBuffer),
              onTap: () => Navigator.of(context).pop(BudgetCategory.buffer),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text(S.moveToGoals),
              onTap: () => Navigator.of(context).pop(BudgetCategory.goals),
            ),
          ],
        ),
      ),
    );
    if (target == null || !context.mounted) {
      return;
    }
    final amount = snapshot.allowance.banked;
    await ref.read(budgetProvider.notifier).moveBanked(amount: amount, to: target);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.bankedMoved(Rupees.format(amount), S.categoryName(target)))),
      );
    }
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.snapshot});

  final BudgetSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.greeting(KolkataTime.wallClock(snapshot.now).hour),
                style: textTheme.titleLarge?.copyWith(color: palette.text, fontWeight: FontWeight.w600),
              ),
              Text(
                snapshot.awaitingDeposit
                    ? S.awaitingLine(snapshot.daysLeft)
                    : S.cycleLine(snapshot.dayNumber, snapshot.cycleLength, snapshot.daysLeft),
                key: const Key('cycle-line'),
                style: textTheme.bodyMedium?.copyWith(color: palette.mutedText),
              ),
            ],
          ),
        ),
        IconButton(
          key: const Key('open-profile'),
          tooltip: S.profile,
          icon: const ProfileAvatar(radius: 14),
          onPressed: () => context.push('/profile'),
        ),
        IconButton(
          key: const Key('lock-button'),
          tooltip: S.lockNow,
          icon: const Icon(Icons.lock_outline),
          onPressed: () => ref.read(lockProvider.notifier).lock(),
        ),
      ],
    );
  }
}

class _LateNightCard extends StatelessWidget {
  const _LateNightCard({required this.snapshot});

  final BudgetSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final stock = snapshot.view(BudgetCategory.nightFoodStock).left;
    final line = S.lateNightLines[snapshot.today.day % S.lateNightLines.length];
    return SectionCard(
      key: const Key('late-night'),
      child: Row(
        children: [
          Icon(Icons.nightlight_round, color: palette.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.lateNightStock(Rupees.format(stock)), style: textTheme.titleSmall?.copyWith(color: palette.text)),
                Text(line, style: textTheme.bodySmall?.copyWith(color: palette.mutedText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({required this.snapshot});

  final BudgetSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final dayIndex = CivilDate(2026, 1, 1).daysUntil(snapshot.today);
    final idea = S.ideas[dayIndex % S.ideas.length];
    return SectionCard(
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: palette.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.todaysIdea, style: textTheme.labelLarge?.copyWith(color: palette.mutedText)),
                Text(idea, style: textTheme.bodyMedium?.copyWith(color: palette.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
