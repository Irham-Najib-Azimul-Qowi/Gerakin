import 'package:firebase_auth/firebase_auth.dart' as fb;

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
/// File ini adalah SATU-SATUNYA tempat di seluruh modul Auth yang boleh
/// melakukan `import 'package:firebase_auth/firebase_auth.dart'`.
class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final fb.FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSourceImpl(this._firebaseAuth);

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
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update displayName setelah akun berhasil dibuat
    await credential.user?.updateDisplayName(displayName);
    await credential.user?.reload();

    final updatedUser = _firebaseAuth.currentUser;
    return AuthUser(
      uid: updatedUser?.uid ?? credential.user!.uid,
      email: updatedUser?.email ?? email,
      displayName: updatedUser?.displayName ?? displayName,
      emailVerified: updatedUser?.emailVerified ?? false,
    );
  }

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Login berhasil tapi data pengguna tidak tersedia.');
    }

    return AuthUser(
      uid: user.uid,
      email: user.email ?? email,
      displayName: user.displayName,
      emailVerified: user.emailVerified,
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
