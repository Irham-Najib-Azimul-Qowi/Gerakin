import '../../models/xp_transaction.dart';
import '../../models/user_level.dart';
import '../../models/mission.dart';
import '../../models/challenge.dart';
import '../../models/streak.dart';
import '../../models/goal.dart';
import '../../models/motivation_message.dart';

/// Kontrak repositori untuk penyimpanan lokal gamifikasi.
abstract class GamificationRepository {
  // XP Transactions
  Future<void> addXPTransaction(XPTransaction tx);
  Future<List<XPTransaction>> getXPTransactions(int userId);

  // User Level
  Future<UserLevel> getUserLevel(int userId);
  Future<void> saveUserLevel(UserLevel level);

  // Missions
  Future<List<Mission>> getMissions();
  Future<void> saveMission(Mission mission);
  Future<void> clearMissions();

  // Challenges
  Future<List<Challenge>> getChallenges();
  Future<void> saveChallenge(Challenge challenge);
  Future<void> clearChallenges();

  // Streaks
  Future<Streak> getStreak(int userId);
  Future<void> saveStreak(Streak streak);

  // Goals
  Future<List<Goal>> getGoals(int userId);
  Future<void> saveGoal(Goal goal);
  Future<void> deleteGoal(int id);

  // Motivation Messages
  Future<List<MotivationMessage>> getMotivationMessages();
  Future<void> addMotivationMessage(MotivationMessage msg);
}
