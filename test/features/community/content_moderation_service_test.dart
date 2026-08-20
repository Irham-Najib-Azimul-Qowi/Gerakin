import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/community/services/content_moderation_service.dart';

void main() {
  group('ContentModerationService Tests', () {
    late ContentModerationService moderationService;

    setUp(() {
      moderationService = ContentModerationService();
    });

    test('Harus mengembalikan false untuk teks bersih / sopan', () {
      expect(moderationService.containsProhibitedContent('Semangat latihan fisioterapi hari ini!'), false);
      expect(moderationService.containsProhibitedContent('Alhamdulillah progres hari ini mencapai target.'), false);
    });

    test('Harus mengembalikan true jika teks mengandung kata terlarang (case-insensitive)', () {
      expect(moderationService.containsProhibitedContent('Dasar goblok latihan begini saja tidak bisa'), true);
      expect(moderationService.containsProhibitedContent('ANJING banget nih rasa sakitnya'), true);
      expect(moderationService.containsProhibitedContent('Jangan FUCK disini'), true);
    });

    test('Harus mengembalikan false untuk string kosong', () {
      expect(moderationService.containsProhibitedContent(''), false);
      expect(moderationService.containsProhibitedContent('   '), false);
    });
  });
}
