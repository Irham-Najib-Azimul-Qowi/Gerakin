import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/detected_pose.dart';

/// Service khusus pengelola Google ML Kit Pose Detector.
///
/// PERFORMA & ARSITEKTUR:
/// - Menggunakan [PoseDetectionMode.stream] agar ML Kit memanfaatkan tracking temporal
///   antar frame sehingga inferensi jauh lebih cepat (~30-60 FPS) dibanding mode single image.
/// - Menjaga instance `PoseDetector` tetap hidup selama sesi kamera aktif dan
///   memastikan dipanggil `.close()` saat halaman ditutup untuk mencegah kebocoran memori native (C++).
class PoseDetectorService {
  PoseDetectorService({
    PoseDetectionModel model = PoseDetectionModel.base,
  }) : _detector = PoseDetector(
          options: PoseDetectorOptions(
            mode: PoseDetectionMode.stream,
            model: model,
          ),
        );

  final PoseDetector _detector;
  bool _isClosed = false;

  /// Memproses [InputImage] dan mengembalikan [DetectedPose] pertama jika ditemukan.
  ///
  /// Mengembalikan `null` jika tidak ada pose terdeteksi atau detector sudah di-dispose.
  Future<DetectedPose?> processImage({
    required InputImage inputImage,
    required bool isFrontCamera,
  }) async {
    if (_isClosed) return null;

    try {
      final poses = await _detector.processImage(inputImage);
      if (poses.isEmpty) return null;

      // Ambil pose utama (pertama) yang terdeteksi dalam frame
      final firstPose = poses.first;
      final imageSize = inputImage.metadata?.size ?? Size.zero;
      final rotation = inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg;

      return DetectedPose.fromMLKit(
        pose: firstPose,
        imageSize: imageSize,
        rotation: rotation,
        isFrontCamera: isFrontCamera,
      );
    } catch (e) {
      debugPrint('Error processing pose detection frame: $e');
      return null;
    }
  }

  /// Menutup instance ML Kit Pose Detector dan membebaskan native C++ resources.
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    await _detector.close();
  }
}
