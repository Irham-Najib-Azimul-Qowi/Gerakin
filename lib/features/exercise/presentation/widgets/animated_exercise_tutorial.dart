import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gerakin/core/theme/app_colors.dart';

import '../../domain/exercise_education_config.dart';

/// Widget Hero Animasi Tutorial Latihan 3-Frame (AnimatedExerciseTutorial).
///
/// PERILAKU & UX:
/// - Pre-load 3 PNG asset untuk mencegah flicker/blank saat transisi.
/// - Memutar sekuens frame sesuai [ExerciseEducationConfig.animationSequence]:
///   * Arm Raise & Curl: 1 -> 2 -> 3 -> 2 -> 1 (Looping)
///   * Neck Rotation : Center -> Right -> Center -> Left -> Center (Looping)
/// - Menampilkan gambar 9:16 pada Opacity 100% (Warna asli cerah).
/// - Dilengkapi Indikator Titik (● ○ ○) & Teks Fase Gerakan yang terus tersinkronisasi.
class AnimatedExerciseTutorial extends StatefulWidget {
  const AnimatedExerciseTutorial({
    super.key,
    required this.config,
    this.frameDuration = const Duration(milliseconds: 900),
    this.transitionDuration = const Duration(milliseconds: 220),
  });

  final ExerciseEducationConfig config;
  final Duration frameDuration;
  final Duration transitionDuration;

  @override
  State<AnimatedExerciseTutorial> createState() => _AnimatedExerciseTutorialState();
}

class _AnimatedExerciseTutorialState extends State<AnimatedExerciseTutorial> {
  Timer? _timer;
  int _sequenceIndex = 0;
  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      // Pre-cache 3 gambar PNG agar transisi 100% mulus tanpa lag
      for (final assetPath in widget.config.exerciseType.guideFrameAssets) {
        precacheImage(AssetImage(assetPath), context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _startAnimationLoop();
  }

  void _startAnimationLoop() {
    _timer = Timer.periodic(widget.frameDuration, (timer) {
      if (!mounted) return;
      setState(() {
        _sequenceIndex = (_sequenceIndex + 1) % widget.config.animationSequence.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frameAssetIndex = widget.config.animationSequence[_sequenceIndex];
    final guideAssetPath = widget.config.exerciseType.guideFrameAssets[frameAssetIndex];

    String phaseText = '';
    if (frameAssetIndex < widget.config.phaseLabels.length) {
      phaseText = widget.config.phaseLabels[frameAssetIndex];
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),

          // Container Hero Gambar Demonstrasi 9:16 (Opacity 100% Full Color)
          SizedBox(
            height: 240,
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: AnimatedSwitcher(
                duration: widget.transitionDuration,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
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
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Indikator Frame Aktif (● ○ ○)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isActive = index == frameAssetIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 12 : 7,
                height: isActive ? 12 : 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primary : AppColors.outlineVariant,
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          // Teks Penjelas Fase Gerakan Real-time
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
            ),
            child: Text(
              phaseText,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
