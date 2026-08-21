import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import '../domain/movement_feedback.dart';

/// Abstract Interface untuk Text-To-Speech Service Latihan.
abstract class ExerciseTtsService {
  Future<void> speak(String text, {MovementFeedback? feedback});
  Future<void> speakMilestone(int repNumber);
  Future<void> stop();
  void setMuted(bool isMuted);
}

/// Service FlutterTTS terintegrasi dengan pengaman anti-spam & cooldown 3 detik per pesan.
class FlutterExerciseTtsService implements ExerciseTtsService {
  FlutterExerciseTtsService({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _initTts();
  }

  final FlutterTts _tts;
  final Map<String, DateTime> _lastSpokenMap = {};
  final Map<String, int> _consecutiveFrameCounts = {};

  bool _isMuted = false;
  bool _isInitialized = false;

  static const Duration _cooldownDuration = Duration(seconds: 3);
  static const int _requiredFrameThreshold = 5; // Minimal 5 frame konsisten sebelum mengucap

  @override
  void setMuted(bool isMuted) {
    _isMuted = isMuted;
    if (_isMuted) {
      _tts.stop();
    }
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('id-ID');
      await _tts.setSpeechRate(0.52);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    } catch (_) {
      try {
        await _tts.setLanguage('en-US');
        _isInitialized = true;
      } catch (_) {}
    }
  }

  @override
  Future<void> speak(String text, {MovementFeedback? feedback}) async {
    if (_isMuted || text.isEmpty) return;

    final now = DateTime.now();
    final key = feedback?.message ?? text;

    // 1. Guard Cooldown Anti-Spam (minimal 3 detik per pesan yang sama)
    final lastSpoken = _lastSpokenMap[key];
    if (lastSpoken != null && now.difference(lastSpoken) < _cooldownDuration) {
      return;
    }

    // 2. Guard Frame Threshold (kecuali pesan positif/milestone yang langsung diucapkan)
    if (feedback?.category == FeedbackCategory.correction) {
      final currentCount = (_consecutiveFrameCounts[key] ?? 0) + 1;
      _consecutiveFrameCounts[key] = currentCount;

      if (currentCount < _requiredFrameThreshold) {
        return; // Belum mencapai 5 frame konsisten
      }
    }

    // Reset frame counter setelah threshold tercapai
    _consecutiveFrameCounts[key] = 0;
    _lastSpokenMap[key] = now;

    if (_isInitialized) {
      await _tts.stop();
      await _tts.speak(feedback?.speechText ?? text);
    }
  }

  @override
  Future<void> speakMilestone(int repNumber) async {
    if (_isMuted) return;

    final wordMap = {
      1: 'Satu',
      2: 'Dua',
      3: 'Tiga',
      4: 'Empat',
      5: 'Lima',
      6: 'Enam',
      7: 'Tujuh',
      8: 'Delapan',
      9: 'Sembilan',
      10: 'Sepuluh',
    };

    final text = wordMap[repNumber] ?? '$repNumber';
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
