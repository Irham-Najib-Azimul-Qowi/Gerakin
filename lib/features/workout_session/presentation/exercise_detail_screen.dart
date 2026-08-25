import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../motion/models/joint_angle.dart';
import '../../exercise_library/models/full_exercise_definition.dart';
import '../../exercise_library/models/exercise_target_angles.dart';
import '../widgets/pre_workout_checklist.dart';

/// Screen 1: Exercise Detail Screen (Spesifikasi Lengkap Sebelum Memulai Latihan).
class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    this.exercise,
  });

  final FullExerciseDefinition? exercise;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late final FullExerciseDefinition _exercise;
  bool _isFavorite = false;
  bool _isDownloaded = false;
  bool _isChecklistComplete = false;

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise ?? _getFallbackExercise();
  }

  FullExerciseDefinition _getFallbackExercise() {
    return const FullExerciseDefinition(
      id: 'shoulder_abduction_01',
      name: 'Shoulder Abduction (Fleksi Bahu)',
      category: 'Rehabilitasi Bahu & Ekstremitas Atas',
      difficulty: 2,
      description:
          'Latihan rehabilitasi pemulihan Range of Motion (ROM) sendi bahu pasca cedera rotator cuff atau stroke.',
      benefit: 'Meningkatkan fleksibilitas kapsul sendi bahu, memperkuat otot deltoid & supraspinatus.',
      targetMuscles: ['Deltoid Anterior', 'Supraspinatus', 'Trapezius Upper'],
      requiredEquipment: 'Tanpa Alat (Bodyweight)',
      movementPattern: 'Abduksi Bahu 0 - 180 Derajat',
      startPose: 'Duduk tegak di kursi roda, kedua tangan rileks di samping panggul',
      endPose: 'Mengangkat lengan ke samping/atas hingga sejajar bahu atau telinga',
      targetAngles: ExerciseTargetAngles(
        primaryJoint: JointType.leftElbow,
        startAngle: 15.0,
        targetAngle: 160.0,
      ),
      tolerance: 15.0,
      tempo: '2-2-2',
      holdDuration: 2,
      repetitionTarget: 10,
      setTarget: 3,
      restDuration: 30,
      estimatedCalories: 15.0,
      voiceInstruction: 'Duduk tegak di kursi roda, angkat lengan perlahan ke atas hingga lurus sejajar telinga',
      warning: 'Jangan memaksakan mengangkat jika merasakan nyeri tajam pada sendi bahu',
      contraindication: 'Dislokasi bahu akut, fraktur klavikula yang belum menyambung',
      tags: ['Bahu', 'Stroke', 'Rehabilitasi', 'Kursi Roda'],
      thumbnailAsset: 'assets/exercises/shoulder_abduction.png',
      animationAsset: 'assets/exercises/shoulder_abduction.gif',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.workoutSurfaceDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Detail Latihan Rehabilitasi',
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? AppColors.error : Colors.white,
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isDownloaded ? Icons.download_done_rounded : Icons.download_rounded,
              color: _isDownloaded ? AppColors.workoutAccentGreen : Colors.white,
            ),
            onPressed: () {
              setState(() => _isDownloaded = !_isDownloaded);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isDownloaded ? 'Model latihan diunduh offline' : 'Pengunduhan dibatalkan'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tautan program latihan disalin')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Animation Banner
            GestureDetector(
              onTap: () {
                context.push(
                  '/workout-session/preview',
                  extra: {
                    'exercise': _exercise,
                    'isChecklistComplete': _isChecklistComplete,
                  },
                );
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.workoutCardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fitness_center_rounded, size: 64, color: AppColors.workoutAccentGreen),
                        const SizedBox(height: 8),
                        Text(
                          _exercise.name,
                          style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.workoutAccentGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.play_circle_fill, color: Colors.black, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'PRATINJAU GERAKAN',
                              style: AppTextStyles.labelSmall.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Info
            Text(
              _exercise.name,
              style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _exercise.category,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.workoutAccentGreen, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Specs Row Grid
            Row(
              children: [
                _specCard('SET', '${_exercise.setTarget} Set', Icons.repeat),
                const SizedBox(width: 8),
                _specCard('REPETISI', '${_exercise.repetitionTarget} Reps', Icons.format_list_numbered),
                const SizedBox(width: 8),
                _specCard('KALORI', '${_exercise.estimatedCalories.round()} kcal', Icons.local_fire_department),
                const SizedBox(width: 8),
                _specCard('TARGET ROM', '${_exercise.targetAngles.targetAngle.round()}°', Icons.screen_rotation),
              ],
            ),
            const SizedBox(height: 20),

            // Target Musculoskeletal
            _sectionTitle('Target Otot & Sendi'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _exercise.targetMuscles
                  .map((m) => Chip(
                        label: Text(m, style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
                        backgroundColor: AppColors.workoutCardDark,
                        side: const BorderSide(color: Colors.white24),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Benefits
            _sectionTitle('Manfaat Rehabilitasi'),
            const SizedBox(height: 6),
            Text(
              _exercise.benefit,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Warning & Contraindications
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'PERINGATAN & KONTRAINDIKASI',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Peringatan: ${_exercise.warning}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kontraindikasi: ${_exercise.contraindication}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pre-workout Checklist
            PreWorkoutChecklistWidget(
              onAllChecked: (isComplete) {
                setState(() => _isChecklistComplete = isComplete);
              },
            ),
            const SizedBox(height: 24),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isChecklistComplete
                    ? () {
                        context.push('/workout-session/live', extra: _exercise);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.workoutAccentGreen,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'MULAI LATIHAN',
                  style: AppTextStyles.titleMedium.copyWith(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  Widget _specCard(String title, String val, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.workoutCardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.workoutAccentGreen, size: 18),
            const SizedBox(height: 4),
            Text(title, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(val, style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
