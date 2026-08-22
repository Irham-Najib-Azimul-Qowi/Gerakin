import 'package:flutter/material.dart';
import 'package:gerakin/core/theme/app_colors.dart';
import '../../domain/exercise_type.dart';

/// Top HUD Display Sesi Latihan Light Translucent (Set, Reps, Accuracy Quality, & Status).
class RepetitionHud extends StatelessWidget {
  const RepetitionHud({
    super.key,
    required this.exerciseType,
    required this.currentSet,
    required this.totalSets,
    required this.completedReps,
    required this.targetReps,
    required this.accuracyPercentage,
  });

  final ExerciseType exerciseType;
  final int currentSet;
  final int totalSets;
  final int completedReps;
  final int targetReps;
  final double accuracyPercentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nama Latihan & Kategori Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exerciseType.displayName,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.30), width: 0.8),
                ),
                child: Text(
                  exerciseType.category,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Display Counter SET, REPETISI & AKURASI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCounterItem('SET', '$currentSet / $totalSets', AppColors.secondaryDark),
              Container(width: 1, height: 26, color: Colors.black.withValues(alpha: 0.08)),
              _buildCounterItem('REPETISI', '$completedReps / $targetReps', AppColors.primaryDark),
              Container(width: 1, height: 26, color: Colors.black.withValues(alpha: 0.08)),
              _buildCounterItem(
                'AKURASI',
                '${accuracyPercentage.toStringAsFixed(0)}%',
                accuracyPercentage > 80
                    ? const Color(0xFF008E76)
                    : accuracyPercentage > 60
                        ? const Color(0xFFD97706)
                        : const Color(0xFFDC2626),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar Akurasi / Movement Quality
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (accuracyPercentage / 100.0).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                accuracyPercentage > 80
                    ? AppColors.primary
                    : accuracyPercentage > 60
                        ? Colors.amber
                        : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterItem(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
