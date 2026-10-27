import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/cycle_planning.dart';
import '../../domain/ledger_data.dart';
import '../../domain/rupees.dart';
import '../common/forms.dart';
import '../common/item_dialogs.dart';
import '../common/widgets.dart';
import 'bike_tab.dart';

class SuppliesScreen extends StatelessWidget {
  const SuppliesScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(S.suppliesAndBike),
          bottom: const TabBar(
            tabs: [
              Tab(key: Key('tab-supplies'), text: S.tabSupplies),
              Tab(key: Key('tab-bike'), text: S.tabBike),
              Tab(key: Key('tab-recurring'), text: S.tabRecurring),
            ],
          ),
        ),
        body: const TabBarView(children: [SuppliesTab(), BikeTab(), RecurringTab()]),
      ),
    );
  }
}

class FundHeader extends ConsumerWidget {
  const FundHeader({super.key, required this.category});

  final BudgetCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(budgetProvider.select((value) => value.value?.snapshot));
    if (snapshot == null) {
      return const SizedBox.shrink();
    }
    final balance = snapshot.balances[category]! - snapshot.held[category]!;
    return SectionCard(
      child: Row(
        children: [
          Icon(CategoryIcons.of(category), color: context.palette.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              S.fundLeft(S.categoryName(category), Rupees.format(balance)),
              key: Key('fund-${category.name}'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class SuppliesTab extends ConsumerWidget {
  const SuppliesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider).value;
    final ledger = state?.ledger;
    final snapshot = state?.snapshot;
    if (ledger == null || snapshot == null) {
      return const SizedBox.shrink();
    }
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final items = [...ledger.supplies]..sort((a, b) => a.state.daysLeftOn(snapshot.today).compareTo(b.state.daysLeftOn(snapshot.today)));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const FundHeader(category: BudgetCategory.essentialsStock),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(S.noSupplies, style: TextStyle(color: palette.mutedText)),
          ),
        for (final supply in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SectionCard(
              key: Key('supply-${supply.name}'),
              onTap: () => _actions(context, ref, supply, snapshot.today, state!.preferences.cardEnabled),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(supply.name, style: textTheme.titleMedium)),
                      Text(S.daysLeftLabel(supply.state.daysLeftOn(snapshot.today)), style: textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AnimatedBar(
                    permille: (supply.state.daysLeftOn(snapshot.today) * 1000 ~/ supply.state.lifespanDays).clamp(0, 1000),
                    color: supply.state.daysLeftOn(snapshot.today) == 0 ? palette.tight : palette.accent,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${S.savedOf(Rupees.format(supply.state.saved), Rupees.format(supply.state.price))} · ${S.lifespanLine(supply.state.lifespanDays)}',
                    style: textTheme.bodySmall?.copyWith(color: palette.mutedText),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('add-supply'),
          onPressed: () => _add(context, ref, snapshot.today),
          icon: const Icon(Icons.add),
          label: const Text(S.addSupply),
        ),
        const SizedBox(height: 8),
        Text(S.newItemsNextCycle, style: textTheme.bodySmall?.copyWith(color: palette.mutedText)),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, CivilDate today) async {
    final draft = await showDialog<SupplyDraft>(context: context, builder: (_) => SupplyDialog(today: today));
    if (draft == null) {
      return;
    }
    final controller = ref.read(budgetProvider.notifier);
    await controller.upsertSupply(NamedSupply(
      name: draft.name,
      state: SupplyItemState(
        id: controller.newId('supply'),
        price: draft.price,
        lifespanDays: draft.lifespanDays,
        lastRestock: draft.lastRestock,
      ),
    ));
  }

  Future<void> _actions(BuildContext context, WidgetRef ref, NamedSupply supply, CivilDate today, bool cardEnabled) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('supply-restocked'),
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text(S.restocked),
              onTap: () => Navigator.of(context).pop('restock'),
            ),
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text(S.edit), onTap: () => Navigator.of(context).pop('edit')),
            ListTile(leading: const Icon(Icons.delete_outline), title: const Text(S.delete), onTap: () => Navigator.of(context).pop('delete')),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) {
      return;
    }
    final controller = ref.read(budgetProvider.notifier);
    switch (choice) {
      case 'restock':
        final payment = await showPaymentSheet(context, title: supply.name, cardEnabled: cardEnabled, initial: supply.state.price);
        if (payment == null) {
          return;
        }
        await controller.restock(supplyId: supply.state.id, paid: payment.$1, method: payment.$2);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.restockLogged(supply.name))));
        }
      case 'edit':
        final draft = await showDialog<SupplyDraft>(
          context: context,
          builder: (_) => SupplyDialog(
            today: today,
            initial: SupplyDraft(
              name: supply.name,
              price: supply.state.price,
              lifespanDays: supply.state.lifespanDays,
              lastRestock: supply.state.lastRestock,
            ),
          ),
        );
        if (draft != null) {
          await controller.upsertSupply(NamedSupply(
            name: draft.name,
            state: supply.state.copyWith(
              price: draft.price,
              lifespanDays: draft.lifespanDays,
              lastRestock: draft.lastRestock,
              saved: supply.state.saved.atMost(draft.price),
            ),
          ));
        }
      case 'delete':
        await controller.deleteSupply(supply.state.id);
    }
  }
}

