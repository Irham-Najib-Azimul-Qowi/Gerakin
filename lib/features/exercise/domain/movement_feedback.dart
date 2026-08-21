enum FeedbackCategory {
  positive,
  instruction,
  correction,
}

enum FeedbackPriority {
  low,
  medium,
  high,
}

/// Model umpan balik visual & instruksi suara real-time.
class MovementFeedback {
  const MovementFeedback({
    required this.message,
    required this.category,
    this.priority = FeedbackPriority.medium,
    this.visualIcon,
    this.speechText,
  });

  final String message;
  final FeedbackCategory category;
  final FeedbackPriority priority;
  final String? visualIcon;
  final String? speechText;

  String get ttsMessage => speechText ?? message;

  // Preset feedback umum
  static const ready = MovementFeedback(
    message: 'Posisi terdeteksi ✓. Bersiap mulai!',
    category: FeedbackCategory.positive,
    visualIcon: '✓',
    speechText: 'Posisi terdeteksi. Bersiap mulai latihan.',
  );

  static const lowConfidence = MovementFeedback(
    message: 'Pastikan tubuh terlihat jelas di kamera.',
    category: FeedbackCategory.correction,
    priority: FeedbackPriority.high,
    visualIcon: '⚠️',
    speechText: 'Pastikan tubuh bagian atas terlihat jelas di kamera.',
  );

  static const repComplete = MovementFeedback(
    message: 'Gerakan bagus! Hitungan bertambah.',
    category: FeedbackCategory.positive,
    visualIcon: '👍',
  );
}
