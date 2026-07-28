import 'package:flutter/material.dart';

/// Konstanta spacing untuk layout konsisten.
///
/// Menggunakan skala 4px sebagai base unit.
/// Semua komponen wajib menggunakan token ini, bukan hardcoded spacing.
class AppSpacing {
  AppSpacing._();

  /// 2.0
  static const double xxs = 2.0;

  /// 4.0
  static const double xs = 4.0;

  /// 8.0
  static const double sm = 8.0;

  /// 12.0
  static const double md = 12.0;

  /// 16.0
  static const double lg = 16.0;

  /// 20.0
  static const double xl = 20.0;

  /// 24.0
  static const double xxl = 24.0;

  /// 32.0
  static const double xxxl = 32.0;

  /// 40.0
  static const double huge = 40.0;

  /// 48.0
  static const double massive = 48.0;

  /// 64.0
  static const double giant = 64.0;

  // ── Page Padding ─────────────────────────────────────────
  /// Padding horizontal standar untuk halaman (16.0).
  static const double pageHorizontal = 16.0;

  /// Padding vertikal standar untuk halaman (24.0).
  static const double pageVertical = 24.0;

  // ── EdgeInsets Presets ────────────────────────────────────
  static const EdgeInsets paddingAllXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingAllXxl = EdgeInsets.all(xxl);

  static const EdgeInsets paddingHorizontalSm =
      EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl =
      EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets paddingVerticalSm =
      EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd =
      EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg =
      EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXl =
      EdgeInsets.symmetric(vertical: xl);

  /// Padding standar halaman.
  static const EdgeInsets paddingPage = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: pageVertical,
  );

  /// Padding horizontal halaman saja.
  static const EdgeInsets paddingPageHorizontal = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
  );
}
