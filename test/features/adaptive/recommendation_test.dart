import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/adaptive/models/fatigue_status.dart';
import 'package:gerakin/features/adaptive/models/physical_profile.dart';
import 'package:gerakin/features/adaptive/services/recommendation_engine.dart';

void main() {
  group('Recommendation Engine Tests', () {
    late RecommendationEngine recommendationEngine;

    setUp(() {
      recommendationEngine = const RecommendationEngine();
    });

    test('Merekomendasikan latihan pemulihan ringan saat kelelahan severe', () {
      final profile = PhysicalProfile.defaultProfile();
      const fatigue = FatigueStatus(
        level: FatigueLevel.severe,
        fatigueScore: 85.0,
        degradationPercentage: 85.0,
        recommendRest: true,
      );

      final rec = recommendationEngine.generateRecommendation(
        profile: profile,
        fatigue: fatigue,
      );

      expect(rec.difficultyLevel, equals(1));
      expect(rec.targetReps, equals(6));
    });

    test('Merekomendasikan Shoulder Press Lanjutan untuk profil Level 4', () {
      final profile = PhysicalProfile.defaultProfile().copyWith(
        difficultyLevel: 4,
        shoulderRom: 165.0,
      );
      final fatigue = FatigueStatus.fresh();

      final rec = recommendationEngine.generateRecommendation(
        profile: profile,
        fatigue: fatigue,
      );

      expect(rec.recommendedExerciseId, equals('shoulder_press'));
      expect(rec.difficultyLevel, equals(4));
    });
  });
}
