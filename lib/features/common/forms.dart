import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';

import '../../app/strings.dart';
import '../../domain/rupees.dart';
import 'widgets.dart';

String? validateMoney(String? value, {bool allowZero = false}) {
  final parsed = Rupees.parse(value ?? '');
  if (parsed == null || (!allowZero && !parsed.isPositive)) {
    return S.invalidAmount;
  }
  return null;
}

String? validateWholeNumber(String? value, {int minimum = 1, bool optional = false}) {
  final text = (value ?? '').trim();
  if (optional && text.isEmpty) {
    return null;
  }
  final parsed = int.tryParse(text);
  return parsed == null || parsed < minimum ? S.invalidNumber : null;
}

class MoneyFormField extends StatelessWidget {
  const MoneyFormField({
    super.key,
    required this.controller,
    required this.label,
    this.helper,
    this.allowZero = false,
  });

  final TextEditingController controller;
  final String label;
  final String? helper;
  final bool allowZero;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, helperText: helper, prefixText: '₹ ', border: const OutlineInputBorder()),
        validator: (value) => validateMoney(value, allowZero: allowZero),
      ),
    );
  }
}

class NumberFormField extends StatelessWidget {
  const NumberFormField({
    super.key,
    required this.controller,
    required this.label,
    this.helper,
    this.optional = false,
    this.minimum = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? helper;
  final bool optional;
  final int minimum;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, helperText: helper, border: const OutlineInputBorder()),
        validator: (value) => validateWholeNumber(value, minimum: minimum, optional: optional),
      ),
    );
  }
}

class DateTile extends StatelessWidget {
  const DateTile({
    super.key,
    required this.label,
    required this.date,
    required this.today,
    required this.onChanged,
    this.allowFuture = false,
  });

  final String label;
  final CivilDate? date;
  final CivilDate today;
  final ValueChanged<CivilDate> onChanged;
  final bool allowFuture;

  @override
  Widget build(BuildContext context) {
    final shown = date;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(shown == null ? S.notSet : formatDate(shown)),
      trailing: const Icon(Icons.calendar_today_outlined),
      onTap: () async {
        final initial = shown ?? today;
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(initial.year, initial.month, initial.day),
          firstDate: DateTime(today.year - 3),
          lastDate: allowFuture ? DateTime(today.year + 5) : DateTime(today.year, today.month, today.day),
        );
        if (picked != null) {
          onChanged(CivilDate(picked.year, picked.month, picked.day));
        }
      },
    );
  }
}

Future<(Money, PaymentMethod)?> showPaymentSheet(
  BuildContext context, {
  required String title,
  required bool cardEnabled,
  Money? initial,
}) {
  return showModalBottomSheet<(Money, PaymentMethod)>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => _PaymentSheet(title: title, cardEnabled: cardEnabled, initial: initial),
  );
}

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({required this.title, required this.cardEnabled, this.initial});

  final String title;
  final bool cardEnabled;
  final Money? initial;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(text: widget.initial == null ? '' : Rupees.plain(widget.initial!).replaceAll(',', ''));
  var _method = PaymentMethod.upi;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final methods = [PaymentMethod.cash, PaymentMethod.upi, if (widget.cardEnabled) PaymentMethod.card];
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            MoneyFormField(key: const Key('payment-amount'), controller: _amount, label: S.amountPaid),
            SegmentedButton<PaymentMethod>(
              segments: [for (final method in methods) ButtonSegment(value: method, label: Text(S.methodName(method)))],
              selected: {_method},
              onSelectionChanged: (selection) => setState(() => _method = selection.first),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('payment-save'),
              onPressed: () {
                if (_form.currentState!.validate()) {
                  Navigator.of(context).pop((Rupees.parse(_amount.text)!, _method));
                }
              },
              child: const Text(S.save),
            ),
          ],
        ),
      ),
    );
  }
}
