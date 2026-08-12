import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Pasangan koneksi antar sendi (Skeletal Joint Connections).
class JointConnection {
  final PoseLandmarkType start;
  final PoseLandmarkType end;
  final String category; // 'torso', 'arm', 'leg'

  const JointConnection(this.start, this.end, {required this.category});
}

/// Definisi koneksi kerangka tubuh utama (Main Body Skeleton Connections).
///
/// Difokuskan pada sendi biomekanik utama (Bahu, Torso, Lengan, Kaki)
/// tanpa garis kebisingan wajah/jari untuk tampilan AR Fitness yang bersih & presisi.
class PoseConnections {
  PoseConnections._();

  static const List<JointConnection> all = [
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
