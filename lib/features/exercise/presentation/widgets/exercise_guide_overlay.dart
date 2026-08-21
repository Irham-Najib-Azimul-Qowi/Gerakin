import 'package:flutter/material.dart';
import '../../domain/exercise_phase.dart';
import '../../domain/exercise_type.dart';

/// Overlay Gambar Panduan Gerakan Transparan.
///
/// BERFUNGSI:
/// - Menampilkan gambar ilustrasi pose 2D semi-transparan (opacity 0.25–0.45).
/// - Menggunakan [AnimatedSwitcher] untuk transisi halus 200ms antar-frame.
/// - Berubah secara dinamis mengikuti pergeseran [MovementPhase] pengguna (START → frame 1, MIDDLE → frame 2, TARGET → frame 3).
/// - Dibungkus [IgnorePointer] agar tidak mengganggu sentuhan UI & gesture kamera.
class ExerciseGuideOverlay extends StatelessWidget {
  const ExerciseGuideOverlay({
    super.key,
    required this.exerciseType,
    required this.phase,
    this.opacity = 0.35,
  });

  final ExerciseType exerciseType;
  final MovementPhase phase;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final guideAssetPath = exerciseType.getGuideAssetForPhase(phase);

    int activeIndex = 0;
    if (phase == MovementPhase.middle || phase == MovementPhase.returning) {
      activeIndex = 1;
    } else if (phase == MovementPhase.target) {
      activeIndex = 2;
    }

    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Gambar Ilustrasi Transparan dengan AnimatedSwitcher
          Opacity(
            opacity: opacity.clamp(0.1, 0.8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Image.asset(
                guideAssetPath,
                key: ValueKey<String>(guideAssetPath),
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.60,
              ),
            ),
          ),

          // 2. Indikator Frame Aktif Kecil (● ○ ○)
          Positioned(
            bottom: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final isActive = index == activeIndex;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 10 : 6,
                    height: isActive ? 10 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? const Color(0xFF00BFA5) : Colors.white54,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
