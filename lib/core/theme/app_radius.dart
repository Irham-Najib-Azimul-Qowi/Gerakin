import 'package:flutter/material.dart';

/// Konstanta border radius untuk UI konsisten.
class AppRadius {
  AppRadius._();

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

  /// 28.0
  static const double xxxl = 28.0;

  /// 9999.0 – Fully rounded (pill shape).
  static const double full = 9999.0;

  // ── BorderRadius Presets ─────────────────────────────────
  static BorderRadius get borderRadiusXs =>
      BorderRadius.circular(xs);

  static BorderRadius get borderRadiusSm =>
      BorderRadius.circular(sm);

  static BorderRadius get borderRadiusMd =>
      BorderRadius.circular(md);

  static BorderRadius get borderRadiusLg =>
      BorderRadius.circular(lg);

  static BorderRadius get borderRadiusXl =>
      BorderRadius.circular(xl);

  static BorderRadius get borderRadiusXxl =>
      BorderRadius.circular(xxl);

  static BorderRadius get borderRadiusFull =>
      BorderRadius.circular(full);
}
