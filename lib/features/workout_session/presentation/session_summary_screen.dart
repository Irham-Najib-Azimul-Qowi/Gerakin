import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/workout_summary.dart';

/// Screen 4: Workout Session Summary Screen (Ringkasan Lengkap Hasil Latihan Rehabilitasi).
class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({
    super.key,
    required this.summary,
  });

  final WorkoutSummary summary;

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.workoutSurfaceDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Ringkasan Sesi Latihan',
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Banner Celebration Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.workoutCardDark, AppColors.workoutSurfaceDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.workoutAccentGreen, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.workoutAccentGreen.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppColors.warning, size: 64),
                  const SizedBox(height: 8),
                  Text(
                    'SESI LATIHAN SELESAI!',
                    style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary.exerciseName,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.workoutAccentGreen, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Big Score & Grade
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${summary.score.totalScore.round()}',
                          style: AppTextStyles.displayLarge.copyWith(color: AppColors.warning, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'SKOR REHABILITASI: ${summary.score.grade}',
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Key Metrics Grid
            Row(
              children: [
                _metricTile('DURASI', _formatDuration(summary.totalDurationSeconds), Icons.timer_outlined, Colors.cyanAccent),
                const SizedBox(width: 8),
                _metricTile('KALORI', '${summary.caloriesBurned.round()} kcal', Icons.local_fire_department, Colors.orangeAccent),
                const SizedBox(width: 8),
                _metricTile('REPS / SET', '${summary.totalRepsCompleted} / ${summary.totalSetsCompleted}', Icons.repeat, AppColors.workoutAccentGreen),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _metricTile('RERATA AKURASI', '${summary.averageAccuracy.round()}%', Icons.check_circle_outline, AppColors.info),
                const SizedBox(width: 8),
                _metricTile('RERATA ROM', '${summary.averageROM.round()}°', Icons.screen_rotation, Colors.purpleAccent),
                const SizedBox(width: 8),
                _metricTile('STABILITAS', '${summary.movementStability.round()}%', Icons.show_chart, Colors.tealAccent),
              ],
            ),
            const SizedBox(height: 20),

            // Best / Worst Rep Analysis Card
            if (summary.bestRep != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.workoutCardDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analisis Performa Repetisi',
                      style: AppTextStyles.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _repPerformanceCol('BEST REP', summary.bestRep!),
                        if (summary.worstRep != null) _repPerformanceCol('WORST REP', summary.worstRep!),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Achievements & XP
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.workoutCardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pencapaian & XP',
                        style: AppTextStyles.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${summary.xpEarned} XP',
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: summary.achievements
                        .map((a) => Chip(
                              avatar: const Icon(Icons.star, color: AppColors.warning, size: 16),
                              label: Text(a, style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
                              backgroundColor: Colors.black26,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Improvements & Medical Recommendations
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.workoutCardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_services_outlined, color: AppColors.workoutAccentGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Saran Fisioterapis AI',
                        style: AppTextStyles.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...summary.improvements.map((imp) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppColors.workoutAccentGreen, fontSize: 16)),
                            Expanded(
                              child: Text(
                                imp,
                                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons (Replay Session & Finish)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/workout-session/replay', extra: summary);
                    },
                    icon: const Icon(Icons.replay_rounded, color: Colors.cyanAccent),
                    label: Text(
                      'REPLAY SESI',
                      style: AppTextStyles.labelLarge.copyWith(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.cyanAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.workoutAccentGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'SIMPAN & SELESAI',
                      style: AppTextStyles.labelLarge.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.workoutCardDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(val, style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _repPerformanceCol(String tag, dynamic rep) {
    return Column(
      children: [
        Text(tag, style: AppTextStyles.labelSmall.copyWith(color: AppColors.workoutAccentGreen, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Rep #${rep.repNumber}', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        Text('Max ROM: ${rep.maxROM.round()}°', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
        Text('Akurasi: ${rep.accuracyScore.round()}%', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
      ],
    );
  }
}
