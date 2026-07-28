import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sync/data/repositories/sync_repository_impl.dart';
import '../data/repositories/gamification_repository_impl.dart';
import 'xp_engine.dart';
import 'level_engine.dart';
import 'mission_engine.dart';
import 'challenge_engine.dart';
import 'streak_engine.dart';
import 'motivation_engine.dart';
import 'goal_tracking_service.dart';

/// Provider untuk instansiasi [XPEngine].
final xpEngineProvider = Provider<XPEngine>((ref) {
  final repo = ref.watch(gamificationRepositoryProvider);
  return XPEngine(repo);
});

/// Provider untuk instansiasi [LevelEngine].
final levelEngineProvider = Provider<LevelEngine>((ref) {
  final repo = ref.watch(gamificationRepositoryProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  return LevelEngine(repo, syncRepo);
});

/// Provider untuk instansiasi [MissionEngine].
final missionEngineProvider = Provider<MissionEngine>((ref) {
  final repo = ref.watch(gamificationRepositoryProvider);
  final xp = ref.watch(xpEngineProvider);
  final lvl = ref.watch(levelEngineProvider);
  return MissionEngine(repo, xp, lvl);
});

/// Provider untuk instansiasi [ChallengeEngine].
final challengeEngineProvider = Provider<ChallengeEngine>((ref) {
  final repo = ref.watch(gamificationRepositoryProvider);
  final xp = ref.watch(xpEngineProvider);
  final lvl = ref.watch(levelEngineProvider);
  return ChallengeEngine(repo, xp, lvl);
});

/// Provider untuk instansiasi [StreakEngine].
final streakEngineProvider = Provider<StreakEngine>((ref) {
  final repo = ref.watch(gamificationRepositoryProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  return StreakEngine(repo, syncRepo);
});

/// Provider untuk instansiasi [MotivationEngine].
final motivationEngineProvider = Provider<MotivationEngine>((ref) {
  final repo = ref.watch(gamificationRepositoryProvider);
  return MotivationEngine(repo);
});

/// Provider untuk instansiasi [GoalTrackingService].
final goalTrackingServiceProvider = Provider<GoalTrackingService>((ref) {
  final repo = ref.watch(gamificationRepositoryProvider);
  return GoalTrackingService(repo);
});
