import 'package:flutter/material.dart';

/// Extension pada [BuildContext] untuk akses cepat ke properti yang sering dipakai.
extension ContextExtensions on BuildContext {
  // ── Theme ────────────────────────────────────────────────
  /// Akses cepat ke [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Akses cepat ke [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Akses cepat ke [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Apakah tema dark aktif.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ── MediaQuery ───────────────────────────────────────────
  /// Akses cepat ke [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Lebar layar.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Tinggi layar.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Padding atas (status bar).
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// Padding bawah (navigation bar / home indicator).
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  // ── Navigation ───────────────────────────────────────────
  /// Navigasi kembali.
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Apakah bisa navigasi kembali.
  bool get canPop => Navigator.of(this).canPop();

  // ── Snackbar ─────────────────────────────────────────────
  /// Tampilkan snackbar.
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}
