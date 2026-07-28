import 'feedback_action.dart';
import 'feedback_priority.dart';
import 'feedback_type.dart';

/// Model pesan feedback tunggal yang siap dieksekusi UI & Voice TTS.
class FeedbackMessage {
  const FeedbackMessage({
    required this.id,
    required this.type,
    required this.priority,
    required this.text,
    this.voiceText,
    this.action = const FeedbackAction(),
    required this.timestamp,
  });

  /// ID unik jenis pesan (misal: 'warning_shoulder_asymmetry').
  final String id;

  /// Kategori feedback (instruction, liveCoaching, warning, success).
  final FeedbackType type;

  /// Tingkat prioritas.
  final FeedbackPriority priority;

  /// Teks yang ditampilkan pada banner UI.
  final String text;

  /// Teks opsional khusus untuk dibacakan oleh Text-to-Speech (TTS).
  final String? voiceText;

  /// Aksi visual pendamping.
  final FeedbackAction action;

  /// Timestamp pembuatan pesan.
  final DateTime timestamp;

  /// Teks yang akan diucapkan oleh TTS (fallback ke [text] jika null).
  String get speechText => voiceText ?? text;

  @override
  String toString() =>
      'FeedbackMessage(${priority.name.toUpperCase()} [$id]: "$text")';
}
