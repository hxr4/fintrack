enum ThemePreference { dark, light }

abstract final class SettingKeys {
  static const onboarded = 'onboarded';
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
}

final class AppPreferences {
  const AppPreferences({
    this.onboarded = false,
    this.cardEnabled = false,
    this.secureScreen = true,
    this.theme = ThemePreference.dark,
  });

  factory AppPreferences.fromMap(Map<String, String> map) => AppPreferences(
        onboarded: map[SettingKeys.onboarded] == 'true',
        cardEnabled: map[SettingKeys.cardEnabled] == 'true',
        secureScreen: map[SettingKeys.secureScreen] != 'false',
        theme: map[SettingKeys.theme] == ThemePreference.light.name ? ThemePreference.light : ThemePreference.dark,
      );

  final bool onboarded;
  final bool cardEnabled;
  final bool secureScreen;
  final ThemePreference theme;

  Map<String, String> toMap() => {
        SettingKeys.onboarded: '$onboarded',
        SettingKeys.cardEnabled: '$cardEnabled',
        SettingKeys.secureScreen: '$secureScreen',
        SettingKeys.theme: theme.name,
      };

  AppPreferences copyWith({bool? onboarded, bool? cardEnabled, bool? secureScreen, ThemePreference? theme}) =>
      AppPreferences(
        onboarded: onboarded ?? this.onboarded,
        cardEnabled: cardEnabled ?? this.cardEnabled,
        secureScreen: secureScreen ?? this.secureScreen,
        theme: theme ?? this.theme,
      );
}
