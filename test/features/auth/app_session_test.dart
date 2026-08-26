import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/auth/domain/app_session_state.dart';
import 'package:gerakin/features/auth/domain/session_access_policy.dart';
import 'package:gerakin/features/auth/models/auth_user.dart';
import 'package:gerakin/features/user/models/user_profile.dart';

void main() {
  group('AppSessionState & Mutually Exclusive State Tests', () {
    final now = DateTime.now();

    final testGuestProfile = UserProfile(
      id: 1,
      displayName: 'Tamu (Guest)',
      gender: 'Lainnya',
      birthDate: DateTime(2000, 1, 1),
      height: 170.0,
      weight: 60.0,
      wheelchairType: 'none',
      mobilityLevel: 'intermediate',
      dominantHand: 'right',
      rehabilitationGoal: 'Pelihara Kebugaran',
      medicalNotes: '',
      createdAt: now,
      updatedAt: now,
      syncStatus: 'local_only',
      isGuest: true,
      isActive: true,
    );

    final testAuthProfile = UserProfile(
      id: 2,
      displayName: 'User Terdaftar',
      email: 'user@gerakin.id',
      gender: 'Pria',
      birthDate: DateTime(1995, 5, 15),
      height: 175.0,
      weight: 68.0,
      wheelchairType: 'manual',
      mobilityLevel: 'advanced',
      dominantHand: 'right',
      rehabilitationGoal: 'Penguatan Bahu',
      medicalNotes: '',
      createdAt: now,
      updatedAt: now,
      syncStatus: 'synced',
      isGuest: false,
      isActive: true,
    );

    final testAuthUser = const AuthUser(
      uid: 'firebase_uid_123',
      email: 'user@gerakin.id',
      displayName: 'User Terdaftar',
      emailVerified: true,
    );

    test('State Initializing dan SignedOut merepresentasikan state non-user', () {
      const init = SessionInitializing();
      const signedOut = SessionSignedOut();

      expect(init, isA<AppSessionState>());
      expect(signedOut, isA<AppSessionState>());
      expect(init, equals(const SessionInitializing()));
      expect(signedOut, equals(const SessionSignedOut()));
    });

    test('SessionGuest memegang profil tamu yang valid', () {
      final guestSession = SessionGuest(testGuestProfile);

      expect(guestSession.profile.isGuest, isTrue);
      expect(guestSession.profile.displayName, contains('Guest'));
      expect(guestSession, isA<SessionGuest>());
      expect(guestSession, isNot(isA<SessionAuthenticated>()));
    });

    test('SessionAuthenticated memegang AuthUser dan UserProfile non-guest', () {
      final authSession = SessionAuthenticated(
        user: testAuthUser,
        profile: testAuthProfile,
      );

      expect(authSession.user.uid, equals('firebase_uid_123'));
      expect(authSession.profile.isGuest, isFalse);
      expect(authSession, isA<SessionAuthenticated>());
      expect(authSession, isNot(isA<SessionGuest>()));
    });
  });

  group('SessionAccessPolicy Tests (Guest vs Authenticated Permission Matrix)', () {
    final now = DateTime.now();

    final guestProfile = UserProfile(
      id: 1,
      displayName: 'Guest User',
      gender: 'Lainnya',
      birthDate: DateTime(2000, 1, 1),
      height: 170,
      weight: 60,
      wheelchairType: 'none',
      mobilityLevel: 'intermediate',
      dominantHand: 'right',
      rehabilitationGoal: 'Pelihara Kebugaran',
      medicalNotes: '',
      createdAt: now,
      updatedAt: now,
      syncStatus: 'local_only',
      isGuest: true,
      isActive: true,
    );

    final authProfile = UserProfile(
      id: 2,
      displayName: 'Auth User',
      email: 'auth@gerakin.id',
      gender: 'Pria',
      birthDate: DateTime(1998, 1, 1),
      height: 170,
      weight: 60,
      wheelchairType: 'manual',
      mobilityLevel: 'intermediate',
      dominantHand: 'right',
      rehabilitationGoal: 'Pelihara Kebugaran',
      medicalNotes: '',
      createdAt: now,
      updatedAt: now,
      syncStatus: 'synced',
      isGuest: false,
      isActive: true,
    );

    final authUser = const AuthUser(
      uid: 'uid_999',
      email: 'auth@gerakin.id',
      emailVerified: true,
    );

    final guestSession = SessionGuest(guestProfile);
    final authSession = SessionAuthenticated(user: authUser, profile: authProfile);

    test('Guest DIPERBOLEHKAN mengakses Core Exercise & Viewing Features', () {
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.home), isTrue);
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.exerciseMenu), isTrue);
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.exerciseEducation), isTrue);
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.exerciseCameraSession), isTrue);
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.sessionResult), isTrue);
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.communityRead), isTrue);
    });

    test('Guest DIBATASI mengakses Cloud & Identity-bound Features', () {
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.communityPost), isFalse);
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.communityComment), isFalse);
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.communityLike), isFalse);
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.profileEdit), isFalse);
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.cloudSync), isFalse);
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.accountSettings), isFalse);
      expect(SessionAccessPolicy.canAccess(guestSession, AppFeature.streakAndBadges), isFalse);
    });

    test('Authenticated User DIPERBOLEHKAN mengakses seluruh fitur', () {
      for (final feature in AppFeature.values) {
        expect(SessionAccessPolicy.canAccess(authSession, feature), isTrue);
      }
    });

    test('getLockedReason mengembalikan instruksi yang jelas dan kontekstual', () {
      final reason = SessionAccessPolicy.getLockedReason(AppFeature.communityPost);
      expect(reason, contains('Masuk dengan akun terdaftar'));
    });
  });
}
