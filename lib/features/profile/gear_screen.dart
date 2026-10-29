import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/profile_state.dart';
import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/gear.dart';
import '../../domain/ledger_data.dart';
import '../../domain/rupees.dart';
import '../common/forms.dart';
import '../common/widgets.dart';
import 'gear_image.dart';
import 'profile_screen.dart';

class GearScreen extends ConsumerStatefulWidget {
  const GearScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<GearScreen> createState() => _GearScreenState();
}

class _GearScreenState extends ConsumerState<GearScreen> {
  final _form = GlobalKey<FormState>();
  late final GearItem _initial = ref.read(profileProvider).requireValue.item(widget.id)!;
  late final _name = TextEditingController(text: _initial.name);
  late final _variant = TextEditingController(text: _initial.variant);
  late final _specs = TextEditingController(text: _initial.specs);
  late final _price = TextEditingController(
    text: _initial.price == null ? '' : Rupees.plain(_initial.price!).replaceAll(',', ''),
  );
  late final _seller = TextEditingController(text: _initial.seller);
  late final _notes = TextEditingController(text: _initial.notes);
  late CivilDate? _purchaseDate = _initial.purchaseDate;
  late CivilDate? _warrantyEnd = _initial.warrantyEnd;
  late String? _photoId = _initial.photoId;
  late String? _billPhotoId = _initial.billPhotoId;

