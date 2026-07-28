import 'package:flutter/material.dart';
import '../services/workout_validator.dart';

/// Overlay UI Kalibrasi Kamera dengan checklist visual interaktif.
class CameraCalibrationOverlay extends StatelessWidget {
  const CameraCalibrationOverlay({
    super.key,
    required this.calibrationResult,
    required this.onStartWorkout,
  });

  final CalibrationResult? calibrationResult;
  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final cal = calibrationResult;
    final isReady = cal?.isReady ?? false;

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isReady ? const Color(0xFF00E676) : Colors.amber,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isReady ? Icons.check_circle_rounded : Icons.center_focus_strong_rounded,
                color: isReady ? const Color(0xFF00E676) : Colors.amber,
                size: 56,
              ),
              const SizedBox(height: 12),
              Text(
                isReady ? 'KALIBRASI BERHASIL!' : 'KALIBRASI POSISI KAMERA',
                style: TextStyle(
                  color: isReady ? const Color(0xFF00E676) : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cal?.instructionMessage ?? 'Posisikan tubuh Anda di depan kamera',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _statusChip('Wajah', cal?.isFaceDetected ?? false),
                  _statusChip('Bahu', cal?.isShoulderDetected ?? false),
                  _statusChip('Pinggul', cal?.isHipDetected ?? false),
                  _statusChip('Jarak', cal?.isDistanceValid ?? false),
                  _statusChip('Cahaya', cal?.isLightingValid ?? false),
                  _statusChip('Seluruh Tubuh', cal?.isEntireBodyVisible ?? false),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isReady ? onStartWorkout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReady ? const Color(0xFF00E676) : Colors.grey,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'MULAI HITUNG MUNDUR',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String label, bool isValid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isValid ? const Color(0xFF00E676).withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isValid ? const Color(0xFF00E676) : Colors.redAccent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_rounded : Icons.close_rounded,
            color: isValid ? const Color(0xFF00E676) : Colors.redAccent,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isValid ? const Color(0xFF00E676) : Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
