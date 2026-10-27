import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';

import '../domain/health.dart';

@immutable
final class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.background,
    required this.card,
    required this.cardBorder,
    required this.text,
    required this.mutedText,
    required this.accent,
    required this.onAccent,
    required this.comfortable,
    required this.tight,
    required this.limit,
    required this.neutral,
    required this.track,
  });

  final Color background;
  final Color card;
  final Color cardBorder;
  final Color text;
  final Color mutedText;
  final Color accent;
  final Color onAccent;
  final Color comfortable;
  final Color tight;
  final Color limit;
  final Color neutral;
  final Color track;

  static const dark = Palette(
    background: Color(0xFF0F1417),
    card: Color(0xFF1A2126),
    cardBorder: Color(0xFF263038),
    text: Color(0xFFEFF3F5),
    mutedText: Color(0xFFA9B6BE),
    accent: Color(0xFF3CC9B4),
    onAccent: Color(0xFF062420),
    comfortable: Color(0xFF3CC9B4),
    tight: Color(0xFFF2B33D),
    limit: Color(0xFFEF8A80),
    neutral: Color(0xFF8FA3B0),
    track: Color(0xFF2A343B),
  );

  static const light = Palette(
    background: Color(0xFFF3F6F7),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFDCE3E7),
    text: Color(0xFF13191D),
    mutedText: Color(0xFF4F5D66),
    accent: Color(0xFF0B7D6E),
    onAccent: Color(0xFFFFFFFF),
    comfortable: Color(0xFF0B7D6E),
    tight: Color(0xFF9A5B00),
    limit: Color(0xFFB3261E),
    neutral: Color(0xFF52636E),
    track: Color(0xFFE2E8EB),
  );

  Color health(HealthState state) => switch (state) {
        HealthState.comfortable => comfortable,
        HealthState.tight => tight,
        HealthState.limit => limit,
        HealthState.neutral => neutral,
      };

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(ThemeExtension<Palette>? other, double t) => t < 0.5 ? this : (other as Palette? ?? this);
}

abstract final class AppTheme {
  static ThemeData build(Palette palette, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
    ).copyWith(
      primary: palette.accent,
      onPrimary: palette.onAccent,
      surface: palette.card,
      onSurface: palette.text,
      onSurfaceVariant: palette.mutedText,
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      extensions: [palette],
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.cardBorder),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.card,
        indicatorColor: palette.accent.withValues(alpha: 0.22),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  static final dark = build(Palette.dark, Brightness.dark);
  static final light = build(Palette.light, Brightness.light);
}

extension PaletteLookup on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
}

abstract final class CategoryIcons {
  static IconData of(BudgetCategory category) => switch (category) {
        BudgetCategory.food => Icons.restaurant,
        BudgetCategory.petrol => Icons.local_gas_station,
        BudgetCategory.nightFoodStock => Icons.nightlight_round,
        BudgetCategory.essentialsStock => Icons.inventory_2_outlined,
        BudgetCategory.outings => Icons.celebration_outlined,
        BudgetCategory.trySomethingNew => Icons.auto_awesome_outlined,
        BudgetCategory.misc => Icons.wifi,
        BudgetCategory.buffer => Icons.shield_outlined,
        BudgetCategory.bikeFund => Icons.two_wheeler,
        BudgetCategory.recurringFund => Icons.autorenew,
        BudgetCategory.goals => Icons.flag_outlined,
        BudgetCategory.unlogged => Icons.help_outline,
      };
}
