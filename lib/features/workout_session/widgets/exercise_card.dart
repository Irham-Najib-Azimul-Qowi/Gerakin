import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Top HUD Exercise Card pada Live Camera Screen (Sesuai DESIGN.md).
///
/// Dibuat sepenuhnya responsif dengan [Expanded] dan [FittedBox] untuk mencegah
/// RenderFlex overflow pada berbagai resolusi layar perangkat.
class ExerciseCardHUD extends StatelessWidget {
  const ExerciseCardHUD({
    super.key,
    required this.exerciseName,
    required this.currentRep,
    required this.targetReps,
    required this.currentSet,
    required this.targetSets,
    required this.elapsedSeconds,
    required this.currentAngle,
    required this.targetAngle,
    required this.poseConfidence,
  });

  final String exerciseName;
  final int currentRep;
  final int targetReps;
  final int currentSet;
  final int targetSets;
  final int elapsedSeconds;
  final double currentAngle;
  final double targetAngle;
  final double poseConfidence;

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.workoutSurfaceDark.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Baris 1: Nama Latihan & Timer ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exerciseName,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimer(elapsedSeconds),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Baris 2: 4 Kolom Metrik Responsif ──────────────────────
          Row(
            children: [
              Expanded(
                child: _metricCol(
                  'REPETISI',
                  '$currentRep / $targetReps',
                  AppColors.workoutAccentGreen,
                ),
              ),
              Expanded(
                child: _metricCol(
                  'SET',
                  '$currentSet / $targetSets',
                  AppColors.info,
                ),
              ),
              Expanded(
                child: _metricCol(
                  'SUDUT',
                  '${currentAngle.round()}° / ${targetAngle.round()}°',
                  AppColors.warning,
                ),
              ),
              Expanded(
                child: _metricCol(
                  'AKURASI',
                  '${(poseConfidence * 100).round()}%',
                  Colors.purpleAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCol(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.grey.shade400,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
