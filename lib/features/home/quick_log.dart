import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../domain/category_prediction.dart';
import '../../domain/log_parser.dart';
import '../../domain/rupees.dart';
import '../add/add_sheet.dart';
import '../add/logging.dart';

class QuickAddChips extends ConsumerWidget {
  const QuickAddChips({super.key, required this.predicted});

  final BudgetCategory predicted;

  static final amounts = [Money.rupees(40), Money.rupees(100)];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final amount in amounts)
          GestureDetector(
            onLongPress: () => showAddSheet(context, amount: amount, category: predicted),
            child: ActionChip(
              key: Key('chip-${amount.paise ~/ 100}'),
              label: Text(S.quickChip(Rupees.plain(amount), predicted)),
              onPressed: () => logAndConfirm(
                context,
                ref,
                amount: amount,
                category: predicted,
                source: TransactionSource.quickAdd,
              ),
            ),
          ),
        ActionChip(
          key: const Key('chip-custom'),
          avatar: const Icon(Icons.dialpad, size: 18),
          label: const Text(S.custom),
          onPressed: () => showAddSheet(context, category: predicted),
        ),
      ],
    );
  }
}

class TypeToLogBar extends ConsumerStatefulWidget {
  const TypeToLogBar({super.key});

  @override
  ConsumerState<TypeToLogBar> createState() => _TypeToLogBarState();
}

class _TypeToLogBarState extends ConsumerState<TypeToLogBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  ParsedEntry? _parsed;
  BudgetCategory? _category;
  BudgetCategory? _guess;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String text) {
    final state = ref.read(budgetProvider).requireValue;
    final parsed = LogParser.parse(text, learned: state.ledger!.learnedKeywords);
    setState(() {
      if (parsed == null) {
        _error = S.typeToLogNotUnderstood;
        _parsed = null;
        return;
      }
      _error = null;
      _parsed = parsed;
      _guess = parsed.category ?? state.snapshot!.predictedCategory;
      _category = _guess;
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _parsed = null;
      _category = null;
      _guess = null;
      _error = null;
    });
  }

  Future<void> _confirm() async {
    final parsed = _parsed;
    final category = _category;
    if (parsed == null || category == null) {
      return;
    }
    final learn = category != _guess ? parsed.keyword : null;
    _clear();
    _focus.unfocus();
    await logAndConfirm(
      context,
      ref,
      amount: parsed.amount,
      category: category,
      source: TransactionSource.typed,
      note: parsed.note,
      learnKeyword: learn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parsed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('type-to-log'),
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: S.typeToLogHint,
            prefixIcon: const Icon(Icons.edit_note),
            errorText: _error,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onSubmitted: _submit,
        ),
        if (parsed != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InputChip(
                key: const Key('confirm-chip'),
                label: Text(S.parsedChip(Rupees.format(parsed.amount), _category!)),
                onPressed: _pickCategory,
              ),
              FilledButton(key: const Key('confirm-save'), onPressed: _confirm, child: const Text(S.confirm)),
              TextButton(onPressed: _clear, child: const Text(S.cancel)),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _pickCategory() async {
    final picked = await showModalBottomSheet<BudgetCategory>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final category in CategoryPrediction.loggable)
              ListTile(
                title: Text(S.categoryName(category)),
                selected: category == _category,
                onTap: () => Navigator.of(context).pop(category),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() => _category = picked);
    }
  }
}
