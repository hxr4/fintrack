import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/rupees.dart';
import '../common/forms.dart';

class BudgetValuesScreen extends ConsumerStatefulWidget {
  const BudgetValuesScreen({super.key});

  @override
  ConsumerState<BudgetValuesScreen> createState() => _BudgetValuesScreenState();
}

class _BudgetValuesScreenState extends ConsumerState<BudgetValuesScreen> {
  final _form = GlobalKey<FormState>();
  late final BudgetSettings _initial = ref.read(budgetProvider).requireValue.settings!;
  late final _food = TextEditingController(text: _plain(_initial.foodFloorPerDay));
  late final _petrol = TextEditingController(text: _plain(_initial.petrolFloorPerCycle));
  late final _night = TextEditingController(text: _plain(_initial.nightFoodStockTarget));
  late final _anchor = TextEditingController(text: '${_initial.anchorDay}');
  late final Map<BudgetCategory, int> _weights = {
    for (final category in BudgetCategory.weighted) category: _initial.defaultWeights[category] ~/ 100,
  };
  var _saving = false;

  static String _plain(Money money) => Rupees.plain(money).replaceAll(',', '');

  int get _total => _weights.values.fold(0, (sum, value) => sum + value);

  @override
  void dispose() {
    for (final controller in [_food, _petrol, _night, _anchor]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _total != 100) {
      return;
    }
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final weightsChanged = BudgetCategory.weighted.any((category) => _initial.defaultWeights[category] != _weights[category]! * 100);
    await ref.read(budgetProvider.notifier).updateBudgetValues(_initial.copyWith(
          foodFloorPerDay: Rupees.parse(_food.text),
          petrolFloorPerCycle: Rupees.parse(_petrol.text),
          nightFoodStockTarget: Rupees.parse(_night.text),
          anchorDay: int.parse(_anchor.text),
          defaultWeights: weightsChanged ? CategoryWeights.fromPercent(_weights) : _initial.defaultWeights,
        ));
    messenger.showSnackBar(const SnackBar(content: Text(S.budgetValuesSaved)));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(title: const Text(S.budgetValuesTitle)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(S.budgetValuesNote, style: TextStyle(color: palette.mutedText)),
            const SizedBox(height: 16),
            MoneyFormField(key: const Key('values-food'), controller: _food, label: S.foodFloorLabel),
            MoneyFormField(key: const Key('values-petrol'), controller: _petrol, label: S.petrolFloorLabel, allowZero: true),
            MoneyFormField(key: const Key('values-night'), controller: _night, label: S.nightFoodLabel, allowZero: true),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                key: const Key('values-anchor'),
                controller: _anchor,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: S.anchorDayLabel, border: OutlineInputBorder()),
                validator: (value) {
                  final day = int.tryParse(value ?? '');
                  return day == null || day < 1 || day > 31 ? S.invalidDay : null;
                },
              ),
            ),
            Text(S.weightsTitle, style: Theme.of(context).textTheme.titleSmall),
            for (final entry in _weights.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(S.categoryName(entry.key)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: entry.value == 0 ? null : () => setState(() => _weights[entry.key] = entry.value - 1),
                    ),
                    SizedBox(width: 32, child: Text('${entry.value}', textAlign: TextAlign.center)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => _weights[entry.key] = entry.value + 1),
                    ),
                  ],
                ),
              ),
            Text(
              _total == 100 ? S.weightsTotal(_total) : '${S.weightsTotal(_total)}. ${S.weightsMustBe100}',
              style: TextStyle(color: _total == 100 ? palette.mutedText : palette.tight),
            ),
            const SizedBox(height: 16),
            FilledButton(key: const Key('values-save'), onPressed: _saving ? null : _save, child: const Text(S.save)),
          ],
        ),
      ),
    );
  }
}