class RecurringTab extends ConsumerWidget {
  const RecurringTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider).value;
    final ledger = state?.ledger;
    if (ledger == null) {
      return const SizedBox.shrink();
    }
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const FundHeader(category: BudgetCategory.recurringFund),
        const SizedBox(height: 12),
        if (ledger.recurring.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(S.noRecurring, style: TextStyle(color: palette.mutedText)),
          ),
        for (final cost in ledger.recurring)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SectionCard(
              padding: EdgeInsets.zero,
              onTap: () => _actions(context, ref, cost, state!.preferences.cardEnabled),
              child: ListTile(
                title: Text(cost.name),
                subtitle: Text(
                  '${S.recurringLine(Rupees.format(cost.state.amount), cost.state.everyMonths)} · '
                  '${S.perCycle(Rupees.format(cost.state.amount.ceilDiv(cost.state.everyMonths)))}',
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('add-recurring'),
          onPressed: () => _add(context, ref),
          icon: const Icon(Icons.add),
          label: const Text(S.addRecurring),
        ),
        const SizedBox(height: 8),
        Text(S.newItemsNextCycle, style: textTheme.bodySmall?.copyWith(color: palette.mutedText)),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final draft = await showDialog<RecurringDraft>(context: context, builder: (_) => const RecurringDialog());
    if (draft == null) {
      return;
    }
    final controller = ref.read(budgetProvider.notifier);
    await controller.upsertRecurring(NamedRecurringCost(
      name: draft.name,
      state: RecurringCostState(id: controller.newId('recurring'), amount: draft.amount, everyMonths: draft.everyMonths),
    ));
  }

  Future<void> _actions(BuildContext context, WidgetRef ref, NamedRecurringCost cost, bool cardEnabled) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.payments_outlined), title: const Text(S.paid), onTap: () => Navigator.of(context).pop('paid')),
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text(S.edit), onTap: () => Navigator.of(context).pop('edit')),
            ListTile(leading: const Icon(Icons.delete_outline), title: const Text(S.delete), onTap: () => Navigator.of(context).pop('delete')),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) {
      return;
    }
    final controller = ref.read(budgetProvider.notifier);
    switch (choice) {
      case 'paid':
        final payment = await showPaymentSheet(context, title: cost.name, cardEnabled: cardEnabled, initial: cost.state.amount);
        if (payment == null) {
          return;
        }
        await controller.payRecurring(costId: cost.state.id, amount: payment.$1, method: payment.$2);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.recurringPaid(cost.name))));
        }
      case 'edit':
        final draft = await showDialog<RecurringDraft>(
          context: context,
          builder: (_) => RecurringDialog(
            initial: RecurringDraft(name: cost.name, amount: cost.state.amount, everyMonths: cost.state.everyMonths),
          ),
        );
        if (draft != null) {
          await controller.upsertRecurring(NamedRecurringCost(
            name: draft.name,
            state: RecurringCostState(id: cost.state.id, amount: draft.amount, everyMonths: draft.everyMonths),
          ));
        }
      case 'delete':
        await controller.deleteRecurring(cost.state.id);
    }
  }
}
