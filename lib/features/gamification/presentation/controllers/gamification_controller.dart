import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../../data/repositories/gamification_repository_impl.dart';
import '../../models/user_level.dart';
import '../../models/streak.dart';
import '../../models/mission.dart';
import '../../models/challenge.dart';
import '../../models/goal.dart';
import '../../services/gamification_providers.dart';
import '../../../user/presentation/controllers/profile_controller.dart';
import '../../../analytics/domain/repositories/workout_history_repository.dart';
import '../../../analytics/data/repositories/workout_history_repository_impl.dart';
import '../../../analytics/models/achievement.dart';

/// State untuk manajemen UI gamifikasi.
class GamificationState {
  final UserLevel? level;
  final Streak? streak;
  final List<Mission> missions;
  final List<Challenge> challenges;
  final List<Goal> goals;
  final List<Achievement> achievements;
  final String motivationMessage;
  final bool isLoading;

  GamificationState({
    this.level,
    this.streak,
    required this.missions,
    required this.challenges,
    required this.goals,
    required this.achievements,
    required this.motivationMessage,
    required this.isLoading,
  });

  GamificationState copyWith({
    UserLevel? level,
    Streak? streak,
    List<Mission>? missions,
    List<Challenge>? challenges,
    List<Goal>? goals,
    List<Achievement>? achievements,
    String? motivationMessage,
    bool? isLoading,
  }) {
    return GamificationState(
      level: level ?? this.level,
      streak: streak ?? this.streak,
      missions: missions ?? this.missions,
      challenges: challenges ?? this.challenges,
      goals: goals ?? this.goals,
      achievements: achievements ?? this.achievements,
      motivationMessage: motivationMessage ?? this.motivationMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Controller (Notifier) untuk mengelola data visual gamifikasi.
class GamificationController extends Notifier<GamificationState> {
  late final GamificationRepository _repository;
  late final WorkoutHistoryRepository _workoutHistoryRepo;

  @override
  GamificationState build() {
    _repository = ref.watch(gamificationRepositoryProvider);
    _workoutHistoryRepo = ref.watch(workoutHistoryRepositoryProvider);

    ref.listen(profileControllerProvider, (prev, next) {
      if (next.activeProfile != null) {
        loadGamificationData(next.activeProfile!.id);
      }
    });

    final activeProfile = ref.read(profileControllerProvider).activeProfile;
    if (activeProfile != null) {
      Future.microtask(() => loadGamificationData(activeProfile.id));
    }

    return GamificationState(
      missions: const [],
      challenges: const [],
      goals: const [],
      achievements: const [],
      motivationMessage: 'Memuat motivasi...',
      isLoading: true,
    );
  }

  /// Memuat seluruh data gamifikasi pengguna dari ObjectBox.
  Future<void> loadGamificationData(int userId) async {
    try {
      state = state.copyWith(isLoading: true);

      // Inisialisasi misi & tantangan harian bawaan jika kosong
      await ref.read(missionEngineProvider).initializeDailyMissions();
      await ref.read(challengeEngineProvider).initializeWeeklyChallenges();

      final level = await _repository.getUserLevel(userId);
      final streak = await _repository.getStreak(userId);
      final missions = await _repository.getMissions();
      final challenges = await _repository.getChallenges();
      final goals = await _repository.getGoals(userId);

      // Integrasikan data pencapaian dari Analytics Engine
      final achievements = await _workoutHistoryRepo.getAllAchievements();
      final motivation = await ref.read(motivationEngineProvider).getRandomMessage('daily');

      state = GamificationState(
        level: level,
        streak: streak,
        missions: missions,
        challenges: challenges,
        goals: goals,
        achievements: achievements,
        motivationMessage: motivation,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Memicu aksi evaluasi gamifikasi ketika latihan baru diselesaikan.
  Future<void> triggerWorkoutCompleted(double accuracy, double consistency) async {
    final active = ref.read(profileControllerProvider).activeProfile;
    if (active == null) return;

    final userId = active.id;

    // 1. Berikan XP & update level
    final xpEarned = await ref.read(xpEngineProvider).awardXPForWorkout(
          userId: userId,
          accuracy: accuracy,
          consistency: consistency,
          completion: 1.0,
        );
    await ref.read(levelEngineProvider).addXP(userId, xpEarned);

    // 2. Perbarui streak aktif harian
    await ref.read(streakEngineProvider).recordActivity(userId);

    // 3. Perbarui misi & tantangan harian
    await ref
        .read(missionEngineProvider)
        .updateMissionProgress(userId, workoutCount: 1.0, accuracy: accuracy * 100);
    await ref.read(challengeEngineProvider).updateChallengeProgress(userId, workoutCount: 1.0);

    // 4. Perbarui sasaran (goal tracking)
    await ref.read(goalTrackingServiceProvider).updateGoalProgress(userId, 'workout_count', 1.0);

    await loadGamificationData(userId);
  }
}

/// Provider untuk instansiasi [GamificationController].
final gamificationControllerProvider = NotifierProvider<GamificationController, GamificationState>(
  GamificationController.new,
);
