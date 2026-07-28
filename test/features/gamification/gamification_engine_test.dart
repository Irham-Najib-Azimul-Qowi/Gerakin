import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:gerakin/features/gamification/models/xp_transaction.dart';
import 'package:gerakin/features/gamification/models/user_level.dart';
import 'package:gerakin/features/gamification/models/mission.dart';
import 'package:gerakin/features/gamification/models/challenge.dart';
import 'package:gerakin/features/gamification/models/streak.dart';
import 'package:gerakin/features/gamification/models/goal.dart';
import 'package:gerakin/features/gamification/models/motivation_message.dart';
import 'package:gerakin/features/gamification/services/xp_engine.dart';
import 'package:gerakin/features/gamification/services/level_engine.dart';
import 'package:gerakin/features/gamification/services/mission_engine.dart';
import 'package:gerakin/features/gamification/services/challenge_engine.dart';
import 'package:gerakin/features/gamification/services/streak_engine.dart';
import 'package:gerakin/features/gamification/services/motivation_engine.dart';
import 'package:gerakin/features/sync/domain/repositories/sync_repository.dart';
import 'package:gerakin/features/sync/models/sync_item.dart';
import 'package:gerakin/features/sync/models/sync_status.dart';
import 'package:gerakin/features/sync/models/sync_result.dart';

/// Mock in-memory implementation dari [GamificationRepository].
class MockGamificationRepository implements GamificationRepository {
  final Map<int, XPTransaction> xpTransactions = {};
  final Map<int, UserLevel> userLevels = {};
  final List<Mission> missions = [];
  final List<Challenge> challenges = [];
  final Map<int, Streak> streaks = {};
  final Map<int, Goal> goals = {};
  final List<MotivationMessage> messages = [];

  int _idCounter = 1;

  @override
  Future<void> addXPTransaction(XPTransaction tx) async {
    tx.id = _idCounter++;
    xpTransactions[tx.id] = tx;
  }

  @override
  Future<List<XPTransaction>> getXPTransactions(int userId) async {
    return xpTransactions.values.where((x) => x.userId == userId).toList();
  }

  @override
  Future<UserLevel> getUserLevel(int userId) async {
    if (!userLevels.containsKey(userId)) {
      userLevels[userId] = UserLevel(userId: userId, currentLevel: 1, currentXP: 0, nextLevelXP: 100);
    }
    return userLevels[userId]!;
  }

  @override
  Future<void> saveUserLevel(UserLevel level) async {
    userLevels[level.userId] = level;
  }

  @override
  Future<List<Mission>> getMissions() async {
    return List.from(missions);
  }

  @override
  Future<void> saveMission(Mission mission) async {
    if (mission.id == 0) {
      mission.id = _idCounter++;
    }
    final idx = missions.indexWhere((x) => x.id == mission.id);
    if (idx != -1) {
      missions[idx] = mission;
    } else {
      missions.add(mission);
    }
  }

  @override
  Future<void> clearMissions() async {
    missions.clear();
  }

  @override
  Future<List<Challenge>> getChallenges() async {
    return List.from(challenges);
  }

  @override
  Future<void> saveChallenge(Challenge challenge) async {
    if (challenge.id == 0) {
      challenge.id = _idCounter++;
    }
    final idx = challenges.indexWhere((x) => x.id == challenge.id);
    if (idx != -1) {
      challenges[idx] = challenge;
    } else {
      challenges.add(challenge);
    }
  }

  @override
  Future<void> clearChallenges() async {
    challenges.clear();
  }

  @override
  Future<Streak> getStreak(int userId) async {
    if (!streaks.containsKey(userId)) {
      streaks[userId] = Streak(
        userId: userId,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: DateTime.fromMillisecondsSinceEpoch(0),
      );
    }
    return streaks[userId]!;
  }

  @override
  Future<void> saveStreak(Streak streak) async {
    streaks[streak.userId] = streak;
  }

  @override
  Future<List<Goal>> getGoals(int userId) async {
    return goals.values.where((x) => x.userId == userId).toList();
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    if (goal.id == 0) {
      goal.id = _idCounter++;
    }
    goals[goal.id] = goal;
  }

  @override
  Future<void> deleteGoal(int id) async {
    goals.remove(id);
  }

  @override
  Future<List<MotivationMessage>> getMotivationMessages() async {
    return List.from(messages);
  }

  @override
  Future<void> addMotivationMessage(MotivationMessage msg) async {
    msg.id = _idCounter++;
    messages.add(msg);
  }
}

/// Mock in-memory implementation dari [SyncRepository].
class MockSyncRepository implements SyncRepository {
  final List<SyncItem> syncQueue = [];

