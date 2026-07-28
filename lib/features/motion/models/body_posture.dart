/// Orientasi fisik batang tubuh (torso).
enum TorsoOrientation {
  upright,
  leaningForward,
  leaningBackward,
  tiltedSide,
}

/// Posisi relatif lengan.
enum ArmPosition {
  extended,
  bent,
  raised,
  lowered,
}

/// Arah kemiringan tubuh secara umum.
enum LeaningDirection {
  neutral,
  left,
  right,
  forward,
  backward,
}

/// Model analisis postur tubuh biomekanik.
///
/// Menyimpan informasi simetri bahu, orientasi torso, posisi lengan, dan arah kemiringan.
class BodyPosture {
  const BodyPosture({
    required this.shoulderSymmetryDiff,
    required this.isShoulderSymmetric,
    required this.torsoOrientation,
    required this.armPosition,
    required this.leaningDirection,
  });

  /// Beda tinggi/sudut simetri bahu kiri dan kanan dalam derajat.
  final double shoulderSymmetryDiff;

  /// Apakah bahu kiri dan kanan dalam batas simetris yang dapat diterima.
  final bool isShoulderSymmetric;

  /// Orientasi fisik torso.
  final TorsoOrientation torsoOrientation;

  /// Posisi lengan.
  final ArmPosition armPosition;

  /// Arah kemiringan tubuh.
  final LeaningDirection leaningDirection;

  @override
  String toString() =>
      'BodyPosture(symmetry: ${shoulderSymmetryDiff.toStringAsFixed(1)}°, torso: ${torsoOrientation.name}, arm: ${armPosition.name}, lean: ${leaningDirection.name})';
}
