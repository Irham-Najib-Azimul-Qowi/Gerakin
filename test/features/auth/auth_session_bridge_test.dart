import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/auth/models/auth_user.dart';
import 'package:gerakin/features/auth/services/auth_session_bridge.dart';
import 'package:gerakin/features/user/domain/repositories/user_repository.dart';
import 'package:gerakin/features/user/models/app_setting.dart';
import 'package:gerakin/features/user/models/assessment_profile.dart';
import 'package:gerakin/features/user/models/rehabilitation_goal.dart';
import 'package:gerakin/features/user/models/user_preference.dart';
import 'package:gerakin/features/user/models/user_profile.dart';
import 'package:gerakin/features/user/models/wheelchair_profile.dart';
import 'package:gerakin/features/user/services/guest_session_manager.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock UserRepository — in-memory tanpa ketergantungan ObjectBox native
// Mengikuti pola yang sama dengan user_management_test.dart
// ─────────────────────────────────────────────────────────────────────────────
class MockUserRepository implements UserRepository {
  final Map<int, UserProfile> _profiles = {};
  int _idCounter = 1;

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Reset state untuk setUp() setiap test
  void reset() {
    _profiles.clear();
    _idCounter = 1;
  }

  // ── Profiles ─────────────────────────────────────────────────────────────

  @override
  Future<int> saveProfile(UserProfile profile) async {
    if (profile.id == 0) {
      profile.id = _idCounter++;
    }
    _profiles[profile.id] = profile;
    return profile.id;
  }

  @override
  Future<UserProfile?> getActiveProfile() async {
    final list = _profiles.values.where((p) => p.isActive).toList();
    return list.isEmpty ? null : list.first;
  }

  @override
  Future<UserProfile?> getProfileById(int id) async => _profiles[id];

  @override
  Future<List<UserProfile>> getAllProfiles() async =>
      _profiles.values.toList();

  @override
  Future<void> deleteProfile(int id) async => _profiles.remove(id);

  @override
  Future<void> switchProfile(int id) async {
    for (final p in _profiles.values.toList()) {
      _profiles[p.id] = p.copyWith(isActive: p.id == id);
    }
  }

  // ── Metode lain (tidak dipakai di test ini, return default kosong) ────────

  @override
  Future<UserPreference> getPreferences(int userId) async =>
      UserPreference(userId: userId, themeMode: 'system', enableAudioCues: true, enableTts: false, dailyReminderTime: '08:00');

  @override
  Future<void> savePreferences(UserPreference preference) async {}

  @override
  Future<List<AssessmentProfile>> getAssessments(int userId) async => [];

  @override
  Future<void> saveAssessment(AssessmentProfile assessment) async {}

  @override
  Future<WheelchairProfile?> getWheelchairProfile(int userId) async => null;

  @override
  Future<void> saveWheelchairProfile(WheelchairProfile wheelchair) async {}

  @override
  Future<List<RehabilitationGoal>> getGoals(int userId) async => [];

  @override
  Future<void> saveGoal(RehabilitationGoal goal) async {}

  @override
  Future<AppSetting> getAppSettings() async =>
      AppSetting(languageCode: 'id', isOfflineMode: true);

