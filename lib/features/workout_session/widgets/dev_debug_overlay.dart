import 'package:flutter/material.dart';
import '../models/movement_phase.dart';
import '../models/workout_state.dart';

/// Panel Developer Debug Mode melayang untuk diagnosa real-time telemetri AI.
class DevDebugOverlay extends StatelessWidget {
  const DevDebugOverlay({
    super.key,
    required this.currentAngle,
    required this.targetAngle,
    required this.phase,
    required this.state,
    required this.confidence,
    required this.fps,
    required this.repCount,
    required this.setCount,
    required this.processingTimeMs,
    required this.landmarkCount,
  });

  final double currentAngle;
  final double targetAngle;
  final MovementPhase phase;
  final WorkoutState state;
  final double confidence;
  final int fps;
  final int repCount;
  final int setCount;
  final double processingTimeMs;
  final int landmarkCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bug_report, color: Colors.cyanAccent, size: 14),
              SizedBox(width: 4),
              Text(
                'DEV METRICS HUD',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.cyanAccent, height: 12),
          _debugRow('State', state.name),
          _debugRow('Phase', phase.name),
          _debugRow('Angle', '${currentAngle.toStringAsFixed(1)}° / ${targetAngle.toStringAsFixed(1)}°'),
          _debugRow('Confidence', '${(confidence * 100).toStringAsFixed(1)}%'),
          _debugRow('FPS', '$fps FPS'),
          _debugRow('Rep / Set', '$repCount | Set $setCount'),
          _debugRow('Proc Time', '${processingTimeMs.toStringAsFixed(1)} ms'),
          _debugRow('Landmarks', '$landmarkCount pts'),
        ],
      ),
    );
  }

  Widget _debugRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
          Text(
            val,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
