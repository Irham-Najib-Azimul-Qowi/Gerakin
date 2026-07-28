import 'package:flutter/foundation.dart';

/// Level keparahan log sistem.
enum LogLevel { debug, info, warning, error, fatal }

/// Layanan pencatatan log terpusat (Enterprise Logger Service) berkinerja tinggi.
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  final List<String> _logs = [];

  /// Mendapatkan daftar riwayat log yang tersimpan secara lokal.
  List<String> get logs => List.unmodifiable(_logs);

  /// Mencatat entri log baru dengan timestamp dan kategori.
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    String? category,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final cat = category != null ? '[$category]' : '[APP]';
    final lvl = level.name.toUpperCase();
    final formatted = '$timestamp [$lvl] $cat $message';

    _logs.add(formatted);
    if (_logs.length > 500) {
      _logs.removeAt(0); // Menjaga penggunaan memori tetap efisien
    }

    if (kDebugMode) {
      debugPrint(formatted);
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrint('  StackTrace: $stackTrace');
    }
  }

  void debug(String message, {String? category}) =>
      log(message, level: LogLevel.debug, category: category);

  void info(String message, {String? category}) =>
      log(message, level: LogLevel.info, category: category);

  void warning(String message, {String? category}) =>
      log(message, level: LogLevel.warning, category: category);

  void error(String message, {String? category, Object? error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.error, category: category, error: error, stackTrace: stackTrace);

  void fatal(String message, {String? category, Object? error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.fatal, category: category, error: error, stackTrace: stackTrace);
}
