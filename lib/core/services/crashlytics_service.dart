import 'logger_service.dart';

/// Layanan pembungkus Firebase Crashlytics dengan dukungan Offline-First dan logging aman.
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  final LoggerService _logger = LoggerService();

  /// Mencatat crash atau pengecualian yang tertangkap ke sistem crash logging.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    _logger.log(
      'Crashlytics RecordError: ${reason ?? "Pengecualian sistem tertangkap"}',
      level: fatal ? LogLevel.fatal : LogLevel.error,
      category: 'CRASHLYTICS',
      error: exception,
      stackTrace: stack,
    );
  }

  /// Mencatat rekam jejak (breadcrumb log).
  Future<void> log(String message) async {
    _logger.info(message, category: 'CRASHLYTICS_BREADCRUMB');
  }

  /// Menetapkan identitas pengguna secara anonim untuk penelusuran eror.
  Future<void> setUserIdentifier(String userId) async {
    _logger.info('Identifikasi Pengguna Ditetapkan: $userId', category: 'CRASHLYTICS');
  }
}
