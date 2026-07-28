import 'logger_service.dart';

/// Layanan pelacakan peristiwa analitik (Firebase Analytics wrapper) secara terstruktur.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final LoggerService _logger = LoggerService();

  /// Mencatat peristiwa khusus (custom event).
  Future<void> logEvent({required String name, Map<String, dynamic>? parameters}) async {
    final paramsStr = parameters != null ? parameters.toString() : '{}';
    _logger.info('Analytics Event: $name $paramsStr', category: 'ANALYTICS');
  }

  /// Mencatat penyelesaian sesi latihan.
  Future<void> logWorkoutCompleted({required String exerciseId, required double score}) async {
    await logEvent(
      name: 'workout_completed',
      parameters: {'exercise_id': exerciseId, 'score': score},
    );
  }

  /// Mencatat navigasi tampilan layar.
  Future<void> logScreenView({required String screenName}) async {
    await logEvent(
      name: 'screen_view',
      parameters: {'screen_name': screenName},
    );
  }
}
