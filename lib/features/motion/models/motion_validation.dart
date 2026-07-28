/// Enum status validasi kualitas gerakan biomekanik.
enum MotionValidationStatus {
  /// Gerakan valid dan berada dalam rentang & kecepatan yang benar.
  valid,

  /// Gerakan terlalu cepat (terlalu banyak momentum, rentan cedera).
  tooFast,

  /// Gerakan terlalu lambat (tidak aktif atau kehilangan ritme).
  tooSlow,

  /// Gerakan tidak lengkap (range of motion belum tercapai).
  incomplete,

  /// Tubuh atau sendi berada di luar jangkauan sensor / kamera.
  outOfRange,
}

/// Extension helper untuk [MotionValidationStatus].
extension MotionValidationStatusX on MotionValidationStatus {
  bool get isValid => this == MotionValidationStatus.valid;
  bool get isTooFast => this == MotionValidationStatus.tooFast;
  bool get isTooSlow => this == MotionValidationStatus.tooSlow;
  bool get isIncomplete => this == MotionValidationStatus.incomplete;
  bool get isOutOfRange => this == MotionValidationStatus.outOfRange;

  String get description {
    switch (this) {
      case MotionValidationStatus.valid:
        return 'Gerakan Bagus!';
      case MotionValidationStatus.tooFast:
        return 'Gerakan Terlalu Cepat';
      case MotionValidationStatus.tooSlow:
        return 'Gerakan Terlalu Lambat';
      case MotionValidationStatus.incomplete:
        return 'Rentang Gerak Belum Penuh';
      case MotionValidationStatus.outOfRange:
        return 'Tubuh Di Luar Jangkauan Kamera';
    }
  }
}
