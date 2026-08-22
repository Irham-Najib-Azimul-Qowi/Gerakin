import 'package:flutter/material.dart';
import 'package:gerakin/core/theme/app_colors.dart';
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
    this.opacity,
    this.isVisible = true,
  });

  final ExerciseType exerciseType;
  final MovementPhase phase;
  final double? opacity;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final double targetOpacity = (opacity ?? exerciseType.defaultGuideOpacity).clamp(0.35, 0.50);
    final double activeOpacity = isVisible ? targetOpacity : 0.0;

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
          // 1. Full Screen Ghost Guide Frame dengan alignment offset (0.0, 0.16) & opacity 0.43 - 0.45
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              opacity: activeOpacity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: Align(
                  key: ValueKey<String>(guideAssetPath),
                  alignment: const Alignment(0.0, 0.16),
                  child: Image.asset(
                    guideAssetPath,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),

          // 2. Indikator Frame Aktif Translusen di Bawah (● ○ ○)
          Positioned(
            bottom: 125,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                        color: isActive ? AppColors.primary : AppColors.outlineVariant,
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
