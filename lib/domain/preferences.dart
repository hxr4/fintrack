enum ThemePreference { dark, light }

abstract final class SettingKeys {
  static const onboarded = 'onboarded';
  static const lastBackupAt = 'lastBackupAt';
  static const cardEnabled = 'cardEnabled';
  static const secureScreen = 'secureScreen';
  static const theme = 'theme';
  static const foodFloor = 'foodFloorPerDay';
  static const petrolFloor = 'petrolFloorPerCycle';
  static const nightFoodStock = 'nightFoodStockTarget';
  static const anchorDay = 'anchorDay';
  static const dayBoundaryHour = 'dayBoundaryHour';
  static const weights = 'weights';
  static const excluded = 'excludedPaise';
  static const bikeServiceIntervalKm = 'bikeServiceIntervalKm';
  static const bikeServiceIntervalMonths = 'bikeServiceIntervalMonths';
  static const bikeServiceCost = 'bikeServiceCostPaise';
  static const bikeLastServiceDate = 'bikeLastServiceDate';
  static const bikeLastServiceKm = 'bikeLastServiceKm';
  static const bikeInsuranceExpiry = 'bikeInsuranceExpiry';
  static const bikePucExpiry = 'bikePucExpiry';
}

final class AppPreferences {
  const AppPreferences({
    this.onboarded = false,
    this.cardEnabled = false,
    this.secureScreen = true,
    this.theme = ThemePreference.dark,
    this.lastBackupAt,
  });

  factory AppPreferences.fromMap(Map<String, String> map) => AppPreferences(
        onboarded: map[SettingKeys.onboarded] == 'true',
        cardEnabled: map[SettingKeys.cardEnabled] == 'true',
        secureScreen: map[SettingKeys.secureScreen] != 'false',
        theme: map[SettingKeys.theme] == ThemePreference.light.name ? ThemePreference.light : ThemePreference.dark,
        lastBackupAt: DateTime.tryParse(map[SettingKeys.lastBackupAt] ?? ''),
      );

  final bool onboarded;
  final bool cardEnabled;
  final bool secureScreen;
  final ThemePreference theme;
  final DateTime? lastBackupAt;

  Map<String, String> toMap() => {
        SettingKeys.onboarded: '$onboarded',
        SettingKeys.cardEnabled: '$cardEnabled',
        SettingKeys.secureScreen: '$secureScreen',
        SettingKeys.theme: theme.name,
        SettingKeys.lastBackupAt: lastBackupAt?.toUtc().toIso8601String() ?? '',
      };

  AppPreferences copyWith({
    bool? onboarded,
    bool? cardEnabled,
    bool? secureScreen,
    ThemePreference? theme,
    DateTime? lastBackupAt,
  }) =>
      AppPreferences(
        onboarded: onboarded ?? this.onboarded,
        cardEnabled: cardEnabled ?? this.cardEnabled,
        secureScreen: secureScreen ?? this.secureScreen,
        theme: theme ?? this.theme,
        lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      );
}
