import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/profile_state.dart';
import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/gear.dart';
import '../../domain/rupees.dart';
import '../../platform/photo_picker.dart';
import '../common/widgets.dart';
import 'gear_image.dart';

Future<PhotoSource?> askPhotoSource(BuildContext context) => showModalBottomSheet<PhotoSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text(S.takePhoto),
              onTap: () => Navigator.of(context).pop(PhotoSource.camera),
            ),
            ListTile(
              key: const Key('pick-gallery'),
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(S.chooseFromGallery),
              onTap: () => Navigator.of(context).pop(PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );

class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({super.key, this.radius = 18});

  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(profileProvider).value?.details;
    final palette = context.palette;
    final initial = (details?.name.trim().isNotEmpty ?? false) ? details!.name.trim()[0].toUpperCase() : null;
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: palette.accent.withValues(alpha: 0.25),
      child: initial == null ? Icon(Icons.person_outline, size: radius, color: palette.text) : Text(initial),
    );
    final photoId = details?.photoId;
    if (photoId == null) {
      return fallback;
    }
    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: StoredPhoto(photoId: photoId, fallback: fallback),
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final snapshot = ref.watch(budgetProvider.select((value) => value.value?.snapshot));
    if (profile == null || snapshot == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final details = profile.details;
    return Scaffold(
      appBar: AppBar(title: const Text(S.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              GestureDetector(
                key: const Key('profile-photo'),
                onTap: () => _changePhoto(context, ref, details),
                child: const ProfileAvatar(radius: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(details.name.isEmpty ? S.yourName : details.name, style: textTheme.titleLarge),
                    if (details.details.isNotEmpty)
                      Text(details.details, style: textTheme.bodyMedium?.copyWith(color: palette.mutedText)),
                  ],
                ),
              ),
              IconButton(
                key: const Key('edit-profile'),
                tooltip: S.editProfile,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _editDetails(context, ref, details),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Text(S.gear, style: textTheme.titleMedium)),
              TextButton.icon(
                key: const Key('add-gear'),
                onPressed: () async {
                  final controller = ref.read(profileProvider.notifier);
                  final item = GearItem(
                    id: controller.newGearId(),
                    kind: GearKind.other,
                    name: S.addGear,
                    sortOrder: profile.gear.length + 10,
                  );
                  await controller.saveGear(item);
                  if (context.mounted) {
                    await context.push('/gear/${item.id}');
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text(S.addGear),
              ),
            ],
          ),
          for (final item in profile.gear)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GearCard(item: item, today: snapshot.today),
            ),
          const SizedBox(height: 16),
          SectionCard(
            padding: EdgeInsets.zero,
            onTap: () => context.push('/settings'),
            child: const ListTile(
              key: Key('open-settings'),
              leading: Icon(Icons.settings_outlined),
              title: Text(S.settings),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePhoto(BuildContext context, WidgetRef ref, ProfileDetails details) async {
    final source = await askPhotoSource(context);
    if (source == null) {
      return;
    }
    final controller = ref.read(profileProvider.notifier);
    final id = await controller.pickPhoto(source);
    if (id != null) {
      await controller.saveDetails(details.copyWith(photoId: id));
    }
  }

  Future<void> _editDetails(BuildContext context, WidgetRef ref, ProfileDetails details) async {
    final name = TextEditingController(text: details.name);
    final about = TextEditingController(text: details.details);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(S.editProfile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(key: const Key('profile-name'), controller: name, decoration: const InputDecoration(labelText: S.yourName)),
            TextField(
              controller: about,
              decoration: const InputDecoration(labelText: S.aboutYou, hintText: S.aboutYouHint),
              maxLines: 3,
              minLines: 1,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text(S.cancel)),
          FilledButton(key: const Key('profile-save'), onPressed: () => Navigator.of(context).pop(true), child: const Text(S.save)),
        ],
      ),
    );
    if (saved == true) {
      await ref.read(profileProvider.notifier).saveDetails(details.copyWith(name: name.text.trim(), details: about.text.trim()));
    }
    name.dispose();
    about.dispose();
  }
}

class GearCard extends ConsumerWidget {
  const GearCard({super.key, required this.item, required this.today});

  final GearItem item;
  final CivilDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodySmall?.copyWith(color: palette.mutedText);
    final cost = item.costPerDay(today);
    final warranty = item.warrantyDaysLeft(today);
    final firstSpec = item.specs.split('\n').first;
    return SectionCard(
      key: Key('gear-${item.id}'),
      onTap: () => context.push('/gear/${item.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GearImage(item: item),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: textTheme.titleMedium),
                if (item.variant.isNotEmpty) Text(item.variant, style: muted),
                if (firstSpec.isNotEmpty) Text(firstSpec, style: muted, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (cost != null)
                  Text(S.costPerDay(Rupees.format(cost, showPaise: cost.paise < 10000)), style: textTheme.bodyMedium)
                else
                  Text(S.missingDetails, style: muted),
                if (warranty != null) Text(S.warrantyLeft(warranty), style: muted),
                if (item.isBike) _BikeLine(today: today),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BikeLine extends ConsumerWidget {
  const _BikeLine({required this.today});

  final CivilDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledger = ref.watch(budgetProvider.select((value) => value.value?.ledger));
    if (ledger == null) {
      return const SizedBox.shrink();
    }
    final odometer = ledger.latestOdometer;
    final muted = Theme.of(context).textTheme.bodySmall?.copyWith(color: context.palette.mutedText);
    return Text(
      [
        if (odometer != null) S.odometerValue(odometer),
        if (ledger.serviceDue(today).daysLeft != null) S.serviceDue(S.serviceDueDays(ledger.serviceDue(today).daysLeft!)),
      ].join(' · '),
      key: const Key('bike-line'),
      style: muted,
    );
  }
}
