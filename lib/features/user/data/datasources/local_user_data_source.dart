import '../../../../objectbox.g.dart';
import '../../models/user_profile.dart';
import '../../models/user_preference.dart';
import '../../models/assessment_profile.dart';
import '../../models/wheelchair_profile.dart';
import '../../models/rehabilitation_goal.dart';
import '../../models/app_setting.dart';

/// Antarmuka sumber data lokal untuk manajemen pengguna.
abstract class LocalUserDataSource {
  // Profiles
  Future<int> saveProfile(UserProfile profile);
  Future<UserProfile?> getActiveProfile();
  Future<UserProfile?> getProfileById(int id);
  Future<List<UserProfile>> getAllProfiles();
  Future<void> deleteProfile(int id);
  Future<void> clearAllProfiles();

  // Preferences
  Future<int> savePreference(UserPreference preference);
  Future<UserPreference?> getPreferenceByUserId(int userId);

  // Assessments
  Future<int> saveAssessment(AssessmentProfile assessment);
  Future<List<AssessmentProfile>> getAssessmentsByUserId(int userId);

  // Wheelchair
  Future<int> saveWheelchairProfile(WheelchairProfile wheelchair);
  Future<WheelchairProfile?> getWheelchairProfileByUserId(int userId);

  // Goals
  Future<int> saveGoal(RehabilitationGoal goal);
  Future<List<RehabilitationGoal>> getGoalsByUserId(int userId);

  // App Settings
  Future<int> saveAppSetting(AppSetting setting);
  Future<AppSetting?> getAppSetting();
}

/// Implementasi [LocalUserDataSource] menggunakan ObjectBox.
class LocalUserDataSourceImpl implements LocalUserDataSource {
  final Box<UserProfile> _profileBox;
  final Box<UserPreference> _preferenceBox;
  final Box<AssessmentProfile> _assessmentBox;
  final Box<WheelchairProfile> _wheelchairBox;
  final Box<RehabilitationGoal> _goalBox;
  final Box<AppSetting> _settingBox;

  LocalUserDataSourceImpl(Store store)
      : _profileBox = store.box<UserProfile>(),
        _preferenceBox = store.box<UserPreference>(),
        _assessmentBox = store.box<AssessmentProfile>(),
        _wheelchairBox = store.box<WheelchairProfile>(),
        _goalBox = store.box<RehabilitationGoal>(),
        _settingBox = store.box<AppSetting>();

  @override
  Future<int> saveProfile(UserProfile profile) async {
    return _profileBox.put(profile);
  }

  @override
  Future<UserProfile?> getActiveProfile() async {
    final query = _profileBox.query(UserProfile_.isActive.equals(true)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  @override
  Future<UserProfile?> getProfileById(int id) async {
    return _profileBox.get(id);
  }

  @override
  Future<List<UserProfile>> getAllProfiles() async {
    return _profileBox.getAll();
  }

  @override
  Future<void> deleteProfile(int id) async {
    _profileBox.remove(id);
  }

  @override
  Future<void> clearAllProfiles() async {
    _profileBox.removeAll();
  }

  @override
  Future<int> savePreference(UserPreference preference) async {
    return _preferenceBox.put(preference);
  }

  @override
  Future<UserPreference?> getPreferenceByUserId(int userId) async {
    final query = _preferenceBox.query(UserPreference_.userId.equals(userId)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  @override
  Future<int> saveAssessment(AssessmentProfile assessment) async {
    return _assessmentBox.put(assessment);
  }

  @override
  Future<List<AssessmentProfile>> getAssessmentsByUserId(int userId) async {
    final query = _assessmentBox.query(AssessmentProfile_.userId.equals(userId)).build();
    final result = query.find();
    query.close();
    return result;
  }

  @override
  Future<int> saveWheelchairProfile(WheelchairProfile wheelchair) async {
    return _wheelchairBox.put(wheelchair);
  }

  @override
  Future<WheelchairProfile?> getWheelchairProfileByUserId(int userId) async {
    final query = _wheelchairBox.query(WheelchairProfile_.userId.equals(userId)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  @override
  Future<int> saveGoal(RehabilitationGoal goal) async {
    return _goalBox.put(goal);
  }

  @override
  Future<List<RehabilitationGoal>> getGoalsByUserId(int userId) async {
    final query = _goalBox.query(RehabilitationGoal_.userId.equals(userId)).build();
    final result = query.find();
    query.close();
    return result;
  }

  @override
  Future<int> saveAppSetting(AppSetting setting) async {
    return _settingBox.put(setting);
  }

  @override
  Future<AppSetting?> getAppSetting() async {
    final list = _settingBox.getAll();
    return list.isEmpty ? null : list.first;
  }
}
