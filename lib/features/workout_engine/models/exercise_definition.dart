import '../../motion/models/joint_angle.dart';

/// Definisi data-driven untuk satu jenis latihan fisik pada GERAKIN.
class ExerciseDefinition {
  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.description,
    required this.primaryJoint,
    required this.startAngle,
    required this.targetAngle,
    required this.tolerance,
    required this.holdDuration,
    required this.repetitionTarget,
    this.setTarget = 3,
    required this.restDuration,
    required this.voiceCues,
    required this.warningMessages,
  });

  /// Identifikasi unik latihan (misal: 'arm_raise').
  final String id;

  /// Nama tampilan latihan (misal: 'Arm Raise').
  final String name;

  /// Kategori latihan (misal: 'Upper Body / Mobility').
  final String category;

  /// Tingkat kesulitan (misal: 'Beginner', 'Intermediate').
  final String difficulty;

  /// Deskripsi singkat panduan gerakan.
  final String description;

  /// Sendi utama yang diukur sudutnya.
  final JointType primaryJoint;

  /// Sudut posisi awal dalam derajat (starting posture).
  final double startAngle;

  /// Sudut target puncak dalam derajat (peak posture).
  final double targetAngle;

  /// Toleransi penyimpangan sudut dalam derajat (misal: 15.0°).
  final double tolerance;

  /// Durasi penahanan posisi puncak dalam detik (0 jika tidak ada hold).
  final int holdDuration;

  /// Target jumlah repetisi per set.
  final int repetitionTarget;

  /// Target jumlah set.
  final int setTarget;

  /// Durasi istirahat antar set dalam detik.
  final int restDuration;

  /// Daftar petunjuk / aba-aba suara.
  final List<String> voiceCues;

  /// Daftar pesan peringatan bentuk tubuh.
  final List<String> warningMessages;

  /// Apakah sudut saat ini masuk dalam toleransi puncak target.
  bool isAtTargetAngle(double currentAngle) {
    return (currentAngle - targetAngle).abs() <= tolerance;
  }

  /// Apakah sudut saat ini masuk dalam toleransi posisi awal.
  bool isAtStartAngle(double currentAngle) {
    return (currentAngle - startAngle).abs() <= tolerance;
  }
}
