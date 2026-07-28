import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/feedback_message.dart';
import '../models/voice_settings.dart';

/// Service pengelola Text-to-Speech (TTS) untuk Voice Feedback real-time.
///
/// PERFORMA & USER EXPERIENCE:
/// - **Cooldown Minimal 3 Detik**: Mencegah pengulangan pesan suara secara berlebihan
///   yang dapat mengganggu fokus pengguna saat berolahraga.
/// - Mendukung pengalihan Voice ON/OFF, kontrol volume, dan pengaturan kecepatan bicara.
class VoiceFeedbackService {
  VoiceFeedbackService({
    FlutterTts? tts,
    VoiceSettings initialSettings = const VoiceSettings(),
  })  : _tts = tts ?? FlutterTts(),
        _settings = initialSettings {
    _initTts();
  }

  final FlutterTts _tts;
  VoiceSettings _settings;
  final Map<String, int> _lastSpokenTimestamps = {};
  bool _isSpeaking = false;

  VoiceSettings get settings => _settings;

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('id-ID'); // Bahasa Indonesia
      await _tts.setVolume(_settings.volume);
      await _tts.setSpeechRate(_settings.speechRate);
      await _tts.setPitch(_settings.pitch);

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });
    } catch (e) {
      debugPrint('Error initializing FlutterTts: $e');
    }
  }

  /// Memperbarui konfigurasi suara.
  Future<void> updateSettings(VoiceSettings newSettings) async {
    _settings = newSettings;
    try {
      await _tts.setVolume(_settings.volume);
      await _tts.setSpeechRate(_settings.speechRate);
      await _tts.setPitch(_settings.pitch);
    } catch (e) {
      debugPrint('Error updating FlutterTts settings: $e');
    }
  }

  /// Memutar pesan [message] jika voice diaktifkan dan memenuhi jeda cooldown.
  ///
  /// Mengembalikan `true` jika pesan berhasil diucapkan, atau `false` jika di-skip.
  Future<bool> speakMessage(FeedbackMessage message) async {
    if (!_settings.isVoiceEnabled) return false;
    if (_isSpeaking) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastSpoken = _lastSpokenTimestamps[message.id] ?? 0;
    final cooldownMs = _settings.cooldownSeconds * 1000;

    // Skip jika belum melewati masa cooldown
    if (now - lastSpoken < cooldownMs) {
      return false;
    }

    _lastSpokenTimestamps[message.id] = now;
    _isSpeaking = true;

    try {
      await _tts.speak(message.speechText);
      return true;
    } catch (e) {
      _isSpeaking = false;
      debugPrint('Error in speakMessage: $e');
      return false;
    }
  }

  /// Menghentikan ucapan yang sedang berjalan.
  Future<void> stop() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  /// Reset riwayat cooldown.
  void resetCooldown() {
    _lastSpokenTimestamps.clear();
    _isSpeaking = false;
  }
}
