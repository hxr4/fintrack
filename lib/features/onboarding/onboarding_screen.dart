import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/cycle_planning.dart';
import '../../domain/rupees.dart';
import '../common/widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const stepCount = 8;

  final _pages = PageController();
  final _forms = List.generate(stepCount, (_) => GlobalKey<FormState>());
  var _step = 0;
  var _saving = false;

  final _deposit = TextEditingController();
  final _anchorDay = TextEditingController(text: '5');
  final _foodFloor = TextEditingController(text: '150');
  final _petrolFloor = TextEditingController(text: '1200');
  final _nightFood = TextEditingController(text: '750');
  final _bank = TextEditingController();
  final _cash = TextEditingController(text: '0');
  final _excluded = TextEditingController(text: '0');
  late CivilDate _depositDate;
  final _weights = <BudgetCategory, int>{
    BudgetCategory.food: 60,
    BudgetCategory.petrol: 14,
    BudgetCategory.outings: 9,
    BudgetCategory.trySomethingNew: 4,
    BudgetCategory.misc: 3,
    BudgetCategory.buffer: 10,
  };
  final _recurring = <RecurringDraft>[];
  final _supplies = <SupplyDraft>[];
  var _cardEnabled = false;

  CivilDate get _today => KolkataTime.dateOf(ref.read(clockProvider)());

  @override
  void initState() {
    super.initState();
    _depositDate = _today;
  }

  @override
  void dispose() {
    _pages.dispose();
    for (final controller in [_deposit, _anchorDay, _foodFloor, _petrolFloor, _nightFood, _bank, _cash, _excluded]) {
      controller.dispose();
    }
    super.dispose();
  }

  int get _weightTotal => _weights.values.fold(0, (sum, value) => sum + value);

  Future<void> _next() async {
    final form = _forms[_step].currentState;
    if (form != null && !form.validate()) {
      return;
    }
    if (_step == 3 && _weightTotal != 100) {
      return;
    }
    if (_step == stepCount - 1) {
      await _finish();
      return;
    }
    setState(() => _step += 1);
    await _pages.animateToPage(_step, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _back() async {
    if (_step == 0) {
      return;
    }
    setState(() => _step -= 1);
    await _pages.animateToPage(_step, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final input = OnboardingInput(
      deposit: Rupees.parse(_deposit.text)!,
      depositDate: _depositDate,
      anchorDay: int.parse(_anchorDay.text),
      foodFloorPerDay: Rupees.parse(_foodFloor.text)!,
      petrolFloorPerCycle: Rupees.parse(_petrolFloor.text)!,
      nightFoodStock: Rupees.parse(_nightFood.text)!,
      weights: CategoryWeights.fromPercent(_weights),
      bank: Rupees.parse(_bank.text) ?? Money.zero,
      cash: Rupees.parse(_cash.text) ?? Money.zero,
      excluded: Rupees.parse(_excluded.text) ?? Money.zero,
      recurring: List.of(_recurring),
      supplies: List.of(_supplies),
      cardEnabled: _cardEnabled,
    );
    await ref.read(budgetProvider.notifier).completeOnboarding(input);
    ref.read(lockProvider.notifier).unlock();
  }

  String? _money(String? value, {bool allowZero = false}) {
    final parsed = Rupees.parse(value ?? '');
    if (parsed == null) {
      return S.invalidAmount;
    }
    if (!allowZero && !parsed.isPositive) {
      return S.invalidAmount;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _welcome(),
      _depositStep(),
      _floorsStep(),
      _weightsStep(),
      _balancesStep(),
      _recurringStep(),
      _suppliesStep(),
      _paymentsStep(),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / stepCount),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var index = 0; index < steps.length; index++)
                    Form(
                      key: _forms[index],
                      child: ListView(padding: const EdgeInsets.all(20), children: steps[index]),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(key: const Key('onboard-back'), onPressed: _saving ? null : _back, child: const Text(S.back)),
                  const Spacer(),
                  FilledButton(
                    key: const Key('onboard-next'),
                    onPressed: _saving ? null : _next,
                    child: Text(_step == 0 ? S.start : (_step == stepCount - 1 ? S.finish : S.next)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text, [String? body]) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(body, style: textTheme.bodyMedium?.copyWith(color: context.palette.mutedText)),
          ],
        ],
      ),
    );
  }

  Widget _moneyField(String key, TextEditingController controller, String label, {String? helper, bool allowZero = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: Key(key),
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, helperText: helper, prefixText: '₹ ', border: const OutlineInputBorder()),
        validator: (value) => _money(value, allowZero: allowZero),
      ),
    );
  }

  List<Widget> _welcome() => [_title(S.onboardingWelcomeTitle, S.onboardingWelcomeBody)];

  List<Widget> _depositStep() => [
        _title(S.depositTitle),
        _moneyField('field-deposit', _deposit, S.depositAmount),
        ListTile(
          key: const Key('field-deposit-date'),
          contentPadding: EdgeInsets.zero,
          title: const Text(S.depositDate),
          subtitle: Text(formatDate(_depositDate)),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: () async {
            final today = _today;
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(_depositDate.year, _depositDate.month, _depositDate.day),
              firstDate: DateTime(today.year - 1, today.month, 1),
              lastDate: DateTime(today.year, today.month, today.day),
            );
            if (picked != null) {
              setState(() => _depositDate = CivilDate(picked.year, picked.month, picked.day));
            }
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: const Key('field-anchor'),
          controller: _anchorDay,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: S.anchorDayLabel, helperText: S.anchorDayHint, border: OutlineInputBorder()),
          validator: (value) {
            final day = int.tryParse(value ?? '');
            return day == null || day < 1 || day > 31 ? S.invalidDay : null;
          },
        ),
      ];

  List<Widget> _floorsStep() => [
        _title(S.floorsTitle, S.floorsBody),
        _moneyField('field-food-floor', _foodFloor, S.foodFloorLabel),
        _moneyField('field-petrol-floor', _petrolFloor, S.petrolFloorLabel, allowZero: true),
        _moneyField('field-night-food', _nightFood, S.nightFoodLabel, allowZero: true),
      ];

  List<Widget> _weightsStep() {
    final total = _weightTotal;
    final palette = context.palette;
    return [
      _title(S.weightsTitle),
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
      const SizedBox(height: 8),
      Text(
        total == 100 ? S.weightsTotal(total) : '${S.weightsTotal(total)}. ${S.weightsMustBe100}',
        style: TextStyle(color: total == 100 ? palette.mutedText : palette.tight),
      ),
    ];
  }

  List<Widget> _balancesStep() => [
        _title(S.balancesTitle, S.balancesBody),
        _moneyField('field-bank', _bank, S.bankBalance, allowZero: true),
        _moneyField('field-cash', _cash, S.cashInHand, allowZero: true),
        _moneyField('field-excluded', _excluded, S.excludedAmount, helper: S.excludedHint, allowZero: true),
      ];

  List<Widget> _recurringStep() => [
        _title(S.recurringTitle, S.recurringBody),
        for (final cost in _recurring)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(cost.name),
            subtitle: Text(S.recurringLine(Rupees.format(cost.amount), cost.everyMonths)),
            trailing: IconButton(
              tooltip: S.remove,
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _recurring.remove(cost)),
            ),
          ),
        OutlinedButton.icon(onPressed: _addRecurring, icon: const Icon(Icons.add), label: const Text(S.addRecurring)),
      ];

  List<Widget> _suppliesStep() => [
        _title(S.suppliesTitle, S.suppliesBody),
        for (final supply in _supplies)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(supply.name),
            subtitle: Text(S.supplyLine(Rupees.format(supply.price), supply.lifespanDays)),
            trailing: IconButton(
              tooltip: S.remove,
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _supplies.remove(supply)),
            ),
          ),
        OutlinedButton.icon(onPressed: _addSupply, icon: const Icon(Icons.add), label: const Text(S.addSupply)),
      ];

  List<Widget> _paymentsStep() => [
        _title(S.paymentsTitle, S.paymentsBody),
        SwitchListTile(
          key: const Key('field-card'),
          contentPadding: EdgeInsets.zero,
          title: const Text(S.enableCard),
          value: _cardEnabled,
          onChanged: (value) => setState(() => _cardEnabled = value),
        ),
      ];

  Future<void> _addRecurring() async {
    final result = await showDialog<RecurringDraft>(context: context, builder: (_) => const _RecurringDialog());
    if (result != null) {
      setState(() => _recurring.add(result));
    }
  }

  Future<void> _addSupply() async {
    final result = await showDialog<SupplyDraft>(context: context, builder: (_) => _SupplyDialog(today: _today));
    if (result != null) {
      setState(() => _supplies.add(result));
    }
  }
}

