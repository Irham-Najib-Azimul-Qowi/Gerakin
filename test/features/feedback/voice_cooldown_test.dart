import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/feedback/models/feedback_message.dart';
import 'package:gerakin/features/feedback/models/feedback_priority.dart';
import 'package:gerakin/features/feedback/models/feedback_type.dart';
import 'package:gerakin/features/feedback/models/voice_settings.dart';
import 'package:gerakin/features/feedback/services/voice_feedback_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Voice Cooldown Tests', () {
    late VoiceFeedbackService voiceService;

    setUp(() {
      voiceService = VoiceFeedbackService(
        initialSettings: const VoiceSettings(
          isVoiceEnabled: true,
          cooldownSeconds: 3,
        ),
      );
    });

    test('Uji logika cooldown 3 detik antar ucapan', () async {
      final msg = FeedbackMessage(
        id: 'test_msg_id',
        type: FeedbackType.warning,
        priority: FeedbackPriority.high,
        text: 'Tes Cooldown',
        timestamp: DateTime.now(),
      );

      // Ucapan pertama dipicu
      await voiceService.speakMessage(msg);

      // Ucapan kedua dipicu seketika (< 3 detik) -> Harus di-skip (false)
      final spoken2 = await voiceService.speakMessage(msg);

      expect(spoken2, isFalse); // Terbukti di-skip oleh cooldown
    });
  });
}
