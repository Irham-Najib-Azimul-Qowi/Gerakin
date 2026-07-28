import 'dart:convert';
import '../models/recorded_frame.dart';
import '../models/recorded_session.dart';

/// Service pemutar kembali (replay) rekaman sesi dari JSON tanpa kamera fisik.
class SessionReplay {
  SessionReplay();

  RecordedSession? _activeSession;
  int _currentIndex = 0;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;
  int get currentIndex => _currentIndex;
  int get totalFrames => _activeSession?.frames.length ?? 0;

  /// Memuat rekaman dari JSON String.
  void loadSessionFromJson(String jsonString) {
    final Map<String, dynamic> parsed = jsonDecode(jsonString);
    _activeSession = RecordedSession.fromJson(parsed);
    _currentIndex = 0;
    _isPlaying = false;
  }

  /// Memuat rekaman dari objek [RecordedSession].
  void loadSession(RecordedSession session) {
    _activeSession = session;
    _currentIndex = 0;
    _isPlaying = false;
  }

  void startReplay() {
    if (_activeSession == null || _activeSession!.frames.isEmpty) return;
    _isPlaying = true;
    _currentIndex = 0;
  }

  /// Mengambil frame berikutnya dalam replay.
  RecordedFrame? nextFrame() {
    if (!_isPlaying || _activeSession == null) return null;

    if (_currentIndex >= _activeSession!.frames.length) {
      _isPlaying = false;
      return null;
    }

    final frame = _activeSession!.frames[_currentIndex];
    _currentIndex++;
    return frame;
  }

  void stopReplay() {
    _isPlaying = false;
    _currentIndex = 0;
  }
}
