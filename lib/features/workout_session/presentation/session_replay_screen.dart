import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/workout_summary.dart';
import '../services/workout_replay.dart';

/// Screen 5: Session Replay Screen (Pemutaran Ulang Frame Skeleton Telemetri Latihan).
class SessionReplayScreen extends StatefulWidget {
  const SessionReplayScreen({
    super.key,
    required this.summary,
  });

  final WorkoutSummary summary;

  @override
  State<SessionReplayScreen> createState() => _SessionReplayScreenState();
}

class _SessionReplayScreenState extends State<SessionReplayScreen> {
  late final WorkoutReplayEngine _replayEngine;
  bool _isPlaying = false;
  double _currentSliderVal = 0;

  @override
  void initState() {
    super.initState();
    _replayEngine = WorkoutReplayEngine(frames: const []);
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _replayEngine.dispose();
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
          'Visualisasi Replay Fisioterapis',
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
            // Replay Skeleton Canvas Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.workoutCardDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.cyanAccent, width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.psychology_rounded, size: 96, color: Colors.cyanAccent),
                        const SizedBox(height: 16),
                        Text(
                          widget.summary.exerciseName,
                          style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sesi Replay: ${widget.summary.sessionId}',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
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
                            const Icon(Icons.videocam_rounded, color: Colors.cyanAccent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'SKELETON PLAYBACK MODE',
                              style: AppTextStyles.labelSmall.copyWith(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Timeline Scrubber Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text('00:00', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey)),
                  Expanded(
                    child: Slider(
                      value: _currentSliderVal,
                      max: 100,
                      activeColor: Colors.cyanAccent,
                      inactiveColor: Colors.white24,
                      onChanged: (val) {
                        setState(() => _currentSliderVal = val);
                      },
                    ),
                  ),
                  Text(
                    '${(widget.summary.totalDurationSeconds ~/ 60).toString().padLeft(2, '0')}:${(widget.summary.totalDurationSeconds % 60).toString().padLeft(2, '0')}',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Replay Playback Controls
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.workoutCardDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.fast_rewind_rounded, color: Colors.white, size: 28),
                    onPressed: () {
                      setState(() => _currentSliderVal = 0);
                    },
                  ),
                  FloatingActionButton(
                    heroTag: 'replay_play_btn',
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    onPressed: _togglePlayPause,
                    child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 32),
                  ),
                  IconButton(
                    icon: const Icon(Icons.speed_rounded, color: Colors.white, size: 28),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kecepatan replay: 1.0x')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
