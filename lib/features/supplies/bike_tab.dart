import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/ledger_data.dart';
import '../../domain/rupees.dart';
import '../common/forms.dart';
import '../common/widgets.dart';
import 'supplies_screen.dart';

String tenths(int value) => '${value ~/ 10}.${value % 10}';

String litresText(int millilitres) => S.litres('${millilitres ~/ 1000}.${((millilitres % 1000) ~/ 10).toString().padLeft(2, '0')}');

class BikeTab extends ConsumerWidget {
  const BikeTab({super.key});

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
    final today = snapshot.today;
    final summary = ledger.fuelSummary(today);
    final suggestion = summary.suggestedPerCycle(snapshot.cycleLength);
    final due = ledger.serviceDue(today);
    final recent = [...ledger.fuelFills]..sort((a, b) => b.fill.odometerKm.compareTo(a.fill.odometerKm));
    final muted = textTheme.bodySmall?.copyWith(color: palette.mutedText);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const FundHeader(category: BudgetCategory.bikeFund),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.fuelSummary, style: textTheme.titleMedium),
              const SizedBox(height: 6),
              if (summary.averageKmPerLitreTenths == null)
                Text(S.mileageNeedsTwoFull, style: muted)
              else ...[
                Text(S.mileage(tenths(summary.averageKmPerLitreTenths!)), key: const Key('mileage'), style: textTheme.titleLarge),
                Text(S.latestMileage(tenths(summary.latest!.kmPerLitreTenths)), style: muted),
                Text(S.costPerKm(Rupees.format(summary.averageCostPerKm!, showPaise: true)), style: muted),
              ],
              if (summary.kmPerDayTenths != null) Text(S.kmPerDay(tenths(summary.kmPerDayTenths!)), style: muted),
              if (suggestion != null) ...[
                const SizedBox(height: 6),
                Text(
                  S.petrolSuggestion(Rupees.format(suggestion), Rupees.format(ledger.cycle.petrolFloor)),
                  key: const Key('petrol-suggestion'),
                  style: textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('log-fuel'),
                onPressed: () => _logFuel(context, ref, ledger, state!.preferences.cardEnabled),
                icon: const Icon(Icons.local_gas_station),
                label: const Text(S.logFuel),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.service, style: textTheme.titleMedium),
              const SizedBox(height: 6),
              if (!due.isKnown)
                Text(S.serviceNotSet, style: muted)
              else
                Text(
                  S.serviceDue([
                    if (due.daysLeft != null) S.serviceDueDays(due.daysLeft!),
                    if (due.kmLeft != null) S.serviceDueKm(due.kmLeft!),
                  ].join(', ')),
                  key: const Key('service-due'),
                  style: textTheme.bodyMedium?.copyWith(color: due.isDue ? palette.tight : palette.text),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    key: const Key('edit-service'),
                    onPressed: () => _editService(context, ref, ledger, today),
                    child: const Text(S.editService),
                  ),
                  OutlinedButton(
                    key: const Key('record-service'),
                    onPressed: () => _recordService(context, ref, ledger, state!.preferences.cardEnabled),
                    child: const Text(S.recordService),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.documents, style: textTheme.titleMedium),
              DateTile(
                key: const Key('insurance'),
                label: S.insuranceExpiry,
                date: ledger.bike.insuranceExpiry,
                today: today,
                allowFuture: true,
                onChanged: (date) => ref.read(budgetProvider.notifier).saveBike(
                      BikeProfile(service: ledger.bike.service, insuranceExpiry: date, pucExpiry: ledger.bike.pucExpiry),
                    ),
              ),
              if (ledger.bike.insuranceExpiry != null)
                Text(
                  S.expiresIn(formatDate(ledger.bike.insuranceExpiry!), today.daysUntil(ledger.bike.insuranceExpiry!)),
                  style: muted,
                ),
              DateTile(
                key: const Key('puc'),
                label: S.pucExpiry,
                date: ledger.bike.pucExpiry,
                today: today,
                allowFuture: true,
                onChanged: (date) => ref.read(budgetProvider.notifier).saveBike(
                      BikeProfile(service: ledger.bike.service, insuranceExpiry: ledger.bike.insuranceExpiry, pucExpiry: date),
                    ),
              ),
              if (ledger.bike.pucExpiry != null)
                Text(S.expiresIn(formatDate(ledger.bike.pucExpiry!), today.daysUntil(ledger.bike.pucExpiry!)), style: muted),
            ],
          ),
        ),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(S.recentFills, style: textTheme.titleSmall),
          for (final linked in recent.take(10))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(linked.fill.fullTank ? Icons.local_gas_station : Icons.opacity, color: palette.mutedText),
              title: Text(Rupees.format(linked.fill.amount)),
              subtitle: Text(S.fillLine(
                formatDate(linked.fill.date),
                litresText(linked.fill.litresMl),
                linked.fill.odometerKm,
                linked.fill.fullTank,
              )),
            ),
        ],
      ],
    );
  }

  Future<void> _logFuel(BuildContext context, WidgetRef ref, LedgerData ledger, bool cardEnabled) async {
    final lastFill = ledger.fuelFills.isEmpty
        ? null
        : ledger.fuelFills.reduce((a, b) => a.fill.odometerKm >= b.fill.odometerKm ? a : b).fill;
    final result = await showModalBottomSheet<_FuelInput>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _FuelSheet(
        cardEnabled: cardEnabled,
        lastPrice: lastFill?.pricePerLitre,
        minimumOdometer: ledger.latestOdometer ?? 0,
      ),
    );
    if (result == null) {
      return;
    }
    await ref.read(budgetProvider.notifier).logFuel(
          amount: result.amount,
          pricePerLitre: result.price,
          odometerKm: result.odometer,
          fullTank: result.fullTank,
          method: result.method,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.fuelLogged(Rupees.format(result.amount)))));
    }
  }

  Future<void> _editService(BuildContext context, WidgetRef ref, LedgerData ledger, CivilDate today) async {
    final result = await showModalBottomSheet<BikeServicePlan>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _ServiceSheet(initial: ledger.bike.service, today: today),
    );
    if (result != null) {
      await ref.read(budgetProvider.notifier).saveBike(ledger.bike.withService(result));
    }
  }

  Future<void> _recordService(BuildContext context, WidgetRef ref, LedgerData ledger, bool cardEnabled) async {
    final payment = await showPaymentSheet(
      context,
      title: S.recordService,
      cardEnabled: cardEnabled,
      initial: ledger.bike.service.cost.isPositive ? ledger.bike.service.cost : null,
    );
    if (payment == null || !context.mounted) {
      return;
    }
    final odometer = await showDialog<int>(
      context: context,
      builder: (_) => _OdometerDialog(minimum: ledger.latestOdometer ?? 0),
    );
    if (odometer == null) {
      return;
    }
    await ref.read(budgetProvider.notifier).payService(amount: payment.$1, odometerKm: odometer, method: payment.$2);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(S.serviceLogged)));
    }
  }
}

