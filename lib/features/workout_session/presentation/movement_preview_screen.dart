import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../exercise_library/models/full_exercise_definition.dart';

/// Screen 2: Movement Preview Screen (Pratinjau Animasi Gerakan & Kontrol Play/Pause/Replay).
class MovementPreviewScreen extends StatefulWidget {
  const MovementPreviewScreen({
    super.key,
    required this.exercise,
    this.isChecklistComplete = false,
  });

  final FullExerciseDefinition exercise;
  final bool isChecklistComplete;

  @override
  State<MovementPreviewScreen> createState() => _MovementPreviewScreenState();
}

class _MovementPreviewScreenState extends State<MovementPreviewScreen> with SingleTickerProviderStateMixin {
  bool _isPlaying = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    });
  }

  void _replay() {
    _animationController.reset();
    _animationController.repeat(reverse: true);
    setState(() {
      _isPlaying = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.workoutSurfaceDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Pratinjau Gerakan AI',
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Animation Display Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.workoutCardDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.workoutAccentGreen, width: 1.5),
                ),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final angleDegrees =
                        widget.exercise.targetAngles.startAngle +
                        (_animationController.value *
                            (widget.exercise.targetAngles.targetAngle -
                                widget.exercise.targetAngles.startAngle));

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: (angleDegrees - 90) * (3.14159 / 180),
                              child: const Icon(
                                Icons.accessibility_new_rounded,
                                size: 140,
                                color: AppColors.workoutAccentGreen,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Sudut Simulasi: ${angleDegrees.round()}°',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isPlaying ? Icons.sync : Icons.pause,
                                  color: AppColors.workoutAccentGreen,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isPlaying ? 'LOOPING PREVIEW' : 'PAUSED',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Controls Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.workoutCardDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 32),
                    onPressed: _replay,
                  ),
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: AppColors.workoutAccentGreen,
                      size: 54,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 32),
                    onPressed: () {
                      _showInstructionDialog(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Instruction Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _stepTile('Posisi Awal', widget.exercise.startPose),
                  const SizedBox(height: 8),
                  _stepTile('Posisi Puncak', widget.exercise.endPose),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.isChecklistComplete) {
                      context.push('/workout-session/live', extra: widget.exercise);
                    } else {
                      _showChecklistRequiredDialog(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.workoutAccentGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'LANJUT KE KALIBRASI KAMERA',
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showChecklistRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.workoutCardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.warning, size: 26),
            const SizedBox(width: 10),
            Text('Checklist Wajib Diisi', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
          ],
        ),
        content: Text(
          'Demi keselamatan latihan mandiri, mohon lengkapi Safety Checklist pada halaman Detail Latihan sebelum melanjutkan ke kalibrasi kamera.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop(); // Kembali ke halaman Detail Latihan
            },
            child: Text(
              'LENGKAPI CHECKLIST',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.workoutAccentGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepTile(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.workoutCardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.workoutAccentGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(desc, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInstructionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.workoutCardDark,
        title: Text('Petunjuk Latihan Medis', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
        content: Text(
          widget.exercise.voiceInstruction,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('MENGERTI', style: AppTextStyles.labelLarge.copyWith(color: AppColors.workoutAccentGreen)),
          ),
        ],
      ),
    );
  }
}
