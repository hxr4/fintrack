import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/category_prediction.dart';
import '../../domain/rupees.dart';
import 'logging.dart';

Future<void> showAddSheet(
  BuildContext context, {
  Money? amount,
  BudgetCategory? category,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => AddSheet(initialAmount: amount, initialCategory: category),
  );
}

class AddSheet extends ConsumerStatefulWidget {
  const AddSheet({super.key, this.initialAmount, this.initialCategory});

  final Money? initialAmount;
  final BudgetCategory? initialCategory;

  @override
  ConsumerState<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends ConsumerState<AddSheet> {
  late String _digits;
  late BudgetCategory _category;
  late PaymentMethod _method;
  final _note = TextEditingController();
  var _showNote = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(budgetProvider).requireValue;
    final initial = widget.initialAmount;
    _digits = initial == null ? '' : '${initial.paise ~/ 100}';
    _category = widget.initialCategory ?? state.snapshot!.predictedCategory;
    _method = lastUsedMethod(state);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Money? get _amount => _digits.isEmpty ? null : Money.rupees(int.parse(_digits));

  void _press(String key) {
    setState(() {
      if (key == 'back') {
        if (_digits.isNotEmpty) {
          _digits = _digits.substring(0, _digits.length - 1);
        }
      } else if (_digits.length + key.length <= 6) {
        _digits = _digits.isEmpty && key.startsWith('0') ? '' : '$_digits$key';
      }
    });
  }

  Future<void> _save() async {
    final amount = _amount;
    if (amount == null || !amount.isPositive || _saving) {
      return;
    }
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    await logAndConfirm(
      context,
      ref,
      amount: amount,
      category: _category,
      method: _method,
      source: TransactionSource.manual,
      note: _note.text.trim(),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cardEnabled = ref.watch(budgetProvider.select((value) => value.value?.preferences.cardEnabled ?? false));
    final methods = [PaymentMethod.cash, PaymentMethod.upi, if (cardEnabled) PaymentMethod.card];
    if (!methods.contains(_method)) {
      _method = PaymentMethod.upi;
    }
    final amount = _amount;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S.addTitle, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              amount == null ? '₹0' : Rupees.format(amount),
              key: const Key('add-amount'),
              textAlign: TextAlign.center,
              style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600, color: palette.text),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in CategoryPrediction.loggable)
                  ChoiceChip(
                    key: Key('add-category-${category.name}'),
                    avatar: Icon(CategoryIcons.of(category), size: 18),
                    label: Text(S.shortCategoryName(category)),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<PaymentMethod>(
              segments: [
                for (final method in methods)
                  ButtonSegment(value: method, label: Text(S.methodName(method), key: Key('method-${method.name}'))),
              ],
              selected: {_method},
              onSelectionChanged: (selection) => setState(() => _method = selection.first),
            ),
            const SizedBox(height: 8),
            if (_showNote)
              TextField(
                controller: _note,
                decoration: const InputDecoration(labelText: S.note, hintText: S.noteHint),
                textCapitalization: TextCapitalization.sentences,
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showNote = true),
                  icon: const Icon(Icons.notes),
                  label: const Text(S.note),
                ),
              ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              children: [
                for (final key in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '00', '0', 'back'])
                  TextButton(
                    key: Key('pad-$key'),
                    onPressed: key == '00' && _digits.isEmpty ? null : () => _press(key),
                    child: key == 'back'
                        ? const Icon(Icons.backspace_outlined)
                        : Text(key, style: textTheme.headlineSmall),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('add-save'),
              onPressed: amount != null && amount.isPositive && !_saving ? _save : null,
              child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text(S.save)),
            ),
          ],
        ),
      ),
    );
  }
}
