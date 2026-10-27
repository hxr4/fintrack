import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/rupees.dart';
import '../common/forms.dart';
import '../common/widgets.dart';

class BalanceCheckScreen extends ConsumerStatefulWidget {
  const BalanceCheckScreen({super.key});

  @override
  ConsumerState<BalanceCheckScreen> createState() => _BalanceCheckScreenState();
}

class _BalanceCheckScreenState extends ConsumerState<BalanceCheckScreen> {
  final _form = GlobalKey<FormState>();
  final _bank = TextEditingController();
  final _cash = TextEditingController(text: '0');
  late final TextEditingController _excluded;
  BalanceComparison? _comparison;
  ReportedBalance? _reported;
  var _resolution = BalanceResolution.unlogged;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    final anchor = ref.read(budgetProvider).requireValue.ledger?.latestAnchor;
    _excluded = TextEditingController(
      text: anchor == null ? '0' : Rupees.plain(anchor.excluded).replaceAll(',', ''),
    );
  }

  @override
  void dispose() {
    _bank.dispose();
    _cash.dispose();
    _excluded.dispose();
    super.dispose();
  }

  Future<void> _compare() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    final reported = ReportedBalance(
      at: ref.read(clockProvider)(),
      bank: Rupees.parse(_bank.text)!,
      cash: Rupees.parse(_cash.text)!,
      excluded: Rupees.parse(_excluded.text)!,
    );
    final comparison = await ref.read(budgetProvider.notifier).previewBalance(reported);
    setState(() {
      _reported = reported;
      _comparison = comparison ?? BalanceComparison(reported: reported, expected: reported.budgetTotal, actual: reported.budgetTotal);
    });
  }

  Future<void> _apply() async {
    final reported = _reported;
    if (reported == null) {
      return;
    }
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref.read(budgetProvider.notifier).applyBalanceCheck(
          reported: reported,
          resolution: _comparison!.matches ? BalanceResolution.unlogged : _resolution,
        );
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(outcome.uncovered.isPositive ? S.balanceUncovered(Rupees.format(outcome.uncovered)) : S.balanceUpdated),
    ));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final anchor = ref.watch(budgetProvider.select((value) => value.value?.ledger?.latestAnchor));
    final comparison = _comparison;
    return Scaffold(
      appBar: AppBar(title: const Text(S.balanceCheckTitle)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(S.balanceCheckIntro, style: textTheme.bodyMedium?.copyWith(color: palette.mutedText)),
            if (anchor != null) ...[
              const SizedBox(height: 4),
              Text(S.lastChecked(formatDate(KolkataTime.dateOf(anchor.at))), style: textTheme.bodySmall?.copyWith(color: palette.mutedText)),
            ],
            const SizedBox(height: 16),
            MoneyFormField(key: const Key('check-bank'), controller: _bank, label: S.bankBalance, allowZero: true),
            MoneyFormField(key: const Key('check-cash'), controller: _cash, label: S.cashInHand, allowZero: true),
            MoneyFormField(
              key: const Key('check-excluded'),
              controller: _excluded,
              label: S.excludedAmount,
              helper: S.excludedHint,
              allowZero: true,
            ),
            FilledButton.tonal(key: const Key('check-compare'), onPressed: _compare, child: const Text(S.compare)),
            if (comparison != null) ...[
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(S.expected, style: textTheme.labelLarge?.copyWith(color: palette.mutedText))),
                        Text(Rupees.format(comparison.expected), style: textTheme.titleMedium),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: Text(S.actual, style: textTheme.labelLarge?.copyWith(color: palette.mutedText))),
                        Text(Rupees.format(comparison.actual), style: textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comparison.matches
                          ? S.balanceMatches
                          : (comparison.isShort
                              ? S.balanceLower(Rupees.format(-comparison.difference))
                              : S.balanceHigher(Rupees.format(comparison.difference))),
                      key: const Key('check-result'),
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (!comparison.matches) ...[
                const SizedBox(height: 8),
                RadioGroup<BalanceResolution>(
                  groupValue: _resolution,
                  onChanged: (value) => setState(() => _resolution = value ?? _resolution),
                  child: const Column(
                    children: [
                      RadioListTile<BalanceResolution>(
                        key: Key('resolve-unlogged'),
                        value: BalanceResolution.unlogged,
                        title: Text(S.resolveUnlogged),
                        subtitle: Text(S.resolveUnloggedHint),
                      ),
                      RadioListTile<BalanceResolution>(
                        key: Key('resolve-distribute'),
                        value: BalanceResolution.distribute,
                        title: Text(S.resolveDistribute),
                        subtitle: Text(S.resolveDistributeHint),
                      ),
                      RadioListTile<BalanceResolution>(
                        key: Key('resolve-ignore'),
                        value: BalanceResolution.ignore,
                        title: Text(S.resolveIgnore),
                        subtitle: Text(S.resolveIgnoreHint),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              FilledButton(key: const Key('check-apply'), onPressed: _busy ? null : _apply, child: const Text(S.apply)),
            ],
          ],
        ),
      ),
    );
  }
}
