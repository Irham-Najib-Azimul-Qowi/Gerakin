import 'package:flutter/material.dart';

/// Palet warna GERAKIN Inclusive Motion Design System (sesuai DESIGN.md).
///
/// Personality: Bright, Friendly, Inclusive, Cheerful, Modern, Premium.
/// Skema warna disesuaikan untuk Light Mode dengan kontras tinggi WCAG AA.
class AppColors {
  AppColors._();

  // ── Primary & Brand ──────────────────────────────────────
  /// Purple (Primary): Digunakan untuk CTA utama, active states, dan brand highlight.
  static const Color primary = Color(0xFF7C5CFC);
  static const Color primaryLight = Color(0xFFA28BFF);
  static const Color primaryDark = Color(0xFF5A3BD9);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEDE9FE);
  static const Color onPrimaryContainer = Color(0xFF2E1065);
  static const Color purple = Color(0xFF7C5CFC);

  // ── Secondary (Sky Blue) ─────────────────────────────────
  /// Sky Blue (Secondary): Digunakan untuk aksen sekunder, gradient, dan visual pendukung.
  static const Color secondary = Color(0xFF5EC8FF);
  static const Color secondaryLight = Color(0xFF9BDFFF);
  static const Color secondaryDark = Color(0xFF0284C7);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE0F2FE);
  static const Color onSecondaryContainer = Color(0xFF0369A1);
  static const Color skyBlue = Color(0xFF5EC8FF);

  // ── Accent / Tertiary (Mint) ─────────────────────────────
  /// Mint (Accent): Digunakan untuk status sukses, highlight sekunder, dan keseimbangan.
  static const Color tertiary = Color(0xFF7AE7C7);
  static const Color onTertiary = Color(0xFF064E3B);
  static const Color tertiaryContainer = Color(0xFFD1FAE5);
  static const Color onTertiaryContainer = Color(0xFF065F46);
  static const Color mint = Color(0xFF7AE7C7);

  // ── Functional ───────────────────────────────────────────
  /// Success: Umpan balik positif, tugas selesai.
  static const Color success = Color(0xFF4ADE80);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccessContainer = Color(0xFF14532D);

  /// Warning: Pesan kehati-hatian.
  static const Color warning = Color(0xFFFACC15);
  static const Color onWarning = Color(0xFF713F12);
  static const Color warningContainer = Color(0xFFFEF9C3);
  static const Color onWarningContainer = Color(0xFF713F12);

  /// Error: Kesalahan kritis atau tindakan destruktif.
  static const Color error = Color(0xFFF87171);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  /// Info: Pesan informasi umum.
  static const Color info = Color(0xFF5EC8FF);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFE0F2FE);
  static const Color onInfoContainer = Color(0xFF0369A1);

  // ── Surface & Neutral (Light Mode) ───────────────────────
  /// Background: Latar belakang utama aplikasi (#F8FAFC) untuk nuansa bersih & lapang.
  static const Color background = Color(0xFFF8FAFC);

  /// Surface: Warna wadah kartu utama (#FFFFFF).
  static const Color surface = Color(0xFFFFFFFF);

  /// Text Primary: Judul utama dan teks isi (#1E293B) untuk keterbacaan tinggi.
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color onSurface = Color(0xFF1E293B);

  /// Text Secondary: Subheader, caption, dan inactive state (#64748B).
  static const Color textSecondary = Color(0xFF64748B);
  static const Color onSurfaceVariant = Color(0xFF64748B);

  /// Border: Garis pemisah halus dan outline wadah (#E2E8F0).
  static const Color border = Color(0xFFE2E8F0);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineVariant = Color(0xFFCBD5E1);

  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color surfaceContainer = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainerHigh = Color(0xFFF1F5F9);

  // ── Surface (Dark) ──────────────────────────────────────
  static const Color surfaceDark = Color(0xFF121414);
  static const Color onSurfaceDark = Color(0xFFE1E3E1);
  static const Color surfaceVariantDark = Color(0xFF2B2F2D);
  static const Color onSurfaceVariantDark = Color(0xFFBEC9C5);
  static const Color surfaceContainerDark = Color(0xFF1E2120);
  static const Color surfaceContainerLowDark = Color(0xFF1A1C1B);
  static const Color surfaceContainerHighDark = Color(0xFF282B29);
  static const Color outlineDark = Color(0xFF899390);
  static const Color outlineVariantDark = Color(0xFF3F4946);

  // ── Misc ─────────────────────────────────────────────────
  static const Color shadow = Color(0x0D000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF1E293B);
  static const Color onInverseSurface = Color(0xFFF8FAFC);
  static const Color inversePrimary = Color(0xFFA28BFF);

  // ── Neutral Scale ────────────────────────────────────────
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // ── Disabled ─────────────────────────────────────────────
  static const Color disabled = Color(0xFFCBD5E1);
  static const Color disabledBackground = Color(0xFFF1F5F9);
  static const Color onDisabled = Color(0xFF94A3B8);

  // ── Shimmer ──────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // ── Workout High-Contrast Dark Space ─────────────────────
  /// Latar belakang gelap khusus sesi latihan aktif untuk kontras maksimal.
  static const Color workoutSurfaceDark = Color(0xFF0F172A);

  /// Container/kartu gelap pada ruang latihan aktif.
  static const Color workoutCardDark = Color(0xFF1E293B);

  /// Aksen hijau terang penanda sukses & postur valid pada layar latihan.
  static const Color workoutAccentGreen = Color(0xFF00E676);
}
