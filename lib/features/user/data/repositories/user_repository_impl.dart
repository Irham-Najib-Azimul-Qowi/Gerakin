import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local/objectbox_store.dart';
import '../datasources/local_user_data_source.dart';
import '../../domain/repositories/user_repository.dart';
import '../../models/user_profile.dart';
import '../../models/user_preference.dart';
import '../../models/assessment_profile.dart';
import '../../models/wheelchair_profile.dart';
import '../../models/rehabilitation_goal.dart';
import '../../models/app_setting.dart';

/// Implementasi [UserRepository] dengan mendelegasikan pemrosesan ke [LocalUserDataSource].
class UserRepositoryImpl implements UserRepository {
  final LocalUserDataSource _localDataSource;

  UserRepositoryImpl(this._localDataSource);

  @override
  Future<UserProfile?> getActiveProfile() async {
    return _localDataSource.getActiveProfile();
  }

  @override
  Future<int> saveProfile(UserProfile profile) async {
    return _localDataSource.saveProfile(profile);
  }

  @override
  Future<UserProfile?> getProfileById(int id) async {
    return _localDataSource.getProfileById(id);
  }

  @override
  Future<List<UserProfile>> getAllProfiles() async {
    return _localDataSource.getAllProfiles();
  }

  @override
  Future<void> deleteProfile(int id) async {
    await _localDataSource.deleteProfile(id);
  }

  @override
  Future<void> switchProfile(int id) async {
    final profiles = await _localDataSource.getAllProfiles();
    for (final p in profiles) {
      final updated = p.copyWith(isActive: p.id == id);
      await _localDataSource.saveProfile(updated);
    }
  }

  @override
  Future<UserPreference> getPreferences(int userId) async {
    final pref = await _localDataSource.getPreferenceByUserId(userId);
    if (pref != null) return pref;
    return UserPreference(
      userId: userId,
      themeMode: 'system',
      enableAudioCues: true,
      enableTts: false,
      dailyReminderTime: '08:00',
    );
  }

  @override
  Future<void> savePreferences(UserPreference preference) async {
    final savedId = await _localDataSource.savePreference(preference);
    preference.id = savedId;
  }

  @override
  Future<List<AssessmentProfile>> getAssessments(int userId) async {
    return _localDataSource.getAssessmentsByUserId(userId);
  }

  @override
  Future<void> saveAssessment(AssessmentProfile assessment) async {
    await _localDataSource.saveAssessment(assessment);
  }

  @override
  Future<WheelchairProfile?> getWheelchairProfile(int userId) async {
    return _localDataSource.getWheelchairProfileByUserId(userId);
  }

  @override
  Future<void> saveWheelchairProfile(WheelchairProfile wheelchair) async {
    await _localDataSource.saveWheelchairProfile(wheelchair);
  }

  @override
  Future<List<RehabilitationGoal>> getGoals(int userId) async {
    return _localDataSource.getGoalsByUserId(userId);
  }

  @override
  Future<void> saveGoal(RehabilitationGoal goal) async {
    await _localDataSource.saveGoal(goal);
  }

  @override
  Future<AppSetting> getAppSettings() async {
    final setting = await _localDataSource.getAppSetting();
    if (setting != null) return setting;
    return AppSetting(
      languageCode: 'id',
      isOfflineMode: true,
    );
  }

  @override
  Future<void> saveAppSettings(AppSetting setting) async {
    final savedId = await _localDataSource.saveAppSetting(setting);
    setting.id = savedId;
  }
}

/// Provider untuk instansiasi [LocalUserDataSource].
final localUserDataSourceProvider = Provider<LocalUserDataSource>((ref) {
  final store = ref.watch(objectBoxStoreProvider);
  return LocalUserDataSourceImpl(store);
});

/// Provider untuk instansiasi [UserRepository].
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final localDS = ref.watch(localUserDataSourceProvider);
  return UserRepositoryImpl(localDS);
});
