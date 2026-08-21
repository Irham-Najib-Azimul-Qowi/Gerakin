import 'package:flutter/material.dart';

/// Overlay Dialog Istirahat Antar-Set.
class RestTimerDialog extends StatelessWidget {
  const RestTimerDialog({
    super.key,
    required this.currentSet,
    required this.totalSets,
    required this.secondsRemaining,
    required this.onSkip,
  });

  final int currentSet;
  final int totalSets;
  final int secondsRemaining;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF00BFA5), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set $currentSet Selesai! 🎉',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Istirahat sejenak untuk memulihkan otot',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Circle Timer
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: (secondsRemaining / 25.0).clamp(0.0, 1.0),
                      strokeWidth: 8,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BFA5)),
                    ),
                  ),
                  Text(
                    '${secondsRemaining}s',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Skip Rest Button
              ElevatedButton.icon(
                onPressed: onSkip,
                icon: const Icon(Icons.skip_next_rounded, color: Colors.black),
                label: Text(
                  'Mulai Set ${currentSet + 1}',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
