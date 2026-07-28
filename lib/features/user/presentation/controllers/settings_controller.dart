import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../models/user_preference.dart';
import '../../models/app_setting.dart';
import '../../services/user_preference_service.dart';
import 'profile_controller.dart';

/// State untuk pengaturan aplikasi.
class SettingsState {
  final UserPreference? preferences;
  final AppSetting? appSetting;
  final bool isLoading;
  final String? errorMessage;

  SettingsState({
    this.preferences,
    this.appSetting,
    required this.isLoading,
    this.errorMessage,
  });

  SettingsState copyWith({
    UserPreference? preferences,
    AppSetting? appSetting,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      preferences: preferences ?? this.preferences,
      appSetting: appSetting ?? this.appSetting,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller (Notifier) untuk mengelola preferensi & pengaturan.
class SettingsController extends Notifier<SettingsState> {
  late final UserRepository _repository;
  late final UserPreferenceService _prefService;

  @override
  SettingsState build() {
    _repository = ref.watch(userRepositoryProvider);
    _prefService = UserPreferenceService(_repository);

    // Sinkronkan preferensi jika profil aktif berubah
    ref.listen(profileControllerProvider, (prev, next) {
      if (next.activeProfile != null) {
        loadSettings(next.activeProfile!.id);
      }
    });

    final activeProfile = ref.read(profileControllerProvider).activeProfile;
    if (activeProfile != null) {
      Future.microtask(() => loadSettings(activeProfile.id));
    }

    return SettingsState(isLoading: true);
  }

  /// Memuat pengaturan dari database lokal.
  Future<void> loadSettings(int userId) async {
    try {
      state = state.copyWith(isLoading: true);
      final pref = await _prefService.getPreferences(userId);
      final app = await _prefService.getAppSettings();

      state = SettingsState(
        preferences: pref,
        appSetting: app,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat pengaturan: $e',
      );
    }
  }

  /// Memperbarui preferensi pengguna aktif.
  Future<void> updatePreferences(UserPreference updated) async {
    try {
      state = state.copyWith(isLoading: true);
      await _prefService.savePreferences(updated);
      state = state.copyWith(preferences: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Memperbarui pengaturan aplikasi umum.
  Future<void> updateAppSettings(AppSetting updated) async {
    try {
      state = state.copyWith(isLoading: true);
      await _prefService.saveAppSettings(updated);
      state = state.copyWith(appSetting: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

/// Provider untuk instansiasi [SettingsController].
final settingsControllerProvider = NotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);
