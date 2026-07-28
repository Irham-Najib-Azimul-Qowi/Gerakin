import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Model data ringan untuk merepresentasikan satu landmark (titik sendi) pose.
///
/// Menyimpan tipe titik sendi, koordinat 3D (x, y, z), dan tingkat kepercayaan (likelihood).
class PoseLandmarkModel {
  const PoseLandmarkModel({
    required this.type,
    required this.x,
    required this.y,
    required this.z,
    required this.likelihood,
  });

  /// Konversi dari ML Kit [PoseLandmark].
  factory PoseLandmarkModel.fromMLKit(PoseLandmark landmark) {
    return PoseLandmarkModel(
      type: landmark.type,
      x: landmark.x,
      y: landmark.y,
      z: landmark.z,
      likelihood: landmark.likelihood,
    );
  }

  /// Tipe sendi (misal: nose, leftShoulder, rightElbow, dsb).
  final PoseLandmarkType type;

  /// Koordinat X pada sistem koordinat gambar sensor.
  final double x;

  /// Koordinat Y pada sistem koordinat gambar sensor.
  final double y;

  /// Koordinat Z (kedalaman relatif).
  final double z;

  /// Likelihood / confidence score (0.0 s/d 1.0).
  final double likelihood;

  /// Threshold minimum kualifikasi landmark valid (misal 0.5 = 50% confidence).
  bool isValid([double threshold = 0.5]) => likelihood >= threshold;
}
