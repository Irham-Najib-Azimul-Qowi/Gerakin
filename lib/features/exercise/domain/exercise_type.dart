import 'exercise_phase.dart';

/// 3 Jenis Latihan Utama berbasis Computer Vision untuk Pengguna Kursi Roda.
enum ExerciseType {
  sideArmRaise(
    id: 'seated_side_arm_raise',
    displayName: 'Seated Side Arm Raise',
    category: 'Upper Body Mobility & Strength',
    description: 'Angkat kedua lengan dari samping tubuh hingga sejajar dengan bahu, lalu turunkan kembali secara perlahan.',
    targetMuscles: ['Deltoid Anterior', 'Deltoid Lateral', 'Trapezius'],
    guideFrameAssets: [
      'assets/exercises_processed/arm_raise/arm_raise_1.png',
      'assets/exercises_processed/arm_raise/arm_raise_2.png',
      'assets/exercises_processed/arm_raise/arm_raise_3.png',
    ],
  ),
  bicepCurl(
    id: 'seated_bicep_curl',
    displayName: 'Seated Bicep Curl',
    category: 'Arm Strength',
    description: 'Tekuk kedua siku dari posisi hampir lurus ke arah bahu, lalu turunkan secara terkontrol.',
    targetMuscles: ['Biceps Brachii', 'Brachialis', 'Forearms'],
    guideFrameAssets: [
      'assets/exercises_processed/bicep_curl/bicep_curl_1.png',
      'assets/exercises_processed/bicep_curl/bicep_curl_2.png',
      'assets/exercises_processed/bicep_curl/bicep_curl_3.png',
    ],
  ),
  neckRotation(
    id: 'seated_neck_rotation',
    displayName: 'Seated Neck Rotation',
    category: 'Cervical Mobility & Balance',
    description: 'Putar kepala secara lembut dan konstan: Depan → Kanan → Depan → Kiri → Depan.',
    targetMuscles: ['Sternocleidomastoid', 'Splenius Capitis', 'Trapezius Upper'],
    guideFrameAssets: [
      'assets/exercises_processed/neck_rotation/neck_rotation_1.png',
      'assets/exercises_processed/neck_rotation/neck_rotation_2.png',
      'assets/exercises_processed/neck_rotation/neck_rotation_3.png',
    ],
  );

  const ExerciseType({
    required this.id,
    required this.displayName,
    required this.category,
    required this.description,
    required this.targetMuscles,
    required this.guideFrameAssets,
  });

  final String id;
  final String displayName;
  final String category;
  final String description;
  final List<String> targetMuscles;
  final List<String> guideFrameAssets;

  /// Mengambil path asset gambar panduan berdasarkan [MovementPhase]
  String getGuideAssetForPhase(MovementPhase phase) {
    switch (phase) {
      case MovementPhase.start:
        return guideFrameAssets[0];
      case MovementPhase.middle:
      case MovementPhase.returning:
        return guideFrameAssets[1];
      case MovementPhase.target:
        return guideFrameAssets[2];
    }
  }

  static ExerciseType fromId(String id) {
    return ExerciseType.values.firstWhere(
      (e) => e.id == id || e.name == id,
      orElse: () => ExerciseType.sideArmRaise,
    );
  }
}
