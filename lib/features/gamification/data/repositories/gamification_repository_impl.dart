import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local/objectbox_store.dart';
import '../../../../objectbox.g.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../../models/xp_transaction.dart';
import '../../models/user_level.dart';
import '../../models/mission.dart';
import '../../models/challenge.dart';
import '../../models/streak.dart';
import '../../models/goal.dart';
import '../../models/motivation_message.dart';

/// Implementasi [GamificationRepository] menggunakan ObjectBox.
class GamificationRepositoryImpl implements GamificationRepository {
  final Box<XPTransaction> _xpBox;
  final Box<UserLevel> _levelBox;
  final Box<Mission> _missionBox;
  final Box<Challenge> _challengeBox;
  final Box<Streak> _streakBox;
  final Box<Goal> _goalBox;
  final Box<MotivationMessage> _msgBox;

  GamificationRepositoryImpl(Store store)
      : _xpBox = store.box<XPTransaction>(),
        _levelBox = store.box<UserLevel>(),
        _missionBox = store.box<Mission>(),
        _challengeBox = store.box<Challenge>(),
        _streakBox = store.box<Streak>(),
        _goalBox = store.box<Goal>(),
        _msgBox = store.box<MotivationMessage>();

  @override
  Future<void> addXPTransaction(XPTransaction tx) async {
    _xpBox.put(tx);
  }

  @override
  Future<List<XPTransaction>> getXPTransactions(int userId) async {
    final query = (_xpBox.query(XPTransaction_.userId.equals(userId))).build();
    final results = query.find();
    query.close();
    return results;
  }

  @override
  Future<UserLevel> getUserLevel(int userId) async {
    final query = (_levelBox.query(UserLevel_.userId.equals(userId))).build();
    final results = query.find();
    query.close();

    if (results.isEmpty) {
      // Inisialisasi level awal jika belum ada
      final newLvl = UserLevel(userId: userId, currentLevel: 1, currentXP: 0, nextLevelXP: 100);
      _levelBox.put(newLvl);
      return newLvl;
    }
    return results.first;
  }

  @override
  Future<void> saveUserLevel(UserLevel level) async {
    _levelBox.put(level);
  }

  @override
  Future<List<Mission>> getMissions() async {
    return _missionBox.getAll();
  }

  @override
  Future<void> saveMission(Mission mission) async {
    _missionBox.put(mission);
  }

  @override
  Future<void> clearMissions() async {
    _missionBox.removeAll();
  }

  @override
  Future<List<Challenge>> getChallenges() async {
    return _challengeBox.getAll();
  }

  @override
  Future<void> saveChallenge(Challenge challenge) async {
    _challengeBox.put(challenge);
  }

  @override
  Future<void> clearChallenges() async {
    _challengeBox.removeAll();
  }

  @override
  Future<Streak> getStreak(int userId) async {
    final query = (_streakBox.query(Streak_.userId.equals(userId))).build();
    final results = query.find();
    query.close();

    if (results.isEmpty) {
      final newStreak = Streak(
        userId: userId,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: DateTime.fromMillisecondsSinceEpoch(0),
      );
      _streakBox.put(newStreak);
      return newStreak;
    }
    return results.first;
  }

  @override
  Future<void> saveStreak(Streak streak) async {
    _streakBox.put(streak);
  }

  @override
  Future<List<Goal>> getGoals(int userId) async {
    final query = (_goalBox.query(Goal_.userId.equals(userId))).build();
    final results = query.find();
    query.close();
    return results;
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    _goalBox.put(goal);
  }

  @override
  Future<void> deleteGoal(int id) async {
    _goalBox.remove(id);
  }

  @override
  Future<List<MotivationMessage>> getMotivationMessages() async {
    return _msgBox.getAll();
  }

  @override
  Future<void> addMotivationMessage(MotivationMessage msg) async {
    _msgBox.put(msg);
  }
}

/// Provider untuk instansiasi [GamificationRepository].
final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  final store = ref.watch(objectBoxStoreProvider);
  return GamificationRepositoryImpl(store);
});
