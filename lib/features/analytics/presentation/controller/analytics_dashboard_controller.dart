import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/workout_history_repository_impl.dart';
import '../../domain/repositories/workout_history_repository.dart';
import '../../models/workout_session.dart';
import '../../models/recovery_progress.dart';
import '../../services/analytics_engine.dart';
import 'analytics_dashboard_state.dart';

/// Controller (Notifier) untuk mengelola data di Dashboard Analitik.
class AnalyticsDashboardController extends Notifier<AnalyticsDashboardState> {
  late final WorkoutHistoryRepository _repository;
  final AnalyticsEngine _analyticsEngine = AnalyticsEngine();

  @override
  AnalyticsDashboardState build() {
    _repository = ref.watch(workoutHistoryRepositoryProvider);
    
    // Inisialisasi secara asynchronous setelah frame pertama selesai
    Future.microtask(() => _init());

    return AnalyticsDashboardState(
      sessions: const [],
      recoveryRecords: const [],
      achievements: const [],
      isLoading: true,
    );
  }

  Future<void> _init() async {
    try {
      state = state.copyWith(isLoading: true);

      // Pastikan default achievements terinisialisasi
      final defaultAchievements = _analyticsEngine.evaluateAchievements(
        sessions: const [],
        currentAchievements: const [],
      );
      await _repository.initDefaultAchievements(defaultAchievements);

      // Ambil data dari repositori lokal
      final sessions = await _repository.getAllWorkoutSessions();
      final recovery = await _repository.getAllRecoveryProgress();
      final savedAchievements = await _repository.getAllAchievements();

      // Evaluasi kelayakan pencapaian baru secara dinamis
      final updatedAchievements = _analyticsEngine.evaluateAchievements(
        sessions: sessions,
        currentAchievements: savedAchievements,
      );

      // Simpan pembaruan status pencapaian ke local db
      for (final a in updatedAchievements) {
        final prev = savedAchievements.firstWhere(
          (element) => element.achievementId == a.achievementId,
          orElse: () => a,
        );
        if (prev.isUnlocked != a.isUnlocked || prev.progress != a.progress) {
          await _repository.saveAchievement(a);
        }
      }

      state = state.copyWith(
        sessions: sessions,
        recoveryRecords: recovery,
        achievements: updatedAchievements,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat data perkembangan: $e',
      );
    }
  }

  /// Menambah sesi latihan baru.
  Future<void> addWorkoutSession(WorkoutSession session) async {
    await _repository.saveWorkoutSession(session);
    await _init();
  }

  /// Menambah catatan pemulihan fisik baru.
  Future<void> addRecoveryProgress(RecoveryProgress progress) async {
    await _repository.saveRecoveryProgress(progress);
    await _init();
  }

  /// Memperbarui dashboard secara manual.
  Future<void> refresh() async {
    await _init();
  }
}

/// Provider Riverpod untuk instansiasi [AnalyticsDashboardController].
final analyticsDashboardControllerProvider =
    NotifierProvider<AnalyticsDashboardController, AnalyticsDashboardState>(
  AnalyticsDashboardController.new,
);
