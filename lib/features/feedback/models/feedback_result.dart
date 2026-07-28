import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'feedback_message.dart';

/// Hasil akhir evaluasi Feedback Engine untuk dirender oleh UI dan diputar oleh Voice TTS.
class FeedbackResult {
  const FeedbackResult({
    this.primaryMessage,
    this.allMessages = const [],
    required this.skeletonColor,
    this.highlightedJoints = const [],
    this.holdRemainingSeconds = 0,
    this.restRemainingSeconds = 0,
  });

  /// Pesan dengan prioritas tertinggi untuk frame ini.
  final FeedbackMessage? primaryMessage;

  /// Seluruh daftar pesan aktif.
  final List<FeedbackMessage> allMessages;

  /// Warna terhitung untuk skeleton overlay UI.
  final Color skeletonColor;

  /// Daftar sendi yang perlu mendapat indikator visual sorotan (highlight).
  final List<PoseLandmarkType> highlightedJoints;

  /// Sisa detik penahanan posisi puncak (hold phase).
  final int holdRemainingSeconds;

  /// Sisa detik istirahat (rest phase).
  final int restRemainingSeconds;
}
