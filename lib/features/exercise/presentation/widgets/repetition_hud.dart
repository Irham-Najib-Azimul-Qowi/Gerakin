import 'package:flutter/material.dart';
import '../../domain/exercise_type.dart';

/// Top HUD Display Sesi Latihan (Set, Reps, Accuracy Quality, & Status).
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nama Latihan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exerciseType.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00BFA5), width: 0.8),
                ),
                child: Text(
                  exerciseType.category,
                  style: const TextStyle(
                    color: Color(0xFF00BFA5),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Display Counter SET & REPS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCounterItem('SET', '$currentSet / $totalSets', Colors.cyanAccent),
              Container(width: 1, height: 28, color: Colors.white12),
              _buildCounterItem('REPETISI', '$completedReps / $targetReps', const Color(0xFF00E676)),
              Container(width: 1, height: 28, color: Colors.white12),
              _buildCounterItem(
                'AKURASI',
                '${accuracyPercentage.toStringAsFixed(0)}%',
                accuracyPercentage > 80 ? Colors.greenAccent : Colors.orangeAccent,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar Akurasi / Movement Quality
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (accuracyPercentage / 100.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                accuracyPercentage > 80
                    ? const Color(0xFF00E676)
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
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
