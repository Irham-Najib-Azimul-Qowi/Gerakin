import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/user/data/datasources/local_user_data_source.dart';
import 'package:gerakin/features/user/data/repositories/user_repository_impl.dart';
import 'package:gerakin/features/user/domain/repositories/user_repository.dart';
import 'package:gerakin/features/user/models/user_profile.dart';
import 'package:gerakin/features/user/models/user_preference.dart';
import 'package:gerakin/features/user/models/assessment_profile.dart';
import 'package:gerakin/features/user/models/wheelchair_profile.dart';
import 'package:gerakin/features/user/models/rehabilitation_goal.dart';
import 'package:gerakin/features/user/models/app_setting.dart';
import 'package:gerakin/features/user/services/guest_session_manager.dart';
import 'package:gerakin/features/user/services/multi_profile_manager.dart';
import 'package:gerakin/features/user/services/profile_validator.dart';

/// Mock in-memory implementation dari [LocalUserDataSource].
class MockLocalUserDataSource implements LocalUserDataSource {
  final Map<int, UserProfile> profiles = {};
  final Map<int, UserPreference> preferences = {};
  final Map<int, List<AssessmentProfile>> assessments = {};
  final Map<int, WheelchairProfile> wheelchairs = {};
  final Map<int, List<RehabilitationGoal>> goals = {};
  AppSetting? setting;
  int _idCounter = 1;

  @override
  Future<int> saveProfile(UserProfile profile) async {
    if (profile.id == 0) {
      profile.id = _idCounter++;
    }
    profiles[profile.id] = profile;
    return profile.id;
  }

  @override
  Future<UserProfile?> getActiveProfile() async {
    final list = profiles.values.where((p) => p.isActive).toList();
    return list.isEmpty ? null : list.first;
  }

  @override
  Future<UserProfile?> getProfileById(int id) async {
    return profiles[id];
  }

  @override
  Future<List<UserProfile>> getAllProfiles() async {
    return profiles.values.toList();
  }

  @override
  Future<void> deleteProfile(int id) async {
    profiles.remove(id);
  }

  @override
  Future<void> clearAllProfiles() async {
    profiles.clear();
  }

  @override
  Future<int> savePreference(UserPreference preference) async {
    if (preference.id == 0) {
      preference.id = _idCounter++;
    }
    preferences[preference.id] = preference;
    return preference.id;
  }

  @override
  Future<UserPreference?> getPreferenceByUserId(int userId) async {
    return preferences.values.firstWhere((p) => p.userId == userId, orElse: () => throw StateError('Not found'));
  }

  @override
  Future<int> saveAssessment(AssessmentProfile assessment) async {
    if (assessment.id == 0) {
      assessment.id = _idCounter++;
    }
    assessments.putIfAbsent(assessment.userId, () => []).add(assessment);
    return assessment.id;
  }

  @override
  Future<List<AssessmentProfile>> getAssessmentsByUserId(int userId) async {
    return assessments[userId] ?? [];
  }

  @override
  Future<int> saveWheelchairProfile(WheelchairProfile wheelchair) async {
    if (wheelchair.id == 0) {
      wheelchair.id = _idCounter++;
    }
    wheelchairs[wheelchair.userId] = wheelchair;
    return wheelchair.id;
  }

  @override
  Future<WheelchairProfile?> getWheelchairProfileByUserId(int userId) async {
    return wheelchairs[userId];
  }

  @override
  Future<int> saveGoal(RehabilitationGoal goal) async {
    if (goal.id == 0) {
      goal.id = _idCounter++;
    }
    goals.putIfAbsent(goal.userId, () => []).add(goal);
    return goal.id;
  }

  @override
  Future<List<RehabilitationGoal>> getGoalsByUserId(int userId) async {
    return goals[userId] ?? [];
  }

  @override
  Future<int> saveAppSetting(AppSetting s) async {
    if (s.id == 0) {
      s.id = 1;
    }
    setting = s;
    return s.id;
  }

  @override
  Future<AppSetting?> getAppSetting() async {
    return setting;
  }
}

