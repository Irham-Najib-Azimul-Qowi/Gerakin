import '../domain/repositories/user_repository.dart';
import '../models/user_preference.dart';
import '../models/app_setting.dart';

/// Layanan untuk mengelola preferensi pengguna dan pengaturan umum aplikasi.
class UserPreferenceService {
  final UserRepository _repository;

  UserPreferenceService(this._repository);

  /// Mengambil preferensi pengguna untuk ID profil tertentu.
  Future<UserPreference> getPreferences(int userId) async {
    return _repository.getPreferences(userId);
  }

  /// Menyimpan preferensi pengguna.
  Future<void> savePreferences(UserPreference preference) async {
    await _repository.savePreferences(preference);
  }

  /// Mengambil konfigurasi pengaturan umum aplikasi.
  Future<AppSetting> getAppSettings() async {
    return _repository.getAppSettings();
  }

  /// Menyimpan konfigurasi pengaturan umum aplikasi.
  Future<void> saveAppSettings(AppSetting setting) async {
    await _repository.saveAppSettings(setting);
  }
}
