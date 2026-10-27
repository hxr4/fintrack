import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/rupees.dart';
import '../common/widgets.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider).value;
    final ledger = state?.ledger;
    if (ledger == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final cycle = ledger.cycle;
    return Scaffold(
      appBar: AppBar(title: const Text(S.planTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.cycleDates, style: textTheme.labelLarge?.copyWith(color: palette.mutedText)),
                Text(
                  S.cycleRange(formatDate(cycle.window.start), formatDate(cycle.window.lastDay), cycle.window.length),
                  style: textTheme.titleMedium?.copyWith(color: palette.text),
                ),
                const SizedBox(height: 12),
                Text(S.baseDaily, style: textTheme.labelLarge?.copyWith(color: palette.mutedText)),
                Text(Rupees.format(cycle.baseDaily), style: textTheme.titleMedium?.copyWith(color: palette.text)),
                if (cycle.shortfall.isPositive) ...[
                  const SizedBox(height: 12),
                  Text(S.shortfall, style: textTheme.labelLarge?.copyWith(color: palette.mutedText)),
                  Text(S.shortfallNote(Rupees.format(cycle.shortfall)), style: textTheme.bodyMedium?.copyWith(color: palette.tight)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('money-arrived'),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              useSafeArea: true,
              builder: (_) => const DepositSheet(),
            ),
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text(S.moneyArrived),
          ),
          const SizedBox(height: 24),
          Text(S.planTools, style: textTheme.titleSmall?.copyWith(color: palette.mutedText)),
          const SizedBox(height: 8),
          _ToolTile(
            key: const Key('tool-balance-check'),
            icon: Icons.account_balance_outlined,
            title: S.balanceCheckTitle,
            subtitle: S.balanceCheckHint,
            route: '/balance-check',
          ),
          _ToolTile(
            key: const Key('tool-supplies'),
            icon: Icons.inventory_2_outlined,
            title: S.suppliesAndBike,
            subtitle: S.suppliesAndBikeHint,
            route: '/supplies',
          ),
          _ToolTile(
            key: const Key('tool-budget-values'),
            icon: Icons.tune,
            title: S.budgetValuesTitle,
            subtitle: S.budgetValuesHint2,
            route: '/budget-values',
          ),
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({super.key, required this.icon, required this.title, required this.subtitle, required this.route});

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push(route),
        child: ListTile(
          leading: Icon(icon, color: context.palette.accent),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class DepositSheet extends ConsumerStatefulWidget {
  const DepositSheet({super.key});

  @override
  ConsumerState<DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends ConsumerState<DepositSheet> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  var _kind = DepositKind.installment;
  late CivilDate _date = KolkataTime.dateOf(ref.read(clockProvider)());
  String? _dateError;
  var _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    final state = ref.read(budgetProvider).requireValue;
    final start = state.ledger!.cycle.window.start;
    final today = KolkataTime.dateOf(ref.read(clockProvider)());
    if (_date.isAfter(today)) {
      setState(() => _dateError = S.depositDateInFuture);
      return;
    }
    if (_kind == DepositKind.installment && !_date.isAfter(start)) {
      setState(() => _dateError = S.depositDateTooEarly);
      return;
    }
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await ref.read(budgetProvider.notifier).logDeposit(
          amount: Rupees.parse(_amount.text)!,
          date: _date,
          kind: _kind,
        );
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text(_kind == DepositKind.installment ? S.newCycleStarted : S.extraAdded)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S.moneyArrived, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<DepositKind>(
              segments: const [
                ButtonSegment(value: DepositKind.installment, label: Text(S.depositKindInstallment)),
                ButtonSegment(value: DepositKind.extra, label: Text(S.depositKindExtra)),
              ],
              selected: {_kind},
              onSelectionChanged: (selection) => setState(() => _kind = selection.first),
            ),
            const SizedBox(height: 8),
            Text(S.depositKindHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: S.amount, prefixText: '₹ ', border: OutlineInputBorder()),
              validator: (value) => (Rupees.parse(value ?? '')?.isPositive ?? false) ? null : S.invalidAmount,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(S.depositDate),
              subtitle: Text(_dateError ?? formatDate(_date)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final today = KolkataTime.dateOf(ref.read(clockProvider)());
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(_date.year, _date.month, _date.day),
                  firstDate: DateTime(today.year - 1),
                  lastDate: DateTime(today.year, today.month, today.day),
                );
                if (picked != null) {
                  setState(() {
                    _date = CivilDate(picked.year, picked.month, picked.day);
                    _dateError = null;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _saving ? null : _save, child: const Text(S.save)),
          ],
        ),
      ),
    );
  }
}
