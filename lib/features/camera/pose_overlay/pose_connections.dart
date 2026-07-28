import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Pasangan koneksi antar sendi (Skeletal Joint Connections).
class JointConnection {
  final PoseLandmarkType start;
  final PoseLandmarkType end;
  final String category; // 'head', 'torso', 'arm', 'leg'

  const JointConnection(this.start, this.end, {required this.category});
}

/// Definisi lengkap seluruh koneksi kerangka tubuh (Skeleton Connections) standar MediaPipe / ML Kit.
class PoseConnections {
  PoseConnections._();

  static const List<JointConnection> all = [
    // ── HEAD ──────────────────────────────────────────────
    JointConnection(PoseLandmarkType.nose, PoseLandmarkType.leftEyeInner, category: 'head'),
    JointConnection(PoseLandmarkType.leftEyeInner, PoseLandmarkType.leftEye, category: 'head'),
    JointConnection(PoseLandmarkType.leftEye, PoseLandmarkType.leftEyeOuter, category: 'head'),
    JointConnection(PoseLandmarkType.leftEyeOuter, PoseLandmarkType.leftEar, category: 'head'),
    JointConnection(PoseLandmarkType.nose, PoseLandmarkType.rightEyeInner, category: 'head'),
    JointConnection(PoseLandmarkType.rightEyeInner, PoseLandmarkType.rightEye, category: 'head'),
    JointConnection(PoseLandmarkType.rightEye, PoseLandmarkType.rightEyeOuter, category: 'head'),
    JointConnection(PoseLandmarkType.rightEyeOuter, PoseLandmarkType.rightEar, category: 'head'),
    JointConnection(PoseLandmarkType.leftMouth, PoseLandmarkType.rightMouth, category: 'head'),

    // ── SHOULDERS & TORSO ─────────────────────────────────
    JointConnection(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, category: 'torso'),
    JointConnection(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, category: 'torso'),
    JointConnection(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, category: 'torso'),
    JointConnection(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, category: 'torso'),

    // ── ARMS ──────────────────────────────────────────────
    JointConnection(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, category: 'arm'),
    JointConnection(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, category: 'arm'),
    JointConnection(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, category: 'arm'),
    JointConnection(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, category: 'arm'),

    // ── LEGS ──────────────────────────────────────────────
    JointConnection(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, category: 'leg'),
    JointConnection(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, category: 'leg'),
    JointConnection(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, category: 'leg'),
    JointConnection(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, category: 'leg'),
  ];
}
