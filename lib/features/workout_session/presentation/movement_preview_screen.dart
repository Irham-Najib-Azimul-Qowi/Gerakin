import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../exercise_library/models/full_exercise_definition.dart';

/// Screen 2: Movement Preview Screen (Pratinjau Animasi Gerakan & Kontrol Play/Pause/Replay).
class MovementPreviewScreen extends StatefulWidget {
  const MovementPreviewScreen({
    super.key,
    required this.exercise,
  });

  final FullExerciseDefinition exercise;

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
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pratinjau Gerakan AI', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF00E676), width: 1.5),
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
                                color: Color(0xFF00E676),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Sudut Simulasi: ${angleDegrees.round()}°',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 18,
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
                                  color: const Color(0xFF00E676),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isPlaying ? 'LOOPING PREVIEW' : 'PAUSED',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
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
                color: const Color(0xFF1E293B),
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
                      color: const Color(0xFF00E676),
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
                    context.push('/workout-session/live', extra: widget.exercise);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'LANJUT KE KALIBRASI KAMERA',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _stepTile(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00E676), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.white, fontSize: 13)),
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
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Petunjuk Latihan Medis', style: TextStyle(color: Colors.white)),
        content: Text(
          widget.exercise.voiceInstruction,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('MENGERTI', style: TextStyle(color: Color(0xFF00E676))),
          ),
        ],
      ),
    );
  }
}
