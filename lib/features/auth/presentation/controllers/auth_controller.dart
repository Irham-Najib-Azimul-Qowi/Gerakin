import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../models/auth_user.dart';
import '../../services/auth_session_bridge.dart';
import '../../../../core/security/security_hardening.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// State untuk operasi autentikasi.
///
/// Mengikuti pola persis [ProfileState] di modul `user` —
/// `isLoading`, `errorMessage`, plus field spesifik auth.
class AuthState {
  /// Apakah sedang menunggu respons dari Firebase.
  final bool isLoading;

  /// Pesan error dalam Bahasa Indonesia, atau `null` jika tidak ada error.
  final String? errorMessage;

  /// Apakah operasi terakhir berhasil (sign in / sign up / reset).
  final bool isSuccess;

  /// Pengguna yang sedang aktif, atau `null` jika belum login.
  final AuthUser? currentUser;

  /// `true` jika profil baru dibuat dan perlu diarahkan ke Assessment Wizard.
  final bool requiresAssessment;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.currentUser,
    this.requiresAssessment = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    AuthUser? currentUser,
    bool? requiresAssessment,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      currentUser: currentUser ?? this.currentUser,
      requiresAssessment: requiresAssessment ?? this.requiresAssessment,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────

/// Controller autentikasi — membungkus [AuthRepository] dan [AuthSessionBridge]
/// untuk dipakai oleh halaman login, register, dan lupa password.
///
/// Mengikuti pola `Notifier<State>` dari Riverpod (bukan StateNotifier lama),
/// persis seperti [ProfileController] di modul `user`.
class AuthController extends Notifier<AuthState> {
  late final AuthRepository _authRepository;
  late final AuthSessionBridge _sessionBridge;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _sessionBridge = ref.watch(authSessionBridgeProvider);
    return const AuthState();
  }

  String _translateError(AuthException e) => e.message;

  // ── Public Methods ────────────────────────────────────────────────────────

  /// Mendaftarkan pengguna baru dengan email, password, dan nama tampilan.
  ///
  /// Setelah berhasil, memanggil [AuthSessionBridge.linkAuthToProfile] untuk
  /// menghubungkan akun Firebase ke [UserProfile] lokal.
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Sanitasi input sebelum dikirim ke Firebase (sesuai TRD §10)
    final cleanEmail = SecurityHardening.sanitizeInput(email.trim());
    final cleanName = SecurityHardening.sanitizeInput(displayName.trim());

    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      final authUser = await _authRepository.signUp(
        email: cleanEmail,
        password: password,
        displayName: cleanName,
      );

      final linkOutput = await _sessionBridge.linkAuthToProfile(authUser);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        currentUser: authUser,
        requiresAssessment:
            linkOutput.result == LinkAuthResult.newProfileCreated,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _translateError(e),
        isSuccess: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan. Silakan coba beberapa saat lagi.',
        isSuccess: false,
      );
    }
  }

  /// Login dengan email dan password.
  ///
  /// Setelah berhasil, memanggil [AuthSessionBridge.linkAuthToProfile].
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = SecurityHardening.sanitizeInput(email.trim());

    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      final authUser = await _authRepository.signIn(
        email: cleanEmail,
        password: password,
      );

      final linkOutput = await _sessionBridge.linkAuthToProfile(authUser);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        currentUser: authUser,
        requiresAssessment:
            linkOutput.result == LinkAuthResult.newProfileCreated,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _translateError(e),
        isSuccess: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan. Silakan coba beberapa saat lagi.',
        isSuccess: false,
      );
    }
  }

  /// Logout dari sesi Firebase saat ini.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authRepository.signOut();
      state = const AuthState(); // reset ke state awal
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _translateError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal logout. Silakan coba lagi.',
      );
    }
  }

  /// Mengirim email tautan reset password.
  Future<void> sendPasswordReset(String email) async {
    final cleanEmail = SecurityHardening.sanitizeInput(email.trim());

    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      await _authRepository.sendPasswordResetEmail(cleanEmail);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _translateError(e),
        isSuccess: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengirim email. Silakan coba lagi.',
        isSuccess: false,
      );
    }
  }

  /// Bersihkan pesan error (dipanggil saat user mulai mengetik ulang).
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider untuk instansiasi [AuthController].
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
