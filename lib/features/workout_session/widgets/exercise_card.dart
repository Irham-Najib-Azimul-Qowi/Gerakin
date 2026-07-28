import 'package:flutter/material.dart';

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
        color: const Color(0xFF0F172A).withValues(alpha: 0.9),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
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
              _metricCol('REPETISI', '$currentRep / $targetReps', const Color(0xFF00E676)),
              _metricCol('SET', '$currentSet / $targetSets', Colors.lightBlueAccent),
              _metricCol('SUDUT', '${currentAngle.round()}° / ${targetAngle.round()}°', Colors.amberAccent),
              _metricCol('CONFIDENCE', '${(poseConfidence * 100).round()}%', Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCol(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
