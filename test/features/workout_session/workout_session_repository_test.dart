import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/core/services/logger_service.dart';
import 'package:gerakin/features/workout_session/models/workout_session.dart';
import 'package:gerakin/features/workout_session/models/workout_summary.dart';
import 'package:gerakin/features/workout_session/models/workout_score.dart';
import 'package:gerakin/features/workout_session/repository/workout_session_repository.dart';

void main() {
  group('ObjectBoxWorkoutSessionRepository Tests', () {
    late ObjectBoxWorkoutSessionRepository repository;

    final testSummary = WorkoutSummary(
      sessionId: 'session_test_01',
      exerciseId: 'shoulder_abduction_01',
      exerciseName: 'Shoulder Abduction',
      totalDurationSeconds: 120,
      caloriesBurned: 24.5,
      totalRepsCompleted: 10,
      totalSetsCompleted: 3,
      averageAccuracy: 88.5,
      averageROM: 155.0,
      averageSpeedDegreesPerSec: 45.0,
      averageHoldSeconds: 2.0,
      movementStability: 90.0,
      score: const WorkoutScore(
        accuracyScore: 88.5,
        romScore: 155.0,
        smoothnessScore: 85.0,
        confidenceScore: 0.95,
        consistencyScore: 90.0,
        holdScore: 95.0,
        speedScore: 80.0,
        safetyScore: 90.0,
        totalScore: 88.0,
      ),
      xpEarned: 100,
      achievements: const ['Sesi Pertama Selesai'],
      improvements: const ['Tingkatkan stabilitas siku'],
      timestamp: DateTime(2026, 8, 25, 10, 0),
    );

    final testSession = WorkoutSessionData(
      id: 'session_test_01',
      exerciseId: 'shoulder_abduction_01',
      exerciseName: 'Shoulder Abduction',
      startTime: DateTime(2026, 8, 25, 10, 0),
      endTime: DateTime(2026, 8, 25, 10, 2),
      totalDurationSeconds: 120,
      sets: const [],
      summary: testSummary,
      recordedFrames: const [],
    );

    setUp(() {
      repository = ObjectBoxWorkoutSessionRepository(null, LoggerService());
    });

    test('Menyimpan dan membaca sesi latihan dari memory fallback saat store null', () async {
      await repository.saveSession(testSession);

      final retrieved = await repository.getSessionById('session_test_01');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('session_test_01'));
      expect(retrieved.exerciseName, equals('Shoulder Abduction'));
      expect(retrieved.summary.totalRepsCompleted, equals(10));
    });

    test('getAllSessions mengembalikan seluruh sesi yang tersimpan di fallback', () async {
      await repository.saveSession(testSession);

      final all = await repository.getAllSessions();
      expect(all.length, equals(1));
      expect(all.first.exerciseId, equals('shoulder_abduction_01'));
    });

    test('getSessionById mengembalikan null jika ID tidak ditemukan', () async {
      final retrieved = await repository.getSessionById('non_existent_id');
      expect(retrieved, isNull);
    });
  });
}
