import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/exercise_library/models/exercise_target_angles.dart';
import 'package:gerakin/features/exercise_library/models/full_exercise_definition.dart';
import 'package:gerakin/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:gerakin/features/gamification/models/challenge.dart';
import 'package:gerakin/features/gamification/models/goal.dart';
import 'package:gerakin/features/gamification/models/mission.dart';
import 'package:gerakin/features/gamification/models/motivation_message.dart';
import 'package:gerakin/features/gamification/models/streak.dart';
import 'package:gerakin/features/gamification/models/user_level.dart';
import 'package:gerakin/features/gamification/models/xp_transaction.dart';
import 'package:gerakin/features/gamification/services/level_engine.dart';
import 'package:gerakin/features/gamification/services/streak_engine.dart';
import 'package:gerakin/features/gamification/services/xp_engine.dart';
import 'package:gerakin/features/motion/models/joint_angle.dart';
import 'package:gerakin/features/sync/domain/repositories/sync_repository.dart';
import 'package:gerakin/features/sync/models/sync_item.dart';
import 'package:gerakin/features/sync/models/sync_result.dart';
import 'package:gerakin/features/sync/models/sync_status.dart';
import 'package:gerakin/features/workout_session/controllers/workout_session_controller.dart';
import 'package:gerakin/features/workout_session/models/workout_session.dart';
import 'package:gerakin/features/workout_session/repository/workout_session_repository.dart';

class MockWorkoutSessionRepository implements WorkoutSessionRepository {
  WorkoutSessionData? savedSession;

  @override
  Future<void> saveSession(WorkoutSessionData session) async {
    savedSession = session;
  }

  @override
  Future<WorkoutSessionData?> getSessionById(String id) async => savedSession;

  @override
  Future<List<WorkoutSessionData>> getAllSessions() async =>
      savedSession != null ? [savedSession!] : [];
}

class FakeGamificationRepository implements GamificationRepository {
  Streak? storedStreak;
  final List<XPTransaction> transactions = [];
  UserLevel storedLevel = UserLevel(
    userId: 1,
    currentLevel: 1,
    currentXP: 0,
    nextLevelXP: 100,
  );

  @override
  Future<Streak> getStreak(int userId) async {
    return storedStreak ??
        Streak(
          userId: userId,
          currentStreak: 0,
          longestStreak: 0,
          lastActiveDate: DateTime.fromMillisecondsSinceEpoch(0),
        );
  }

  @override
  Future<void> saveStreak(Streak streak) async {
    storedStreak = streak;
  }

  @override
  Future<void> addXPTransaction(XPTransaction tx) async {
    transactions.add(tx);
  }

  @override
  Future<List<XPTransaction>> getXPTransactions(int userId) async => transactions;

  @override
  Future<UserLevel> getUserLevel(int userId) async => storedLevel;

  @override
  Future<void> saveUserLevel(UserLevel level) async {
    storedLevel = level;
  }

  @override
  Future<List<Challenge>> getChallenges() async => [];
  @override
  Future<void> saveChallenge(Challenge challenge) async {}
  @override
  Future<void> clearChallenges() async {}

  @override
  Future<List<Mission>> getMissions() async => [];
  @override
  Future<void> saveMission(Mission mission) async {}
  @override
  Future<void> clearMissions() async {}

  @override
  Future<List<Goal>> getGoals(int userId) async => [];
  @override
  Future<void> saveGoal(Goal goal) async {}
  @override
  Future<void> deleteGoal(int id) async {}

  @override
  Future<List<MotivationMessage>> getMotivationMessages() async => [];
  @override
  Future<void> addMotivationMessage(MotivationMessage msg) async {}
}

class FakeSyncRepository implements SyncRepository {
  final List<Map<String, dynamic>> queue = [];

  @override
  Future<void> queueChange({
    required String collection,
    required String documentId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    queue.add({'collection': collection, 'doc': documentId, 'op': operation, 'data': data});
  }

  @override
  Future<List<SyncItem>> getPendingItems() async => [];
  @override
  Future<void> updateItem(SyncItem item) async {}
  @override
  Future<void> deleteItem(int id) async {}
  @override
  Future<SyncResult> syncItemToRemote(SyncItem item) async =>
      SyncResult(isSuccess: true);
  @override
  Future<void> saveSyncStatus(SyncStatus status) async {}
  @override
  Future<SyncStatus> getSyncStatus() async =>
      SyncStatus(lastSyncTime: DateTime.now(), status: 'idle');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutSessionController Gamification Wiring Tests', () {
    late FullExerciseDefinition testExercise;
    late MockWorkoutSessionRepository mockRepo;
    late FakeGamificationRepository fakeGamificationRepo;
    late FakeSyncRepository fakeSyncRepo;
    late StreakEngine streakEngine;
    late XPEngine xpEngine;
    late LevelEngine levelEngine;

    setUp(() {
      testExercise = const FullExerciseDefinition(
        id: 'test_exercise_01',
        name: 'Shoulder Press',
        category: 'Bahu',
        difficulty: 1,
        description: 'Test latihan',
        benefit: 'Test benefit',
        targetMuscles: ['Deltoid'],
        requiredEquipment: 'None',
        movementPattern: 'Press',
        startPose: 'Duduk tegak',
        endPose: 'Angkat ke atas',
        targetAngles: ExerciseTargetAngles(
          primaryJoint: JointType.leftElbow,
          startAngle: 90.0,
          targetAngle: 170.0,
        ),
        tolerance: 10.0,
        tempo: '2-2-2',
        holdDuration: 2,
        repetitionTarget: 5,
        setTarget: 1,
        restDuration: 15,
        estimatedCalories: 10.0,
        voiceInstruction: 'Angkat tangan',
        warning: 'Hati-hati',
        contraindication: 'None',
        tags: ['Bahu'],
        thumbnailAsset: 'asset.png',
        animationAsset: 'asset.gif',
      );

      mockRepo = MockWorkoutSessionRepository();
      fakeGamificationRepo = FakeGamificationRepository();
      fakeSyncRepo = FakeSyncRepository();
      streakEngine = StreakEngine(fakeGamificationRepo, fakeSyncRepo);
      xpEngine = XPEngine(fakeGamificationRepo);
      levelEngine = LevelEngine(fakeGamificationRepo, fakeSyncRepo);
    });

    test('finishWorkout memanggil recordActivity pada StreakEngine dan menambah streak', () async {
      final controller = WorkoutSessionController(
        initialExercise: testExercise,
        repository: mockRepo,
        streakEngine: streakEngine,
        xpEngine: xpEngine,
        levelEngine: levelEngine,
      );

      // Mulai latihan dan selesaikan
      controller.startCalibration();
      controller.startCountdown();
      controller.startCountdownComplete();

      await controller.finishWorkout();

      expect(mockRepo.savedSession, isNotNull);
      expect(fakeGamificationRepo.storedStreak, isNotNull);
      expect(fakeGamificationRepo.storedStreak!.currentStreak, equals(1));
      expect(fakeGamificationRepo.transactions.isNotEmpty, isTrue);
    });
  });
}
