import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/app_session_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../models/auth_user.dart';
import '../../services/auth_session_bridge.dart';
import '../../../user/data/repositories/user_repository_impl.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../../user/models/user_profile.dart';
import '../../../user/services/guest_session_manager.dart';

/// Controller tersentralisasi yang mengelola [AppSessionState].
///
/// Merupakan **Single Source of Truth** untuk status sesi aplikasi:
/// `SessionInitializing` -> `SessionAuthenticated` / `SessionGuest` / `SessionSignedOut`.
class AppSessionNotifier extends Notifier<AppSessionState> {
  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  late final AuthSessionBridge _sessionBridge;
  StreamSubscription<AuthUser?>? _authSubscription;

  @override
  AppSessionState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _userRepository = ref.watch(userRepositoryProvider);
    _sessionBridge = ref.watch(authSessionBridgeProvider);

    // Batal langganan lama jika ada
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    // Inisialisasi resolve session secara async setelah build pertama
    Future.microtask(() => _initializeSessionResolution());

    return const SessionInitializing();
  }

  /// Resolusi prioritas sesi saat aplikasi pertama kali berjalan.
  ///
  /// **Algoritma Prioritas:**
  /// 1. Cek pengguna Firebase Auth (`currentUser`).
  /// 2. Jika ada user valid:
  ///    - State = [SessionAuthenticated].
  ///    - Nonaktifkan/abaikan flag guest lama.
  /// 3. Jika tidak ada Firebase user:
  ///    - Cek profil aktif di lokal (`UserRepository.getActiveProfile()`).
  ///    - Jika profil aktif adalah guest -> State = [SessionGuest].
  /// 4. Jika tidak ada -> State = [SessionSignedOut].
  Future<void> _initializeSessionResolution() async {
    try {
      final currentUser = _authRepository.currentUser;

      if (currentUser != null) {
        // Prioritas 1: Authenticated User
        final linkOutput = await _sessionBridge.linkAuthToProfile(currentUser);
        state = SessionAuthenticated(
          user: currentUser,
          profile: linkOutput.profile,
        );
      } else {
        // Prioritas 2: Cek Guest Session Persistence
        final activeProfile = await _userRepository.getActiveProfile();
        if (activeProfile != null && activeProfile.isGuest) {
          state = SessionGuest(activeProfile);
        } else {
          state = const SessionSignedOut();
        }
      }
    } catch (e) {
      // Jika terjadi error saat memuat, fallback aman ke SignedOut
      state = const SessionSignedOut();
    }

    // Dengarkan perubahan state auth dari Firebase
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges().listen((authUser) async {
      if (authUser != null) {
        // Hanya update jika belum dalam state authenticated yang sama
        if (state is! SessionAuthenticated || (state as SessionAuthenticated).user.uid != authUser.uid) {
          final linkOutput = await _sessionBridge.linkAuthToProfile(authUser);
          state = SessionAuthenticated(user: authUser, profile: linkOutput.profile);
        }
      } else {
        // Jika Firebase signOut dan sebelumnya Authenticated, ubah ke SignedOut
        if (state is SessionAuthenticated) {
          state = const SessionSignedOut();
        }
      }
    });
  }

  /// Memulai Mode Tamu (Guest Mode).
  ///
  /// Menjamin **Mutually Exclusive State**:
  /// Jika pengguna Firebase masih login, lakukan signOut dari Firebase terlebih dahulu.
  Future<void> startGuestSession() async {
    state = const SessionInitializing();
    try {
      final firebaseUser = _authRepository.currentUser;
      if (firebaseUser != null) {
        await _authRepository.signOut();
      }

      final guestManager = GuestSessionManager(_userRepository);
      final guestProfile = await guestManager.startGuestSession();
      state = SessionGuest(guestProfile);
    } catch (e) {
      state = const SessionSignedOut();
      rethrow;
    }
  }

  /// Memproses transisi setelah login atau registrasi akun berhasil.
  ///
  /// **Perilaku:**
  /// - Membersihkan sesi guest jika sebelumnya ada.
  /// - Menghubungkan identitas [authUser] ke [UserProfile].
  /// - Memperbarui state ke [SessionAuthenticated].
  Future<LinkAuthOutput> onLoginSuccess(AuthUser authUser) async {
    state = const SessionInitializing();
    try {
      // 1. Jika berasal dari Mode Tamu, bersihkan sesi tamu
      final activeProfile = await _userRepository.getActiveProfile();
      if (activeProfile != null && activeProfile.isGuest) {
        final guestManager = GuestSessionManager(_userRepository);
        await guestManager.endGuestSession(activeProfile.id);
      }

      // 2. Hubungkan ke profil pengguna
      final linkOutput = await _sessionBridge.linkAuthToProfile(authUser);

      // 3. Set state ke Authenticated
      state = SessionAuthenticated(
        user: authUser,
        profile: linkOutput.profile,
      );

      return linkOutput;
    } catch (e) {
      state = const SessionSignedOut();
      rethrow;
    }
  }

  /// Keluar dari sesi login (Logout Authenticated User).
  ///
  /// Resets state ke [SessionSignedOut]. Tidak otomatis masuk ke Mode Tamu.
  Future<void> signOut() async {
    state = const SessionInitializing();
    try {
      await _authRepository.signOut();
      final activeProfile = await _userRepository.getActiveProfile();
      if (activeProfile != null) {
        await _userRepository.saveProfile(
          activeProfile.copyWith(isActive: false, updatedAt: DateTime.now()),
        );
      }
      state = const SessionSignedOut();
    } catch (e) {
      state = const SessionSignedOut();
      rethrow;
    }
  }

  /// Keluar dari Mode Tamu (Exit Guest Mode).
  ///
  /// Menghapus profil tamu dari penyimpanan lokal dan reset ke [SessionSignedOut].
  Future<void> exitGuestMode() async {
    state = const SessionInitializing();
    try {
      final activeProfile = await _userRepository.getActiveProfile();
      if (activeProfile != null && activeProfile.isGuest) {
        final guestManager = GuestSessionManager(_userRepository);
        await guestManager.endGuestSession(activeProfile.id);
      }
      state = const SessionSignedOut();
    } catch (e) {
      state = const SessionSignedOut();
      rethrow;
    }
  }

  /// Memperbarui profil aktif di dalam state session tanpa mengubah mode.
  void updateActiveProfile(UserProfile updatedProfile) {
    if (state is SessionAuthenticated) {
      final current = state as SessionAuthenticated;
      state = SessionAuthenticated(user: current.user, profile: updatedProfile);
    } else if (state is SessionGuest) {
      state = SessionGuest(updatedProfile);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod Provider Tersentralisasi
// ─────────────────────────────────────────────────────────────────────────────

/// Single Source of Truth Provider untuk [AppSessionState].
final appSessionProvider = NotifierProvider<AppSessionNotifier, AppSessionState>(
  AppSessionNotifier.new,
);
