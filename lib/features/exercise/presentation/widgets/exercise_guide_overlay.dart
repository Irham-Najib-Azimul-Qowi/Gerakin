import 'package:flutter/material.dart';
import '../../domain/exercise_phase.dart';
import '../../domain/exercise_type.dart';

/// Overlay Gambar Panduan Gerakan Transparan (Ghost Guide Reference).
///
/// FITUR & PERILAKU:
/// - Gambar 9:16 ditampilkan Full Screen (BoxFit.contain).
/// - Opacity sangat ringan (default 0.22) sebagai bayangan referensi, tanpa menutupi tubuh pengguna.
/// - Transisi antar-frame per gerakan halus dengan AnimatedSwitcher (180ms).
/// - Dibungkus [IgnorePointer] agar tidak mengganggu touch event layar.
class ExerciseGuideOverlay extends StatelessWidget {
  const ExerciseGuideOverlay({
    super.key,
    required this.exerciseType,
    required this.phase,
    this.opacity = 0.22,
    this.isVisible = true,
  });

  final ExerciseType exerciseType;
  final MovementPhase phase;
  final double opacity;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final guideAssetPath = exerciseType.getGuideAssetForPhase(phase);

    int activeIndex = 0;
    if (phase == MovementPhase.middle || phase == MovementPhase.returning) {
      activeIndex = 1;
    } else if (phase == MovementPhase.target) {
      activeIndex = 2;
    }

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // 1. Full Screen Ghost Guide Frame dengan 9:16 BoxFit.contain
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: opacity.clamp(0.12, 0.35),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
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
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),

          // 2. Indikator Frame Aktif Translusen di Bawah (● ○ ○)
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
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
                        color: isActive ? Colors.white : Colors.white38,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