  @override
  Future<void> saveAppSettings(AppSetting setting) async {}
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: buat UserProfile guest dengan data fisik lengkap
// ─────────────────────────────────────────────────────────────────────────────
UserProfile _makeGuestProfile({bool isActive = true}) {
  return UserProfile(
    displayName: 'Tamu (Guest)',
    gender: 'Lainnya',
    birthDate: DateTime(2000, 1, 1),
    height: 170.0,
    weight: 60.0,
    wheelchairType: 'manual',       // ← data fisik yang harus tetap ada setelah migrasi
    mobilityLevel: 'beginner',      // ← data fisik yang harus tetap ada setelah migrasi
    dominantHand: 'left',           // ← data fisik yang harus tetap ada setelah migrasi
    rehabilitationGoal: 'ROM',
    medicalNotes: 'Sesi Guest Mode.',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
    syncStatus: 'local_only',
    isGuest: true,
    isActive: isActive,
  );
}

AuthUser _makeAuthUser({String email = 'irham@gerakin.id', String? displayName}) {
  return AuthUser(
    uid: 'firebase-uid-abc123',
    email: email,
    displayName: displayName,
    emailVerified: false,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Test Suite
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  group('AuthSessionBridge — linkAuthToProfile()', () {
    late MockUserRepository mockRepo;
    late AuthSessionBridge bridge;

    setUp(() {
      mockRepo = MockUserRepository();
      bridge = AuthSessionBridge(mockRepo, GuestSessionManager(mockRepo));
    });

    // ── Skenario 1: Guest Aktif → Harus Migrasi ───────────────────────────
    group('Skenario 1: Ada profil Guest aktif', () {
      test('harus mempertahankan semua data fisik setelah migrasi', () async {
        // Arrange: simpan guest profile dengan data fisik lengkap
        final guest = _makeGuestProfile();
        await mockRepo.saveProfile(guest);

        final authUser = _makeAuthUser(displayName: 'Irham Najib');

        // Act
        final output = await bridge.linkAuthToProfile(authUser);

        // Assert — result type
        expect(output.result, equals(LinkAuthResult.guestMigrated));

        // Assert — data identitas diperbarui
        expect(output.profile.email, equals('irham@gerakin.id'));
        expect(output.profile.displayName, equals('Irham Najib'));
        expect(output.profile.isGuest, isFalse);
        expect(output.profile.syncStatus, equals('pending_sync'));

        // Assert — data fisik TIDAK hilang
        expect(output.profile.wheelchairType, equals('manual'));
        expect(output.profile.mobilityLevel, equals('beginner'));
        expect(output.profile.dominantHand, equals('left'));
        expect(output.profile.rehabilitationGoal, equals('ROM'));
      });

      test('harus mempertahankan displayName guest jika authUser tidak punya displayName', () async {
        // Arrange: guest punya nama, authUser tidak punya displayName
        final guest = _makeGuestProfile();
        await mockRepo.saveProfile(guest);

        final authUser = _makeAuthUser(displayName: null);

        // Act
        final output = await bridge.linkAuthToProfile(authUser);

        // Assert — displayName tidak berubah ke null
        expect(output.profile.displayName, equals('Tamu (Guest)'));
        expect(output.result, equals(LinkAuthResult.guestMigrated));
      });

      test('harus tersimpan di repository setelah migrasi', () async {
        // Arrange
        final guest = _makeGuestProfile();
        await mockRepo.saveProfile(guest);
        final authUser = _makeAuthUser();

        // Act
        await bridge.linkAuthToProfile(authUser);

        // Assert — profil di repository sudah terupdate
        final saved = await mockRepo.getActiveProfile();
        expect(saved, isNotNull);
        expect(saved!.isGuest, isFalse);
        expect(saved.email, equals('irham@gerakin.id'));
      });
    });

    // ── Skenario 2: Email Cocok → Aktifkan Profil ─────────────────────────
    group('Skenario 2: Tidak ada guest, ada email yang cocok', () {
      test('harus mengaktifkan profil yang emailnya cocok', () async {
        // Arrange: simpan profil registered (bukan guest) dengan email yang sama
        final existing = UserProfile(
          displayName: 'Irham Najib',
          email: 'irham@gerakin.id',
          gender: 'Laki-laki',
          birthDate: DateTime(1999, 6, 15),
          height: 175.0,
          weight: 68.0,
          wheelchairType: 'power',
          mobilityLevel: 'advanced',
          dominantHand: 'right',
          rehabilitationGoal: 'strength',
          medicalNotes: '',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          syncStatus: 'local_only',
          isGuest: false,
          isActive: false, // ← tidak aktif saat ini
        );
        await mockRepo.saveProfile(existing);

        final authUser = _makeAuthUser(email: 'irham@gerakin.id');

        // Act
        final output = await bridge.linkAuthToProfile(authUser);

        // Assert
        expect(output.result, equals(LinkAuthResult.existingProfileActivated));
        expect(output.profile.displayName, equals('Irham Najib'));
        expect(output.profile.email, equals('irham@gerakin.id'));
      });

      test('harus case-insensitive saat mencocokkan email', () async {
        // Arrange: email tersimpan dengan huruf kapital
        final existing = UserProfile(
          displayName: 'Siti',
          email: 'SITI@gerakin.id',
          gender: 'Perempuan',
          birthDate: DateTime(2000, 1, 1),
          height: 155.0,
          weight: 50.0,
          wheelchairType: 'none',
          mobilityLevel: 'intermediate',
          dominantHand: 'right',
          rehabilitationGoal: 'flexibility',
          medicalNotes: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'synced',
          isGuest: false,
          isActive: false,
        );
        await mockRepo.saveProfile(existing);

        // authUser punya email lowercase
        final authUser = _makeAuthUser(email: 'siti@gerakin.id');

        // Act
        final output = await bridge.linkAuthToProfile(authUser);

        // Assert — cocok meski beda kapital
        expect(output.result, equals(LinkAuthResult.existingProfileActivated));
        expect(output.profile.displayName, equals('Siti'));
      });
    });

    // ── Skenario 3: Tidak Ada Profil → Buat Baru ──────────────────────────
    group('Skenario 3: Tidak ada profil sama sekali', () {
      test('harus membuat profil baru minimal dan return newProfileCreated', () async {
        // Arrange: repository kosong
        final authUser = _makeAuthUser(
          email: 'baru@gerakin.id',
          displayName: 'Pengguna Baru',
        );

        // Act
        final output = await bridge.linkAuthToProfile(authUser);

        // Assert — result type
        expect(output.result, equals(LinkAuthResult.newProfileCreated));

        // Assert — data dasar benar
        expect(output.profile.email, equals('baru@gerakin.id'));
        expect(output.profile.displayName, equals('Pengguna Baru'));
        expect(output.profile.isGuest, isFalse);
        expect(output.profile.isActive, isTrue);
        expect(output.profile.syncStatus, equals('pending_sync'));

        // Assert — profil tersimpan di repository
        final saved = await mockRepo.getActiveProfile();
        expect(saved, isNotNull);
        expect(saved!.email, equals('baru@gerakin.id'));
      });

      test('harus menggunakan bagian email sebagai displayName jika displayName null', () async {
        // Arrange
        final authUser = _makeAuthUser(
          email: 'johndoe@gerakin.id',
          displayName: null,
        );

        // Act
        final output = await bridge.linkAuthToProfile(authUser);

        // Assert — ambil bagian sebelum '@'
        expect(output.profile.displayName, equals('johndoe'));
      });

      test('profil baru harus diberi ID yang valid (bukan 0)', () async {
        // Arrange
        final authUser = _makeAuthUser();

        // Act
        final output = await bridge.linkAuthToProfile(authUser);

        // Assert — ID sudah di-assign oleh repository
        expect(output.profile.id, isPositive);
      });
    });
  });
}
