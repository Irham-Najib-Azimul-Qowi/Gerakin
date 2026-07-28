import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/analytics/models/workout_session.dart';
import 'package:gerakin/features/analytics/models/recovery_progress.dart';
import 'package:gerakin/features/analytics/services/analytics_engine.dart';
import 'package:gerakin/features/analytics/services/progress_calculator.dart';
import 'package:gerakin/features/analytics/services/weekly_summary_generator.dart';
import 'package:gerakin/features/analytics/services/monthly_summary_generator.dart';
import 'package:gerakin/features/analytics/services/achievement_engine.dart';
import 'package:gerakin/features/analytics/services/export_service.dart';

void main() {
  group('Analytics Engine Unit Tests', () {
    late List<WorkoutSession> mockSessions;
    late List<RecoveryProgress> mockRecovery;

    setUp(() {
      // 27 Juli 2026 adalah hari Senin
      mockSessions = [
        WorkoutSession(
          id: 1,
          workoutId: 'w1',
          workoutName: 'Squat Therapy',
          startTime: DateTime(2026, 7, 27, 8, 30), // Senin
          durationInSeconds: 600, // 10 menit
          caloriesBurned: 150.0,
          completedReps: 15,
          targetReps: 15,
          accuracy: 95.0,
          averageRom: 130.0,
          isCompleted: true,
          recoveryScore: 80,
        ),
        WorkoutSession(
          id: 2,
          workoutId: 'w2',
          workoutName: 'Shoulder Press',
          startTime: DateTime(2026, 7, 28, 10, 0), // Selasa
          durationInSeconds: 900, // 15 menit
          caloriesBurned: 250.0,
          completedReps: 20,
          targetReps: 25,
          accuracy: 85.0,
          averageRom: 110.0,
          isCompleted: false,
          recoveryScore: 75,
        ),
        WorkoutSession(
          id: 3,
          workoutId: 'w1',
          workoutName: 'Squat Therapy',
          startTime: DateTime(2026, 7, 29, 17, 0), // Rabu
          durationInSeconds: 300, // 5 menit
          caloriesBurned: 100.0,
          completedReps: 10,
          targetReps: 10,
          accuracy: 92.0,
          averageRom: 125.0,
          isCompleted: true,
          recoveryScore: 85,
        ),
      ];

      mockRecovery = [
        RecoveryProgress(
          id: 1,
          date: DateTime(2026, 7, 27, 21, 0),
          perceivedPainLevel: 2,
          fatigueLevel: 3,
          sleepQualityScore: 85,
          heartRateVariability: 55.0,
          muscleSorenessScore: 3,
          overallRecoveryScore: 82,
        ),
        RecoveryProgress(
          id: 2,
          date: DateTime(2026, 7, 28, 21, 0),
          perceivedPainLevel: 1,
          fatigueLevel: 2,
          sleepQualityScore: 90,
          heartRateVariability: 60.0,
          muscleSorenessScore: 2,
          overallRecoveryScore: 88,
        ),
      ];
    });

    // ── PROGRESS CALCULATOR TESTS ───────────────────────────────────────
    test('ProgressCalculator calculateStatistics computes valid aggregate metrics', () {
      final calculator = ProgressCalculator();
      final stats = calculator.calculateStatistics(mockSessions);

      expect(stats.totalSessions, equals(3));
      expect(stats.totalDurationInMinutes, equals(30.0)); // (600 + 900 + 300) / 60
      expect(stats.totalCalories, equals(500.0)); // 150 + 250 + 100
      expect(stats.averageAccuracy, closeTo(90.66, 0.01)); // (95 + 85 + 92) / 3
      expect(stats.averageRom, closeTo(121.66, 0.01)); // (130 + 110 + 125) / 3
      expect(stats.completionRate, closeTo(66.66, 0.01)); // 2/3 completed
    });

    test('ProgressCalculator trends calculate in correct chronological order', () {
      final calculator = ProgressCalculator();
      final romTrend = calculator.calculateRomTrend(mockSessions);
      final accuracyTrend = calculator.calculateAccuracyTrend(mockSessions);

      expect(romTrend, equals([130.0, 110.0, 125.0]));
      expect(accuracyTrend, equals([95.0, 85.0, 92.0]));
    });

    // ── WEEKLY SUMMARY GENERATOR TESTS ──────────────────────────────────
    test('WeeklySummaryGenerator correctly groups and aggregates weekly sessions', () {
      final generator = WeeklySummaryGenerator();
      final targetDate = DateTime(2026, 7, 28); // Selasa di dalam minggu yang sama
      final summary = generator.generate(mockSessions, targetDate);

      // Pastikan rentang tanggal mencakup Senin (27 Jul) s.d Minggu (2 Agt)
      expect(summary.startDate.year, equals(2026));
      expect(summary.startDate.month, equals(7));
      expect(summary.startDate.day, equals(27));

      expect(summary.totalSessions, equals(3));
      expect(summary.totalCalories, equals(500.0));
      expect(summary.dailySessionCounts, equals([1, 1, 1, 0, 0, 0, 0])); // Senin, Selasa, Rabu masing-masing 1
      expect(summary.dailyAccuracy[0], equals(95.0)); // Senin
      expect(summary.dailyAccuracy[1], equals(85.0)); // Selasa
      expect(summary.dailyAccuracy[2], equals(92.0)); // Rabu
    });

    // ── MONTHLY SUMMARY GENERATOR TESTS ─────────────────────────────────
    test('MonthlySummaryGenerator correctly groups monthly sessions into weekly periods', () {
      final generator = MonthlySummaryGenerator();
      final summary = generator.generate(mockSessions, 2026, 7);

      expect(summary.year, equals(2026));
      expect(summary.month, equals(7));
      expect(summary.totalSessions, equals(3));
      expect(summary.totalCalories, equals(500.0));
      
      // Hari 27, 28, 29 Juli jatuh di minggu 4 (>22 Juli)
      expect(summary.weeklyAccuracy[0], equals(0.0)); // Minggu 1
      expect(summary.weeklyAccuracy[3], closeTo(90.66, 0.01)); // Minggu 4
    });

    // ── ACHIEVEMENT ENGINE TESTS ────────────────────────────────────────
    test('AchievementEngine unlocks correct achievements based on workout goals', () {
      final engine = AchievementEngine();
      final defaults = engine.defaultAchievements;
      final results = engine.evaluateAchievements(sessions: mockSessions, currentAchievements: defaults);

      // Cari medali Langkah Pertama
      final firstStep = results.firstWhere((a) => a.achievementId == 'first_step');
      expect(firstStep.isUnlocked, isTrue);
      expect(firstStep.progress, equals(1.0));

      // Cari medali Akurasi Sempurna (accuracy >= 90)
      final perfectAcc = results.firstWhere((a) => a.achievementId == 'perfect_accuracy');
      expect(perfectAcc.isUnlocked, isTrue);

      // Cari medali Konsistensi (target 5 sesi, baru selesai 3)
      final consistent = results.firstWhere((a) => a.achievementId == 'consistent_athlete');
      expect(consistent.isUnlocked, isFalse);
      expect(consistent.progress, equals(0.6)); // 3 / 5

      // Cari medali Pembakar Kalori (target 500 kkal, total kkal 500)
      final burner = results.firstWhere((a) => a.achievementId == 'calorie_burner');
      expect(burner.isUnlocked, isTrue);
      expect(burner.progress, equals(1.0));
    });

    // ── EXPORT SERVICE TESTS ────────────────────────────────────────────
    test('ExportService CSV generator builds non-empty comma-separated output', () {
      final exporter = ExportService();
      final csv = exporter.exportSessionsToCsv(mockSessions);

      expect(csv, isNotEmpty);
      expect(csv, contains('Nama Gerakan'));
      expect(csv, contains('Squat Therapy'));
      expect(csv, contains('Shoulder Press'));
    });

    test('ExportService PDF generator compiles valid non-empty byte buffer', () async {
      final exporter = ExportService();
      final pdfBytes = await exporter.exportSessionsToPdf(mockSessions);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes, isA<Uint8List>());
      expect(pdfBytes.length, isPositive);
    });

    // ── ANALYTICS ENGINE (FACADE) TESTS ─────────────────────────────────
    test('AnalyticsEngine delegates calculations correctly as a clean Facade', () {
      final engine = AnalyticsEngine();
      
      final stats = engine.calculateOverallStats(mockSessions);
      expect(stats.totalSessions, equals(3));

      final weekly = engine.generateWeeklySummary(mockSessions, DateTime(2026, 7, 27));
      expect(weekly.totalSessions, equals(3));

      final avgRecovery = engine.getAverageRecovery(mockRecovery);
      expect(avgRecovery, equals(85.0)); // (82 + 88) / 2
    });
  });
}
