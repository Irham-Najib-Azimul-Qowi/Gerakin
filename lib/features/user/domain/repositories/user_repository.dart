import '../../models/user_profile.dart';
import '../../models/user_preference.dart';
import '../../models/assessment_profile.dart';
import '../../models/wheelchair_profile.dart';
import '../../models/rehabilitation_goal.dart';
import '../../models/app_setting.dart';

/// Kontrak repositori utama untuk manajemen data pengguna secara offline-first.
abstract class UserRepository {
  // ── Profiles ─────────────────────────────────────────
  Future<UserProfile?> getActiveProfile();
  Future<int> saveProfile(UserProfile profile);
  Future<UserProfile?> getProfileById(int id);
  Future<List<UserProfile>> getAllProfiles();
  Future<void> deleteProfile(int id);
  Future<void> switchProfile(int id);

  // ── Preferences ──────────────────────────────────────
  Future<UserPreference> getPreferences(int userId);
  Future<void> savePreferences(UserPreference preference);

  // ── Assessments ──────────────────────────────────────
  Future<List<AssessmentProfile>> getAssessments(int userId);
  Future<void> saveAssessment(AssessmentProfile assessment);

  // ── Wheelchair Profiles ──────────────────────────────
  Future<WheelchairProfile?> getWheelchairProfile(int userId);
  Future<void> saveWheelchairProfile(WheelchairProfile wheelchair);

  // ── Rehabilitation Goals ─────────────────────────────
  Future<List<RehabilitationGoal>> getGoals(int userId);
  Future<void> saveGoal(RehabilitationGoal goal);

  // ── App Settings ─────────────────────────────────────
  Future<AppSetting> getAppSettings();
  Future<void> saveAppSettings(AppSetting setting);
}
