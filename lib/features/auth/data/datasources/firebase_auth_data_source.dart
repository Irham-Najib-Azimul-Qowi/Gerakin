import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/auth_exception.dart';
import '../../models/auth_user.dart';

/// Kontrak abstrak data source untuk Firebase Authentication.
///
/// Satu-satunya abstraksi yang boleh berinteraksi dengan Firebase Auth SDK.
abstract class FirebaseAuthDataSource {
  /// Stream status autentikasi Firebase.
  Stream<AuthUser?> authStateChanges();

  /// Pengguna Firebase yang sedang aktif, dipetakan ke [AuthUser].
  AuthUser? get currentUser;

  /// Registrasi dengan email dan password.
  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Login dengan email dan password.
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Logout dari sesi Firebase saat ini.
  Future<void> signOut();

  /// Kirim email reset password.
  Future<void> sendPasswordResetEmail(String email);
}

/// Implementasi konkret [FirebaseAuthDataSource] menggunakan Firebase Auth SDK.
///
/// Berinteraksi langsung dengan Firebase Authentication Cloud secara sungguhan.
/// Setiap [fb.FirebaseAuthException] ditangkap dan di-translate ke [AuthException]
/// dengan pesan Bahasa Indonesia yang ramah pengguna.
class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final fb.FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSourceImpl([fb.FirebaseAuth? firebaseAuth])
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  /// Mapping dari [fb.User] Firebase → [AuthUser] milik modul ini.
  AuthUser? _mapFirebaseUser(fb.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      emailVerified: user.emailVerified,
    );
  }

  /// Translate [fb.FirebaseAuthException] → [AuthException] dengan
  /// pesan Bahasa Indonesia yang siap ditampilkan ke pengguna.
  AuthException _translateError(fb.FirebaseAuthException e) {
    final message = switch (e.code) {
      'user-not-found' => 'Akun tidak ditemukan. Periksa kembali email Anda.',
      'wrong-password' || 'invalid-credential' =>
        'Email atau password salah. Silakan coba lagi.',
      'email-already-in-use' =>
        'Email sudah terdaftar. Silakan login atau gunakan email lain.',
      'weak-password' => 'Password terlalu lemah. Gunakan minimal 6 karakter.',
      'invalid-email' => 'Format email tidak valid.',
      'network-request-failed' =>
        'Tidak ada koneksi internet. Periksa jaringan Anda.',
      'too-many-requests' =>
        'Terlalu banyak percobaan. Coba lagi beberapa menit.',
      'user-disabled' => 'Akun ini telah dinonaktifkan. Hubungi dukungan.',
      'operation-not-allowed' =>
        'Metode login ini belum diaktifkan di Firebase Console. Aktifkan Email/Password sign-in method di console.',
      _ => 'Terjadi kesalahan autentikasi: ${e.message ?? e.code}',
    };
    return AuthException(code: e.code, message: message);
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  AuthUser? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  @override
  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();

      final updatedUser = _firebaseAuth.currentUser;
      return AuthUser(
        uid: updatedUser?.uid ?? credential.user!.uid,
        email: updatedUser?.email ?? email,
        displayName: updatedUser?.displayName ?? displayName,
        emailVerified: updatedUser?.emailVerified ?? false,
      );
    } on AuthException {
      rethrow;
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Gagal membuat akun di Firebase: $e',
      );
    }
  }

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          code: 'unknown',
          message: 'Login berhasil tapi data pengguna tidak tersedia.',
        );
      }

      return AuthUser(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        emailVerified: user.emailVerified,
      );
    } on AuthException {
      rethrow;
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Gagal login ke Firebase: $e',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on AuthException {
      rethrow;
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Gagal logout: $e',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on AuthException {
      rethrow;
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Gagal mengirim email reset: $e',
      );
    }
  }
}
