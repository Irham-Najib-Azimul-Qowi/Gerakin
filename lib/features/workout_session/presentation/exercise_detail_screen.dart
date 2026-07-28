import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          'Latihan rehabilitasi pemulihan Range of Motion (ROM) sendi bahu pasca cedera rotaror cuff atau stroke.',
      benefit: 'Meningkatkan fleksibilitas kapsul sendi bahu, memperkuat otot deltoid & supraspinatus.',
      targetMuscles: ['Deltoid Anterior', 'Supraspinatus', 'Trapezius Upper'],
      requiredEquipment: 'Tanpa Alat (Bodyweight)',
      movementPattern: 'Abduksi Bahu 0 - 180 Derajat',
      startPose: 'Berdiri tegak, tangan rileks di samping panggul',
      endPose: 'Mengangkat lengan ke atas sejajar telinga',
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
      voiceInstruction: 'Angkat lengan perlahan ke atas hingga lurus sejajar telinga',
      warning: 'Jangan memaksakan mengangkat jika merasakan nyeri tajam',
      contraindication: 'Dislokasi bahu akut, fraktur klavikula yang belum menyambung',
      tags: ['Bahu', 'Stroke', 'Rehabilitasi'],
      thumbnailAsset: 'assets/exercises/shoulder_abduction.png',
      animationAsset: 'assets/exercises/shoulder_abduction.gif',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Detail Latihan Rehabilitasi', style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.redAccent : Colors.white,
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
              color: _isDownloaded ? const Color(0xFF00E676) : Colors.white,
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
                context.push('/workout-session/preview', extra: _exercise);
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fitness_center_rounded, size: 64, color: Color(0xFF00E676)),
                        const SizedBox(height: 8),
                        Text(
                          _exercise.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.play_circle_fill, color: Colors.black, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'PRATINJAU GERAKAN',
                              style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
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
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _exercise.category,
              style: const TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.w600),
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
                        label: Text(m, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: const Color(0xFF1E293B),
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
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Warning & Contraindications
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'PERINGATAN & KONTRAINDIKASI',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Peringatan: ${_exercise.warning}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kontraindikasi: ${_exercise.contraindication}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'MULAI LATIHAN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Widget _specCard(String title, String val, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00E676), size: 18),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