class _RecurringDialog extends StatefulWidget {
  const _RecurringDialog();

  @override
  State<_RecurringDialog> createState() => _RecurringDialogState();
}

class _RecurringDialogState extends State<_RecurringDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _months = TextEditingController(text: '1');

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
      title: const Text(S.addRecurring),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: S.name),
              validator: (value) => (value ?? '').trim().isEmpty ? S.required : null,
            ),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: S.amount, prefixText: '₹ '),
              validator: (value) => (Rupees.parse(value ?? '')?.isPositive ?? false) ? null : S.invalidAmount,
            ),
            TextFormField(
              controller: _months,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: S.everyMonths),
              validator: (value) => (int.tryParse(value ?? '') ?? 0) >= 1 ? null : S.invalidNumber,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(S.cancel)),
        FilledButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.of(context).pop(RecurringDraft(
                name: _name.text.trim(),
                amount: Rupees.parse(_amount.text)!,
                everyMonths: int.parse(_months.text),
              ));
            }
          },
          child: const Text(S.add),
        ),
      ],
    );
  }
}

class _SupplyDialog extends StatefulWidget {
  const _SupplyDialog({required this.today});

  final CivilDate today;

  @override
  State<_SupplyDialog> createState() => _SupplyDialogState();
}

class _SupplyDialogState extends State<_SupplyDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _days = TextEditingController(text: '30');
  late CivilDate _lastRestock = widget.today;

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
      title: const Text(S.addSupply),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: S.name),
              validator: (value) => (value ?? '').trim().isEmpty ? S.required : null,
            ),
            TextFormField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: S.price, prefixText: '₹ '),
              validator: (value) => (Rupees.parse(value ?? '')?.isPositive ?? false) ? null : S.invalidAmount,
            ),
            TextFormField(
              controller: _days,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: S.lifespanDays),
              validator: (value) => (int.tryParse(value ?? '') ?? 0) >= 1 ? null : S.invalidNumber,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(S.lastRestock),
              subtitle: Text(formatDate(_lastRestock)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final today = widget.today;
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(_lastRestock.year, _lastRestock.month, _lastRestock.day),
                  firstDate: DateTime(today.year - 1),
                  lastDate: DateTime(today.year, today.month, today.day),
                );
                if (picked != null) {
                  setState(() => _lastRestock = CivilDate(picked.year, picked.month, picked.day));
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(S.cancel)),
        FilledButton(
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
          child: const Text(S.add),
        ),
      ],
    );
  }
}
