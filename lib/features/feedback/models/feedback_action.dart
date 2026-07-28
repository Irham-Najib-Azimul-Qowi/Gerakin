import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Aksi visual dan haptik pendamping pesan feedback.
class FeedbackAction {
  const FeedbackAction({
    this.skeletonColor,
    this.highlightJoints = const [],
    this.showHoldProgress = false,
    this.showCountdown = false,
    this.vibrateHaptic = false,
  });

  /// Warna custom untuk skeleton overlay pada frame ini.
  final Color? skeletonColor;

  /// Daftar jenis sendi yang harus diberi sorotan khusus (highlight/pulse).
  final List<PoseLandmarkType> highlightJoints;

  /// Tampilkan indikator penahanan posisi (hold progress bar).
  final bool showHoldProgress;

  /// Tampilkan indikator countdown.
  final bool showCountdown;

  /// Trigger getaran haptik (umpan balik fisik).
  final bool vibrateHaptic;
}