  @override
  void dispose() {
    for (final controller in [_name, _variant, _specs, _price, _seller, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  GearItem get _draft {
    final price = Rupees.parse(_price.text);
    return _initial.copyWith(
      name: _name.text.trim().isEmpty ? _initial.name : _name.text.trim(),
      variant: _variant.text.trim(),
      specs: _specs.text.trim(),
      price: price,
      clearPrice: price == null,
      seller: _seller.text.trim(),
      notes: _notes.text.trim(),
      purchaseDate: _purchaseDate,
      clearPurchaseDate: _purchaseDate == null,
      warrantyEnd: _warrantyEnd,
      clearWarranty: _warrantyEnd == null,
      photoId: _photoId,
      billPhotoId: _billPhotoId,
    );
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await ref.read(profileProvider.notifier).saveGear(_draft);
    messenger.showSnackBar(const SnackBar(content: Text(S.gearSaved)));
    navigator.pop();
  }

  Future<String?> _pick() async {
    final source = await askPhotoSource(context);
    if (source == null) {
      return null;
    }
    return ref.read(profileProvider.notifier).pickPhoto(source);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final snapshot = ref.watch(budgetProvider.select((value) => value.value?.snapshot));
    final today = snapshot?.today ?? KolkataTime.dateOf(DateTime.now());
    final draft = _draft;
    final cost = draft.costPerDay(today);
    final owned = draft.daysOwned(today);
    final warranty = draft.warrantyDaysLeft(today);
    final muted = textTheme.bodySmall?.copyWith(color: palette.mutedText);
    return Scaffold(
      appBar: AppBar(title: Text(_initial.name)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(child: GearImage(item: draft, size: 200)),
            Center(
              child: TextButton.icon(
                key: const Key('gear-photo'),
                onPressed: () async {
                  final id = await _pick();
                  if (id != null) {
                    setState(() => _photoId = id);
                  }
                },
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text(S.useMyPhoto),
              ),
            ),
            const SizedBox(height: 8),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cost != null)
                    Text(S.costPerDay(Rupees.format(cost, showPaise: cost.paise < 10000)), key: const Key('gear-cost'), style: textTheme.titleMedium)
                  else
                    Text(S.missingDetails, style: muted),
                  if (owned != null) Text(S.ownedFor(owned), style: muted),
                  if (warranty != null) Text(S.warrantyLeft(warranty), key: const Key('gear-warranty'), style: muted),
                ],
              ),
            ),
            if (_initial.isBike) ...[
              const SizedBox(height: 12),
              const _BikeSection(),
            ],
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('gear-name'),
              controller: _name,
              decoration: const InputDecoration(labelText: S.gearName, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _variant,
              decoration: const InputDecoration(labelText: S.gearVariant, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _specs,
              minLines: 3,
              maxLines: 10,
              decoration: const InputDecoration(labelText: S.specs, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DateTile(
              key: const Key('gear-purchase-date'),
              label: S.purchaseDate,
              date: _purchaseDate,
              today: today,
              onChanged: (date) => setState(() => _purchaseDate = date),
            ),
            TextFormField(
              key: const Key('gear-price'),
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: S.pricePaid, prefixText: '₹ ', border: OutlineInputBorder()),
              validator: (value) => (value ?? '').trim().isEmpty ? null : validateMoney(value),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _seller,
              decoration: const InputDecoration(labelText: S.seller, border: OutlineInputBorder()),
            ),
            DateTile(
              key: const Key('gear-warranty-date'),
              label: S.warrantyEnds,
              date: _warrantyEnd,
              today: today,
              allowFuture: true,
              onChanged: (date) => setState(() => _warrantyEnd = date),
            ),
            TextFormField(
              controller: _notes,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(labelText: S.notes, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Text(S.billPhoto, style: textTheme.titleSmall),
            const SizedBox(height: 6),
            if (_billPhotoId != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(height: 220, child: StoredPhoto(photoId: _billPhotoId!, fit: BoxFit.contain)),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('gear-bill'),
                onPressed: () async {
                  final id = await _pick();
                  if (id != null) {
                    setState(() => _billPhotoId = id);
                  }
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text(S.addBillPhoto),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(key: const Key('gear-save'), onPressed: _save, child: const Text(S.save)),
            const SizedBox(height: 8),
            if (!_initial.isBike)
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await ref.read(profileProvider.notifier).deleteGear(_initial.id);
                  navigator.pop();
                },
                child: const Text(S.deleteGear),
              ),
          ],
        ),
      ),
    );
  }
}

class _BikeSection extends ConsumerWidget {
  const _BikeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider).value;
    final ledger = state?.ledger;
    final snapshot = state?.snapshot;
    if (ledger == null || snapshot == null) {
      return const SizedBox.shrink();
    }
    final today = snapshot.today;
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodySmall?.copyWith(color: context.palette.mutedText);
    final due = ledger.serviceDue(today);
    final odometer = ledger.latestOdometer;
    final controller = ref.read(budgetProvider.notifier);
    return SectionCard(
      key: const Key('bike-section'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.bikeDetails, style: textTheme.titleSmall),
          const SizedBox(height: 6),
          Text('${S.odometerLabel}: ${odometer == null ? S.notSet : S.odometerValue(odometer)}', key: const Key('bike-odometer')),
          Text(
            due.isKnown
                ? S.serviceDue([
                    if (due.daysLeft != null) S.serviceDueDays(due.daysLeft!),
                    if (due.kmLeft != null) S.serviceDueKm(due.kmLeft!),
                  ].join(', '))
                : S.serviceNotSet,
            style: muted,
          ),
          DateTile(
            key: const Key('bike-insurance'),
            label: S.insuranceExpiry,
            date: ledger.bike.insuranceExpiry,
            today: today,
            allowFuture: true,
            onChanged: (date) => controller.saveBike(
              BikeProfile(service: ledger.bike.service, insuranceExpiry: date, pucExpiry: ledger.bike.pucExpiry),
            ),
          ),
          if (ledger.bike.insuranceExpiry != null)
            Text(S.expiresIn(formatDate(ledger.bike.insuranceExpiry!), today.daysUntil(ledger.bike.insuranceExpiry!)), style: muted),
          DateTile(
            key: const Key('bike-puc'),
            label: S.pucExpiry,
            date: ledger.bike.pucExpiry,
            today: today,
            allowFuture: true,
            onChanged: (date) => controller.saveBike(
              BikeProfile(service: ledger.bike.service, insuranceExpiry: ledger.bike.insuranceExpiry, pucExpiry: date),
            ),
          ),
          if (ledger.bike.pucExpiry != null)
            Text(S.expiresIn(formatDate(ledger.bike.pucExpiry!), today.daysUntil(ledger.bike.pucExpiry!)), style: muted),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('open-bike-log'),
            onPressed: () => context.push('/supplies?tab=1'),
            icon: const Icon(Icons.two_wheeler),
            label: const Text(S.openBike),
          ),
        ],
      ),
    );
  }
}
