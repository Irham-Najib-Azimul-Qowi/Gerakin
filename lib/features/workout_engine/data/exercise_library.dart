import '../../motion/models/joint_angle.dart';
import '../models/exercise_definition.dart';
import '../repository/exercise_repository.dart';

/// Implementasi data-driven pustaka latihan fisik MVP GERAKIN.
class ExerciseLibrary implements ExerciseRepository {
  const ExerciseLibrary();

  static const ExerciseDefinition armRaise = ExerciseDefinition(
    id: 'arm_raise',
    name: 'Arm Raise',
    category: 'Upper Body & Shoulder Mobility',
    difficulty: 'Beginner',
    description:
        'Angkat kedua lengan lurus ke atas dari samping badan hingga mendekati vertikal.',
    primaryJoint: JointType.leftShoulder,
    startAngle: 25.0,
    targetAngle: 160.0,
    tolerance: 15.0,
    holdDuration: 2, // 2 detik hold di puncak
    repetitionTarget: 10,
    setTarget: 3,
    restDuration: 15,
    voiceCues: [
      'Angkat lengan tinggi ke atas',
      'Tahan posisi puncak',
      'Turunkan perlahan',
    ],
    warningMessages: [
      'Jangan membungkuk ke belakang',
      'Jaga bahu tetap rileks',
    ],
  );

  static const ExerciseDefinition shoulderPress = ExerciseDefinition(
    id: 'shoulder_press',
    name: 'Shoulder Press',
    category: 'Shoulder Strength',
    difficulty: 'Intermediate',
    description:
        'Dorong kedua siku ke atas meluruskan lengan di atas kepala.',
    primaryJoint: JointType.leftElbow,
    startAngle: 75.0,
    targetAngle: 165.0,
    tolerance: 15.0,
    holdDuration: 1,
    repetitionTarget: 10,
    setTarget: 3,
    restDuration: 20,
    voiceCues: [
      'Dorong ke atas',
      'Tahan sebentar',
      'Turunkan ke setinggi telinga',
    ],
    warningMessages: [
      'Jaga siku tidak melenceng terlalu jauh ke belakang',
    ],
  );

  static const ExerciseDefinition armExtension = ExerciseDefinition(
    id: 'arm_extension',
    name: 'Arm Extension',
    category: 'Triceps & Arm Mobility',
    difficulty: 'Beginner',
    description:
        'Luruskan siku dari posisi tekuk 90 derajat hingga lurus penuh.',
    primaryJoint: JointType.leftElbow,
    startAngle: 80.0,
    targetAngle: 170.0,
    tolerance: 12.0,
    holdDuration: 1,
    repetitionTarget: 12,
    setTarget: 3,
    restDuration: 15,
    voiceCues: [
      'Luruskan lengan ke depan',
      'Tekuk kembali siku',
    ],
    warningMessages: [
      'Kunci posisi bahu tetap stabil',
    ],
  );

  static const ExerciseDefinition forwardReach = ExerciseDefinition(
    id: 'forward_reach',
    name: 'Forward Reach',
    category: 'Core & Upper Body Reach',
    difficulty: 'Beginner',
    description:
        'Ulikan tangan lurus ke depan dari dada hingga terentang penuh.',
    primaryJoint: JointType.leftShoulder,
    startAngle: 30.0,
    targetAngle: 150.0,
    tolerance: 15.0,
    holdDuration: 2,
    repetitionTarget: 10,
    setTarget: 3,
    restDuration: 15,
    voiceCues: [
      'Jangkau ke depan sejauh mungkin',
      'Tahan posisi jangkauan',
      'Tarik kembali ke dada',
    ],
    warningMessages: [
      'Pertahankan posisi torso tetap tegak',
    ],
  );

  static const List<ExerciseDefinition> _allExercises = [
    armRaise,
    shoulderPress,
    armExtension,
    forwardReach,
  ];

  @override
  List<ExerciseDefinition> getAllExercises() => _allExercises;

  @override
  ExerciseDefinition? getExerciseById(String id) {
    try {
      return _allExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
