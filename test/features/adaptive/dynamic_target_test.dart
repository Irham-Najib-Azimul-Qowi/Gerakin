import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/adaptive/models/fatigue_status.dart';
import 'package:gerakin/features/adaptive/models/physical_profile.dart';
import 'package:gerakin/features/adaptive/services/adaptive_workout_planner.dart';

void main() {
  group('Dynamic Target & Adaptive Rest Tests', () {
    late AdaptiveWorkoutPlanner planner;

    setUp(() {
      planner = const AdaptiveWorkoutPlanner();
    });

    test('Sudut target dinamis dipangkas menyesuaikan ROM bahu pengguna yang terbatas', () {
      final profile = PhysicalProfile.defaultProfile().copyWith(
        shoulderRom: 120.0,
      );

      final dynamicAngle = planner.computeDynamicTargetAngle(
        baseTargetAngle: 160.0,
        profile: profile,
      );

      expect(dynamicAngle, lessThan(160.0));
      expect(dynamicAngle, closeTo(114.0, 1.0));
    });

    test('Waktu istirahat bertambah adaptif saat terdeteksi kelelahan severe', () {
      const fatigue = FatigueStatus(
        level: FatigueLevel.severe,
        fatigueScore: 80.0,
        degradationPercentage: 80.0,
        recommendRest: true,
      );

      final restSeconds = planner.computeAdaptiveRestTime(
        baseRestSeconds: 15,
        fatigue: fatigue,
      );

      expect(restSeconds, equals(45)); // 15s base + 30s penalty
    });
  });
}
