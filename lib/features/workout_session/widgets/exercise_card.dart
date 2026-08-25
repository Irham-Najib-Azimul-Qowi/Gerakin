import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Top HUD Exercise Card pada Live Camera Screen.
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.workoutSurfaceDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricCol('REPETISI', '$currentRep / $targetReps', AppColors.workoutAccentGreen),
              _metricCol('SET', '$currentSet / $targetSets', AppColors.info),
              _metricCol('SUDUT', '${currentAngle.round()}° / ${targetAngle.round()}°', AppColors.warning),
              _metricCol('CONFIDENCE', '${(poseConfidence * 100).round()}%', Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(color: color, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
