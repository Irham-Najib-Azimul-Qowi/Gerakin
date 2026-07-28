import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Custom BoxShadow presets.
///
/// Lebih halus dan natural dibanding Material default shadow.
class AppShadows {
  AppShadows._();

  /// Tanpa shadow.
  static const List<BoxShadow> none = [];

  /// Shadow sangat tipis – untuk card flat.
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Shadow ringan – untuk card, input field.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Shadow medium – untuk dropdown, popover.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Shadow besar – untuk dialog, modal.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ];

  /// Shadow extra besar – untuk navigation, bottom sheet.
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Shadow berwarna primary – untuk tombol primary hover/pressed.
  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
