import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/adaptive/services/adaptive_difficulty_engine.dart';

void main() {
  group('Adaptive Difficulty Engine Tests', () {
    late AdaptiveDifficultyEngine difficultyEngine;

    setUp(() {
      difficultyEngine = const AdaptiveDifficultyEngine();
    });

    test('Menghitung Level 1 untuk ROM rendah (<125°) atau kestabilan rendah (<60)', () {
      final level = difficultyEngine.calculateDifficultyLevel(
        shoulderRom: 110.0,
        elbowRom: 120.0,
        stabilityScore: 55.0,
      );

      expect(level, equals(1));
    });

    test('Menghitung Level 3 untuk ROM menengah (150°) dan kestabilan 75%', () {
      final level = difficultyEngine.calculateDifficultyLevel(
        shoulderRom: 150.0,
        elbowRom: 160.0,
        stabilityScore: 75.0,
      );

      expect(level, equals(3));
    });

    test('Menghitung Level 5 untuk kapasitas ROM tinggi (170°) dan kestabilan 95%', () {
      final level = difficultyEngine.calculateDifficultyLevel(
        shoulderRom: 170.0,
        elbowRom: 175.0,
        stabilityScore: 95.0,
      );

      expect(level, equals(5));
    });
  });
}
