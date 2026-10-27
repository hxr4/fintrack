import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';

import '../../app/strings.dart';
import '../../domain/cycle_planning.dart';
import '../../domain/rupees.dart';
import 'forms.dart';

String _plain(Money money) => Rupees.plain(money).replaceAll(',', '');

class RecurringDialog extends StatefulWidget {
  const RecurringDialog({super.key, this.initial});

  final RecurringDraft? initial;

  @override
  State<RecurringDialog> createState() => _RecurringDialogState();
}

class _RecurringDialogState extends State<RecurringDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _amount = TextEditingController(text: widget.initial == null ? '' : _plain(widget.initial!.amount));
  late final _months = TextEditingController(text: '${widget.initial?.everyMonths ?? 1}');

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _months.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? S.addRecurring : S.editRecurring),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('recurring-name'),
                controller: _name,
                decoration: const InputDecoration(labelText: S.name),
                validator: (value) => (value ?? '').trim().isEmpty ? S.required : null,
              ),
              TextFormField(
                key: const Key('recurring-amount'),
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: S.amount, prefixText: '₹ '),
                validator: validateMoney,
              ),
              TextFormField(
                controller: _months,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: S.everyMonths),
                validator: validateWholeNumber,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(S.cancel)),
        FilledButton(
          key: const Key('recurring-save'),
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.of(context).pop(RecurringDraft(
                name: _name.text.trim(),
                amount: Rupees.parse(_amount.text)!,
                everyMonths: int.parse(_months.text),
              ));
            }
          },
          child: Text(widget.initial == null ? S.add : S.save),
        ),
      ],
    );
  }
}

class SupplyDialog extends StatefulWidget {
  const SupplyDialog({super.key, required this.today, this.initial});

  final CivilDate today;
  final SupplyDraft? initial;

  @override
  State<SupplyDialog> createState() => _SupplyDialogState();
}

class _SupplyDialogState extends State<SupplyDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _price = TextEditingController(text: widget.initial == null ? '' : _plain(widget.initial!.price));
  late final _days = TextEditingController(text: '${widget.initial?.lifespanDays ?? 30}');
  late CivilDate _lastRestock = widget.initial?.lastRestock ?? widget.today;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _days.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? S.addSupply : S.editSupply),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('supply-name'),
                controller: _name,
                decoration: const InputDecoration(labelText: S.name),
                validator: (value) => (value ?? '').trim().isEmpty ? S.required : null,
              ),
              TextFormField(
                key: const Key('supply-price'),
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: S.price, prefixText: '₹ '),
                validator: validateMoney,
              ),
              TextFormField(
                key: const Key('supply-days'),
                controller: _days,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: S.lifespanDays),
                validator: validateWholeNumber,
              ),
              DateTile(
                label: S.lastRestock,
                date: _lastRestock,
                today: widget.today,
                onChanged: (date) => setState(() => _lastRestock = date),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(S.cancel)),
        FilledButton(
          key: const Key('supply-save'),
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.of(context).pop(SupplyDraft(
                name: _name.text.trim(),
                price: Rupees.parse(_price.text)!,
                lifespanDays: int.parse(_days.text),
                lastRestock: _lastRestock,
              ));
            }
          },
          child: Text(widget.initial == null ? S.add : S.save),
        ),
      ],
    );
  }
}
