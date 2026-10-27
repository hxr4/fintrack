import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/preferences.dart';
import '../../domain/rupees.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider).value;
    if (state == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final preferences = state.preferences;
    final settings = state.settings;
    final controller = ref.read(budgetProvider.notifier);
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(title: const Text(S.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            key: const Key('setting-card'),
            title: const Text(S.settingCard),
            subtitle: const Text(S.settingCardHint),
            value: preferences.cardEnabled,
            onChanged: (value) => controller.updatePreferences(preferences.copyWith(cardEnabled: value)),
          ),
          SwitchListTile(
            title: const Text(S.settingSecure),
            subtitle: const Text(S.settingSecureHint),
            value: preferences.secureScreen,
            onChanged: (value) => controller.updatePreferences(preferences.copyWith(secureScreen: value)),
          ),
          SwitchListTile(
            title: const Text(S.settingLight),
            value: preferences.theme == ThemePreference.light,
            onChanged: (value) => controller.updatePreferences(
              preferences.copyWith(theme: value ? ThemePreference.light : ThemePreference.dark),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text(S.lockNow),
            onTap: () {
              Navigator.of(context).pop();
              ref.read(lockProvider.notifier).lock();
            },
          ),
          if (settings != null) ...[
            const Divider(),
            ListTile(
              title: const Text(S.budgetValues),
              subtitle: Text(S.budgetValuesHint, style: TextStyle(color: palette.mutedText)),
            ),
            ListTile(title: const Text(S.foodFloorLabel), trailing: Text(Rupees.format(settings.foodFloorPerDay))),
            ListTile(title: const Text(S.petrolFloorLabel), trailing: Text(Rupees.format(settings.petrolFloorPerCycle))),
            ListTile(title: const Text(S.nightFoodLabel), trailing: Text(Rupees.format(settings.nightFoodStockTarget))),
            ListTile(title: const Text(S.anchorDayLabel), trailing: Text('${settings.anchorDay}')),
          ],
        ],
      ),
    );
  }
}
