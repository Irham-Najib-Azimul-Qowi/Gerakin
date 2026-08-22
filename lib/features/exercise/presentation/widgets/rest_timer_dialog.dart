import 'package:flutter/material.dart';
import 'package:gerakin/core/theme/app_colors.dart';

/// Overlay Dialog Istirahat Antar-Set Light Translucent.
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
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          width: 310,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set $currentSet Selesai! 🎉',
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Istirahat sejenak untuk memulihkan otot',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
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
                      backgroundColor: Colors.black.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  Text(
                    '${secondsRemaining}s',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
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
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                label: Text(
                  'Mulai Set ${currentSet + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
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
