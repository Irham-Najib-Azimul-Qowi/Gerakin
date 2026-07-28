import '../../camera/models/detected_pose.dart';
import 'motion_analysis.dart';

/// Container tunggal yang menggabungkan [DetectedPose] mentah dari kamera
/// dan hasil olahan biomekanik [MotionAnalysis] untuk 1 frame video stream.
class ExerciseFrame {
  const ExerciseFrame({
    required this.pose,
    required this.analysis,
    required this.frameIndex,
    required this.timestamp,
  });

  /// Data pose mentah dari ML Kit.
  final DetectedPose pose;

  /// Informasi biomekanik terolah dari Motion Engine.
  final MotionAnalysis analysis;

  /// Urutan indeks frame.
  final int frameIndex;

  /// Waktu pembuatan frame.
  final DateTime timestamp;
}
