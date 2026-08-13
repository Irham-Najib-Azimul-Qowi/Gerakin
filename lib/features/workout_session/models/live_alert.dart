import 'package:flutter/material.dart';

/// Tingkat keparahan peringatan visual bertingkat (Live Alert Severity).
enum AlertSeverity {
  info,
  warning,
  critical,
}

/// Model data untuk Peringatan Visual Real-Time (Live Alert System).
class LiveAlert {
  LiveAlert({
    required this.message,
    required this.severity,
    required this.icon,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String message;
  final AlertSeverity severity;
  final IconData icon;
  final DateTime timestamp;

  bool get isCritical => severity == AlertSeverity.critical;
  bool get isWarning => severity == AlertSeverity.warning;
  bool get isInfo => severity == AlertSeverity.info;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveAlert &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          severity == other.severity;

  @override
  int get hashCode => message.hashCode ^ severity.hashCode;
}
