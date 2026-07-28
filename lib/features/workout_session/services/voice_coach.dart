import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/services/logger_service.dart';

enum CoachPriority {
  low,
  medium,
  high,
  emergency,
}

/// Service AI Voice Coach berbasis FlutterTTS dengan fitur anti-spam & cooldown 3 detik.
class VoiceCoach {
  VoiceCoach({FlutterTts? tts, LoggerService? logger})
      : _tts = tts ?? FlutterTts(),
        _logger = logger ?? LoggerService() {
    _initTts();
  }

  final FlutterTts _tts;
  final LoggerService _logger;

  DateTime? _lastSpokenTime;
  CoachPriority _lastPriority = CoachPriority.low;
  bool _isMuted = false;
  bool _isInitialized = false;

  static const Duration _cooldownDuration = Duration(seconds: 3);

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _tts.stop();
    }
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('id-ID');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      _logger.warning('Bisa jadi id-ID tidak tersedia, fallback ke default TTS: $e', category: 'VOICE_COACH');
      try {
        await _tts.setLanguage('en-US');
        _isInitialized = true;
      } catch (_) {}
    }
  }

  /// Mengucapkan instruksi dengan guard cooldown & batasan prioritas.
  Future<void> speak(
    String text, {
    CoachPriority priority = CoachPriority.medium,
    bool force = false,
  }) async {
    if (_isMuted || text.trim().isEmpty) return;

    final now = DateTime.now();

    // Cek cooldown 3 detik kecuali prioritas emergency atau force = true
    if (!force && priority != CoachPriority.emergency) {
      if (_lastSpokenTime != null) {
        final elapsed = now.difference(_lastSpokenTime!);
        if (elapsed < _cooldownDuration && priority.index <= _lastPriority.index) {
          // Lewati bicara untuk mencegah audio spamming
          return;
        }
      }
    }

    _lastSpokenTime = now;
    _lastPriority = priority;

    try {
      if (!_isInitialized) {
        await _initTts();
      }

      if (priority == CoachPriority.emergency || force) {
        await _tts.stop();
      }

      _logger.info('Voice Coach: "$text" (Priority: ${priority.name})', category: 'VOICE_COACH');
      await _tts.speak(text);
    } catch (e) {
      _logger.error('Gagal memproses Voice Coach TTS: $e', category: 'VOICE_COACH');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