final class _FuelInput {
  const _FuelInput({required this.amount, required this.price, required this.odometer, required this.fullTank, required this.method});

  final Money amount;
  final Money price;
  final int odometer;
  final bool fullTank;
  final PaymentMethod method;
}

class _FuelSheet extends StatefulWidget {
  const _FuelSheet({required this.cardEnabled, required this.lastPrice, required this.minimumOdometer});

  final bool cardEnabled;
  final Money? lastPrice;
  final int minimumOdometer;

  @override
  State<_FuelSheet> createState() => _FuelSheetState();
}

class _FuelSheetState extends State<_FuelSheet> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  late final _price = TextEditingController(
    text: widget.lastPrice == null ? '' : Rupees.format(widget.lastPrice!, showPaise: true).replaceAll(RegExp('[₹,]'), ''),
  );
  final _odometer = TextEditingController();
  var _full = true;
  var _method = PaymentMethod.upi;

  @override
  void dispose() {
    _amount.dispose();
    _price.dispose();
    _odometer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final methods = [PaymentMethod.cash, PaymentMethod.upi, if (widget.cardEnabled) PaymentMethod.card];
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(S.logFuel, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              MoneyFormField(key: const Key('fuel-amount'), controller: _amount, label: S.amountPaid),
              MoneyFormField(key: const Key('fuel-price'), controller: _price, label: S.pricePerLitre),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  key: const Key('fuel-odometer'),
                  controller: _odometer,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: S.odometer, border: OutlineInputBorder()),
                  validator: (value) {
                    final km = int.tryParse(value ?? '');
                    if (km == null) {
                      return S.invalidNumber;
                    }
                    return km < widget.minimumOdometer ? S.odometerTooLow : null;
                  },
                ),
              ),
              SwitchListTile(
                key: const Key('fuel-full'),
                contentPadding: EdgeInsets.zero,
                title: const Text(S.fullTank),
                value: _full,
                onChanged: (value) => setState(() => _full = value),
              ),
              SegmentedButton<PaymentMethod>(
                segments: [for (final method in methods) ButtonSegment(value: method, label: Text(S.methodName(method)))],
                selected: {_method},
                onSelectionChanged: (selection) => setState(() => _method = selection.first),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('fuel-save'),
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    Navigator.of(context).pop(_FuelInput(
                      amount: Rupees.parse(_amount.text)!,
                      price: Rupees.parse(_price.text)!,
                      odometer: int.parse(_odometer.text),
                      fullTank: _full,
                      method: _method,
                    ));
                  }
                },
                child: const Text(S.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceSheet extends StatefulWidget {
  const _ServiceSheet({required this.initial, required this.today});

  final BikeServicePlan initial;
  final CivilDate today;

  @override
  State<_ServiceSheet> createState() => _ServiceSheetState();
}

class _ServiceSheetState extends State<_ServiceSheet> {
  final _form = GlobalKey<FormState>();
  late final _intervalKm = TextEditingController(text: '${widget.initial.intervalKm ?? ''}');
  late final _intervalMonths = TextEditingController(text: '${widget.initial.intervalMonths ?? ''}');
  late final _cost = TextEditingController(
    text: widget.initial.cost.isPositive ? Rupees.plain(widget.initial.cost).replaceAll(',', '') : '0',
  );
  late final _lastKm = TextEditingController(text: '${widget.initial.lastServiceKm ?? ''}');
  late CivilDate? _lastDate = widget.initial.lastServiceDate;

  @override
  void dispose() {
    for (final controller in [_intervalKm, _intervalMonths, _cost, _lastKm]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(S.editService, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              NumberFormField(
                key: const Key('service-interval-km'),
                controller: _intervalKm,
                label: S.serviceIntervalKm,
                helper: S.optionalNumber,
                optional: true,
              ),
              NumberFormField(controller: _intervalMonths, label: S.serviceIntervalMonths, helper: S.optionalNumber, optional: true),
              MoneyFormField(key: const Key('service-cost'), controller: _cost, label: S.serviceCost, allowZero: true),
              NumberFormField(
                key: const Key('service-last-km'),
                controller: _lastKm,
                label: S.lastServiceKm,
                helper: S.optionalNumber,
                optional: true,
                minimum: 0,
              ),
              DateTile(
                label: S.lastServiceDate,
                date: _lastDate,
                today: widget.today,
                onChanged: (date) => setState(() => _lastDate = date),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('service-save'),
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    Navigator.of(context).pop(BikeServicePlan(
                      intervalKm: int.tryParse(_intervalKm.text.trim()),
                      intervalMonths: int.tryParse(_intervalMonths.text.trim()),
                      cost: Rupees.parse(_cost.text) ?? Money.zero,
                      lastServiceKm: int.tryParse(_lastKm.text.trim()),
                      lastServiceDate: _lastDate,
                    ));
                  }
                },
                child: const Text(S.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OdometerDialog extends StatefulWidget {
  const _OdometerDialog({required this.minimum});

  final int minimum;

  @override
  State<_OdometerDialog> createState() => _OdometerDialogState();
}

class _OdometerDialogState extends State<_OdometerDialog> {
  final _form = GlobalKey<FormState>();
  final _odometer = TextEditingController();

  @override
  void dispose() {
    _odometer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(S.odometer),
      content: Form(
        key: _form,
        child: TextFormField(
          key: const Key('service-odometer'),
          controller: _odometer,
          keyboardType: TextInputType.number,
          validator: (value) {
            final km = int.tryParse(value ?? '');
            if (km == null) {
              return S.invalidNumber;
            }
            return km < widget.minimum ? S.odometerTooLow : null;
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(S.cancel)),
        FilledButton(
          key: const Key('service-odometer-save'),
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.of(context).pop(int.parse(_odometer.text));
            }
          },
          child: const Text(S.save),
        ),
      ],
    );
  }
}
