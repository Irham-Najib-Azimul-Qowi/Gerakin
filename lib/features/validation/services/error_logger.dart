import 'package:flutter/foundation.dart';

/// Service pencatat log kesalahan & peringatan deteksi vision (Error Logger).
class ErrorLogger {
  ErrorLogger();

  final List<String> _errorLogs = [];

  List<String> get errorLogs => List.unmodifiable(_errorLogs);

  /// Mencatat pesan kesalahan / peringatan.
  void logWarning(String tag, String message) {
    final log = '[WARNING][$tag] ${DateTime.now()}: $message';
    _errorLogs.add(log);
    debugPrint(log);
  }

  void logError(String tag, String message, [Object? error]) {
    final log = '[ERROR][$tag] ${DateTime.now()}: $message ${error != null ? "($error)" : ""}';
    _errorLogs.add(log);
    debugPrint(log);
  }

  void clear() {
    _errorLogs.clear();
  }
}
