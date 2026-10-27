import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';

import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/budget_snapshot.dart';
import '../../domain/health.dart';
import '../../domain/rupees.dart';
import '../common/widgets.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.view, required this.onOpen, required this.onAdd});

  final CategoryView view;
  final VoidCallback onOpen;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final health = view.health;
    final barColor = health.state == HealthState.neutral ? palette.accent : palette.health(health.state);
    return SectionCard(
      key: Key('card-${view.category.name}'),
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CategoryIcons.of(view.category), size: 18, color: palette.mutedText),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  S.shortCategoryName(view.category),
                  style: textTheme.labelLarge?.copyWith(color: palette.text),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onAdd != null)
                IconButton(
                  key: Key('add-${view.category.name}'),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onAdd,
                )
              else
                const SizedBox(height: 40),
            ],
          ),
          AnimatedMoney(
            view.left,
            key: Key('left-${view.category.name}'),
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: palette.text),
          ),
          if (view.held.isPositive)
            Text(S.heldLine(Rupees.format(view.held)), style: textTheme.labelSmall?.copyWith(color: palette.mutedText)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedBar(permille: view.leftPermille, color: barColor),
          ),
          const SizedBox(height: 6),
          if (view.category == BudgetCategory.goals)
            Text(S.notSpendable, style: textTheme.labelSmall?.copyWith(color: palette.mutedText))
          else
            HealthTag(health: health.state, coveredByFloor: health.coveredByFloor),
        ],
      ),
    );
  }
}
