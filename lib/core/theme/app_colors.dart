import 'package:flutter/material.dart';

/// Palet warna GERAKIN Design System.
///
/// Skema Material 3 dengan nuansa hijau-teal untuk kesehatan & vitalitas.
/// Semua komponen wajib menggunakan token ini, bukan hardcoded color.
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────
  static const Color primary = Color(0xFF00BFA5);
  static const Color primaryLight = Color(0xFF5DF2D6);
  static const Color primaryDark = Color(0xFF008E76);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFB2FFF0);
  static const Color onPrimaryContainer = Color(0xFF00201B);

  // ── Secondary ────────────────────────────────────────────
  static const Color secondary = Color(0xFF6C63FF);
  static const Color secondaryLight = Color(0xFFA18BFF);
  static const Color secondaryDark = Color(0xFF3D37CB);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE8E0FF);
  static const Color onSecondaryContainer = Color(0xFF1D0160);

  // ── Tertiary ─────────────────────────────────────────────
  static const Color tertiary = Color(0xFFFF8A65);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFDBCF);
  static const Color onTertiaryContainer = Color(0xFF3A0B00);

  // ── Error ────────────────────────────────────────────────
  static const Color error = Color(0xFFEF5350);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  // ── Surface (Light) ──────────────────────────────────────
  static const Color surface = Color(0xFFF8FAF9);
  static const Color onSurface = Color(0xFF1A1C1B);
  static const Color surfaceVariant = Color(0xFFEDF0EE);
  static const Color onSurfaceVariant = Color(0xFF3F4946);
  static const Color surfaceContainer = Color(0xFFEEF1EF);
  static const Color surfaceContainerLow = Color(0xFFF3F6F4);
  static const Color surfaceContainerHigh = Color(0xFFE8EBE9);

  // ── Surface (Dark) ──────────────────────────────────────
  static const Color surfaceDark = Color(0xFF121414);
  static const Color onSurfaceDark = Color(0xFFE1E3E1);
  static const Color surfaceVariantDark = Color(0xFF2B2F2D);
  static const Color onSurfaceVariantDark = Color(0xFFBEC9C5);
  static const Color surfaceContainerDark = Color(0xFF1E2120);
  static const Color surfaceContainerLowDark = Color(0xFF1A1C1B);
  static const Color surfaceContainerHighDark = Color(0xFF282B29);

  // ── Outline ──────────────────────────────────────────────
  static const Color outline = Color(0xFF6F7975);
  static const Color outlineVariant = Color(0xFFBFC9C5);
  static const Color outlineDark = Color(0xFF899390);
  static const Color outlineVariantDark = Color(0xFF3F4946);

  // ── Misc ─────────────────────────────────────────────────
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF2E3130);
  static const Color onInverseSurface = Color(0xFFEFF1EF);
  static const Color inversePrimary = Color(0xFF56DBB8);

  // ── Semantic ─────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFDAF5DB);
  static const Color onSuccessContainer = Color(0xFF0D3A0E);

  static const Color warning = Color(0xFFFFA726);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarningContainer = Color(0xFF4E2600);

  static const Color info = Color(0xFF42A5F5);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color onInfoContainer = Color(0xFF0A3049);

  // ── Neutral ──────────────────────────────────────────────
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // ── Disabled ─────────────────────────────────────────────
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledBackground = Color(0xFFF5F5F5);
  static const Color onDisabled = Color(0xFF9E9E9E);

  // ── Shimmer ──────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
