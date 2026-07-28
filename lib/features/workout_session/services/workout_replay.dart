import 'dart:async';
import '../models/recorded_frame.dart';

/// Engine pemutaran ulang (Replay Engine) untuk visualisasi pergerakan fisioterapis & pengguna.
class WorkoutReplayEngine {
  WorkoutReplayEngine({required this.frames});

  final List<RecordedFrame> frames;

  int _currentFrameIndex = 0;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  Timer? _playbackTimer;

  int get currentFrameIndex => _currentFrameIndex;
  bool get isPlaying => _isPlaying;
  double get playbackSpeed => _playbackSpeed;
  int get totalFrames => frames.length;

  RecordedFrame? get currentFrame =>
      frames.isNotEmpty && _currentFrameIndex < frames.length ? frames[_currentFrameIndex] : null;

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    if (_isPlaying) {
      play(onFrameUpdate: (_) {});
    }
  }

  void play({required Function(RecordedFrame frame) onFrameUpdate}) {
    if (frames.isEmpty) return;
    _isPlaying = true;
    _playbackTimer?.cancel();

    final intervalMs = (66 / _playbackSpeed).round(); // ~15 FPS simulation

    _playbackTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (_currentFrameIndex < frames.length - 1) {
        _currentFrameIndex += 1;
        onFrameUpdate(frames[_currentFrameIndex]);
      } else {
        pause();
      }
    });
  }

  void pause() {
    _isPlaying = false;
    _playbackTimer?.cancel();
  }

  void seekToFrame(int index) {
    if (index >= 0 && index < frames.length) {
      _currentFrameIndex = index;
    }
  }

  void dispose() {
    _playbackTimer?.cancel();
  }
}
