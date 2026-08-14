/// Jenis-jenis sendi utama yang dihitung oleh Motion Engine.
enum JointType {
  leftElbow,
  rightElbow,
  leftKnee,
  rightKnee,
  leftHip,
  rightHip,
  leftShoulder,
  rightShoulder,
  neckRotation,
  neckFlexion,
}

/// Model data untuk sudut sendi terhitung.
///
/// Menyimpan jenis sendi, sudut dalam derajat ($0^\circ \le \theta \le 180^\circ$),
/// dan rerata tingkat kepercayaan (confidence score) dari 3 landmark pendukung.
class JointAngle {
  const JointAngle({
    required this.type,
    required this.angle,
    required this.confidence,
  });

  /// Jenis sendi (misal: leftElbow, rightKnee).
  final JointType type;

  /// Besar sudut sendi dalam derajat ($0^\circ$ s/d $180^\circ$).
  final double angle;

  /// Tingkat kepercayaan gabungan dari 3 titik (0.0 s/d 1.0).
  final double confidence;

  /// Apakah perhitungan sudut sendi ini cukup valid untuk dianalisis.
  bool isValid([double minConfidence = 0.5]) => confidence >= minConfidence;

  JointAngle copyWith({
    JointType? type,
    double? angle,
    double? confidence,
  }) {
    return JointAngle(
      type: type ?? this.type,
      angle: angle ?? this.angle,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  String toString() =>
      'JointAngle(${type.name}: ${angle.toStringAsFixed(1)}°, conf: ${confidence.toStringAsFixed(2)})';
}
