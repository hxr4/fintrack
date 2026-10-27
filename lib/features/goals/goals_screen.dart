import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/rupees.dart';
import '../common/widgets.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(budgetProvider.select((value) => value.value?.snapshot));
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(title: const Text(S.goalsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (snapshot != null)
            SectionCard(
              child: Text(
                S.goalsSaved(Rupees.format(snapshot.balances[BudgetCategory.goals]!)),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: palette.text),
              ),
            ),
          const SizedBox(height: 16),
          Text(S.goalsLater, style: TextStyle(color: palette.mutedText)),
        ],
      ),
    );
  }
}