  @override
  Future<void> queueChange({
    required String collection,
    required String documentId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    syncQueue.add(SyncItem(
      collection: collection,
      documentId: documentId,
      operation: operation,
      payloadJson: '',
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<List<SyncItem>> getPendingItems() async => [];
  @override
  Future<void> updateItem(SyncItem item) async {}
  @override
  Future<void> deleteItem(int id) async {}
  @override
  Future<SyncResult> syncItemToRemote(SyncItem item) async => SyncResult(isSuccess: true);
  @override
  Future<void> saveSyncStatus(SyncStatus status) async {}
  @override
  Future<SyncStatus> getSyncStatus() async => SyncStatus(lastSyncTime: DateTime.now(), status: 'idle');
}

void main() {
  group('Gamification Subsystems Unit Tests', () {
    late MockGamificationRepository repository;
    late MockSyncRepository syncRepository;
    late XPEngine xpEngine;
    late LevelEngine levelEngine;
    late MissionEngine missionEngine;
    late ChallengeEngine challengeEngine;
    late StreakEngine streakEngine;
    late MotivationEngine motivationEngine;

    setUp(() {
      repository = MockGamificationRepository();
      syncRepository = MockSyncRepository();
      
      xpEngine = XPEngine(repository);
      levelEngine = LevelEngine(repository, syncRepository);
      missionEngine = MissionEngine(repository, xpEngine, levelEngine);
      challengeEngine = ChallengeEngine(repository, xpEngine, levelEngine);
      streakEngine = StreakEngine(repository, syncRepository);
      motivationEngine = MotivationEngine(repository);
    });

    // ── 1. XP ENGINE TESTS ──────────────────────────────────────────────
    test('XPEngine evaluates accuracy and consistency rules correctly', () async {
      // Skenario 1: Latihan sempurna (100% completion, 100% accuracy, 100% consistency)
      final perfectXP = await xpEngine.awardXPForWorkout(
        userId: 1,
        accuracy: 1.0,
        consistency: 1.0,
        completion: 1.0,
      );
      expect(perfectXP, equals(100)); // 50 base + 30 accuracy + 20 consistency

      // Skenario 2: Latihan biasa (80% accuracy, 50% consistency, 100% completion)
      final normalXP = await xpEngine.awardXPForWorkout(
        userId: 1,
        accuracy: 0.8,
        consistency: 0.5,
        completion: 1.0,
      );
      expect(normalXP, equals(84)); // 50 base + 24 accuracy + 10 consistency
    });

    // ── 2. LEVEL ENGINE TESTS ───────────────────────────────────────────
    test('LevelEngine awards XP and triggers level-up thresholds', () async {
      // Level 1: butuh 100 XP
      final initialLevel = await repository.getUserLevel(1);
      expect(initialLevel.currentLevel, equals(1));

      // Berikan 120 XP -> harus naik ke Level 2 dengan sisa 20 XP
      final nextLvl = await levelEngine.addXP(1, 120);
      expect(nextLvl.currentLevel, equals(2));
      expect(nextLvl.currentXP, equals(20));
      expect(nextLvl.nextLevelXP, equals(200)); // Level 2 ke Level 3 butuh 200 XP
    });

    // ── 3. MISSION ENGINE TESTS ─────────────────────────────────────────
    test('MissionEngine initializes and updates daily missions to completion', () async {
      await missionEngine.initializeDailyMissions();
      final missions = await repository.getMissions();
      expect(missions.length, equals(2));

      // Selesaikan misi 'Latihan Harian' (target: 1.0)
      await missionEngine.updateMissionProgress(1, workoutCount: 1.0, accuracy: 70.0);
      final updatedMissions = await repository.getMissions();
      
      final m1 = updatedMissions.firstWhere((x) => x.title == 'Latihan Harian');
      expect(m1.isCompleted, isTrue);

      // Verifikasi XP bertambah pada level user
      final userLvl = await repository.getUserLevel(1);
      expect(userLvl.currentXP, isPositive);
    });

    // ── 4. CHALLENGE ENGINE TESTS ───────────────────────────────────────
    test('ChallengeEngine updates weekly challenge progress correctly', () async {
      await challengeEngine.initializeWeeklyChallenges();
      
      // Progres latihan +1 (target: 3.0)
      await challengeEngine.updateChallengeProgress(1, workoutCount: 1.0);
      var challenges = await repository.getChallenges();
      expect(challenges.first.currentValue, equals(1.0));
      expect(challenges.first.isCompleted, isFalse);

      // Progres latihan +2 (total: 3.0)
      await challengeEngine.updateChallengeProgress(1, workoutCount: 2.0);
      challenges = await repository.getChallenges();
      expect(challenges.first.currentValue, equals(3.0));
      expect(challenges.first.isCompleted, isTrue);
    });

    // ── 5. STREAK ENGINE TESTS ──────────────────────────────────────────
    test('StreakEngine increments consecutively and resets broken streaks', () async {
      // Hari 1: Catat aktivitas pertama
      var streak = await streakEngine.recordActivity(1);
      expect(streak.currentStreak, equals(1));

      // Simulasi latihan berturut-turut besok hari (lastActiveDate -1 hari)
      final mockYesterday = DateTime.now().subtract(const Duration(days: 1));
      await repository.saveStreak(streak.copyWith(lastActiveDate: mockYesterday));

      // Catat aktivitas hari ini
      streak = await streakEngine.recordActivity(1);
      expect(streak.currentStreak, equals(2));

      // Simulasi terputus (lastActiveDate -3 hari)
      final mockThreeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      await repository.saveStreak(streak.copyWith(lastActiveDate: mockThreeDaysAgo));

      // Catat aktivitas hari ini -> streak reset ke 1
      streak = await streakEngine.recordActivity(1);
      expect(streak.currentStreak, equals(1));
    });

    // ── 6. MOTIVATION ENGINE TESTS ──────────────────────────────────────
    test('MotivationEngine retrieves messages by category', () async {
      await motivationEngine.initializeDefaultMessages();
      final msg = await motivationEngine.getRandomMessage('daily');
      expect(msg, isNotEmpty);
      expect(msg, isNot(contains('Error')));
    });
  });
}
