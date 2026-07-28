import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Jenis / Kategori Feedback real-time.
enum FeedbackType {
  /// Aba-aba / instruksi awal.
  instruction,

  /// Bimbingan langsung / dorongan semangat (Live Coaching).
  liveCoaching,

  /// Peringatan kesalahan posisi / bentuk tubuh (Form Warning).
  warning,

  /// Pencapaian sukses (Repetisi / Set Selesai).
  success,
}

/// Extension helper untuk [FeedbackType].
extension FeedbackTypeX on FeedbackType {
  bool get isInstruction => this == FeedbackType.instruction;
  bool get isLiveCoaching => this == FeedbackType.liveCoaching;
  bool get isWarning => this == FeedbackType.warning;
  bool get isSuccess => this == FeedbackType.success;

  Color get color {
    switch (this) {
      case FeedbackType.instruction:
        return AppColors.info;
      case FeedbackType.liveCoaching:
        return AppColors.primary;
      case FeedbackType.warning:
        return AppColors.warning;
      case FeedbackType.success:
        return AppColors.success;
    }
  }

  IconData get icon {
    switch (this) {
      case FeedbackType.instruction:
        return Icons.info_outline_rounded;
      case FeedbackType.liveCoaching:
        return Icons.fitness_center_rounded;
      case FeedbackType.warning:
        return Icons.warning_amber_rounded;
      case FeedbackType.success:
        return Icons.check_circle_outline_rounded;
    }
  }
}
