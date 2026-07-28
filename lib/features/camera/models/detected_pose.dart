import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_landmark_model.dart';

/// Model wrapper untuk sekelompok landmark pose dalam 1 frame kamera.
///
/// Menyimpan daftar landmark yang terdeteksi serta dimensi asli gambar sensor
/// yang diperlukan oleh [CoordinateMapper] untuk penskalaan layar.
class DetectedPose {
  const DetectedPose({
    required this.landmarks,
    required this.imageSize,
    required this.rotation,
    required this.isFrontCamera,
  });

  /// Map dari [PoseLandmarkType] ke [PoseLandmarkModel].
  final Map<PoseLandmarkType, PoseLandmarkModel> landmarks;

  /// Ukuran fisik bingkai gambar sensor kamera (misal: 1280x720).
  final Size imageSize;

  /// Rotasi gambar dari sensor kamera.
  final InputImageRotation rotation;

  /// Apakah gambar diambil dari kamera depan (memerlukan horizontal mirror).
  final bool isFrontCamera;

  /// Konversi dari ML Kit [Pose].
  factory DetectedPose.fromMLKit({
    required Pose pose,
    required Size imageSize,
    required InputImageRotation rotation,
    required bool isFrontCamera,
  }) {
    final map = <PoseLandmarkType, PoseLandmarkModel>{};
    for (final entry in pose.landmarks.entries) {
      map[entry.key] = PoseLandmarkModel.fromMLKit(entry.value);
    }

    return DetectedPose(
      landmarks: map,
      imageSize: imageSize,
      rotation: rotation,
      isFrontCamera: isFrontCamera,
    );
  }

  /// Mendapatkan landmark spesifik jika terdeteksi dan memenuhi threshold confidence.
  PoseLandmarkModel? getLandmark(
    PoseLandmarkType type, [
    double minLikelihood = 0.5,
  ]) {
    final landmark = landmarks[type];
    if (landmark != null && landmark.isValid(minLikelihood)) {
      return landmark;
    }
    return null;
  }
}
