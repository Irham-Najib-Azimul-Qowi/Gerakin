import '../../models/workout_session.dart';
import '../../models/recovery_progress.dart';
import '../../models/achievement.dart';

/// State untuk halaman Dashboard Analitik & Perkembangan Pengguna.
class AnalyticsDashboardState {
  final List<WorkoutSession> sessions;
  final List<RecoveryProgress> recoveryRecords;
  final List<Achievement> achievements;
  final bool isLoading;
  final String? errorMessage;

  AnalyticsDashboardState({
    required this.sessions,
    required this.recoveryRecords,
    required this.achievements,
    required this.isLoading,
    this.errorMessage,
  });

  AnalyticsDashboardState copyWith({
    List<WorkoutSession>? sessions,
    List<RecoveryProgress>? recoveryRecords,
    List<Achievement>? achievements,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AnalyticsDashboardState(
      sessions: sessions ?? this.sessions,
      recoveryRecords: recoveryRecords ?? this.recoveryRecords,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