void main() {
  group('User Module Unit Tests', () {
    late LocalUserDataSource mockDataSource;
    late UserRepository repository;

    setUp(() {
      mockDataSource = MockLocalUserDataSource();
      repository = UserRepositoryImpl(mockDataSource);
    });

    // ── 1. REPOSITORY & LOCAL STORAGE TESTS ─────────────────────────────
    test('Repository saves and retrieves profile and settings correctly', () async {
      final profile = UserProfile(
        displayName: 'Ahmad',
        gender: 'Laki-laki',
        birthDate: DateTime(1995, 5, 20),
        height: 175.0,
        weight: 70.0,
        wheelchairType: 'manual',
        mobilityLevel: 'intermediate',
        dominantHand: 'right',
        rehabilitationGoal: 'strength',
        medicalNotes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'local_only',
        isGuest: false,
        isActive: true,
      );

      final id = await repository.saveProfile(profile);
      expect(id, isPositive);

      final fetched = await repository.getProfileById(id);
      expect(fetched, isNotNull);
      expect(fetched!.displayName, equals('Ahmad'));

      // Test App Setting fallback & saving
      final setting = await repository.getAppSettings();
      expect(setting.isOfflineMode, isTrue);

      await repository.saveAppSettings(setting.copyWith(languageCode: 'en'));
      final updatedSetting = await repository.getAppSettings();
      expect(updatedSetting.languageCode, equals('en'));
    });

    // ── 2. GUEST SESSION TESTS ──────────────────────────────────────────
    test('GuestSessionManager starts and ends guest sessions properly', () async {
      final guestManager = GuestSessionManager(repository);

      // Start Guest
      final guest = await guestManager.startGuestSession();
      expect(guest.isGuest, isTrue);
      expect(guest.isActive, isTrue);
      expect(guest.displayName, contains('Tamu'));

      final active = await repository.getActiveProfile();
      expect(active!.id, equals(guest.id));

      // End Guest
      await guestManager.endGuestSession(guest.id);
      final all = await repository.getAllProfiles();
      expect(all.any((p) => p.id == guest.id), isFalse);
    });

    // ── 3. PROFILE VALIDATION TESTS ─────────────────────────────────────
    test('ProfileValidator validates fields correctly within strict ranges', () {
      expect(ProfileValidator.validateDisplayName(''), isFalse);
      expect(ProfileValidator.validateDisplayName('  '), isFalse);
      expect(ProfileValidator.validateDisplayName('Irham'), isTrue);

      expect(ProfileValidator.validateHeight(49.0), isFalse);
      expect(ProfileValidator.validateHeight(251.0), isFalse);
      expect(ProfileValidator.validateHeight(170.0), isTrue);

      expect(ProfileValidator.validateWeight(9.0), isFalse);
      expect(ProfileValidator.validateWeight(301.0), isFalse);
      expect(ProfileValidator.validateWeight(65.0), isTrue);

      expect(ProfileValidator.validateBirthDate(DateTime.now().add(const Duration(days: 1))), isFalse);
      expect(ProfileValidator.validateBirthDate(DateTime(1990, 1, 1)), isTrue);
    });

    // ── 4. MULTI PROFILE TESTS ──────────────────────────────────────────
    test('MultiProfileManager controls profile switching and isolation boundaries', () async {
      final manager = MultiProfileManager(repository);

      // Create Profile 1
      final p1 = await manager.createProfile(
        displayName: 'User Satu',
        gender: 'Laki-laki',
        birthDate: DateTime(1990, 1, 1),
        height: 170.0,
        weight: 60.0,
        wheelchairType: 'none',
        mobilityLevel: 'intermediate',
        dominantHand: 'right',
        rehabilitationGoal: 'fitness',
        medicalNotes: '',
      );

      // Create Profile 2
      final p2 = await manager.createProfile(
        displayName: 'User Dua',
        gender: 'Perempuan',
        birthDate: DateTime(1995, 1, 1),
        height: 160.0,
        weight: 55.0,
        wheelchairType: 'manual',
        mobilityLevel: 'beginner',
        dominantHand: 'left',
        rehabilitationGoal: 'rom',
        medicalNotes: '',
      );

      // Verifikasi profile aktif terpilih terakhir (p2)
      var active = await repository.getActiveProfile();
      expect(active!.id, equals(p2.id));

      // Beralih ke profile pertama (p1)
      await manager.switchProfile(p1.id);
      active = await repository.getActiveProfile();
      expect(active!.id, equals(p1.id));
      expect(active.displayName, equals('User Satu'));

      // Hapus profil p2 dan pastikan p1 tetap aktif
      await manager.deleteProfile(p2.id);
      final all = await manager.getAllProfiles();
      expect(all.length, equals(1));
      expect(all.first.id, equals(p1.id));
    });
  });
}
