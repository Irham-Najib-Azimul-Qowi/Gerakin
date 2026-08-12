import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../models/auth_user.dart';
import '../datasources/firebase_auth_data_source.dart';

/// Implementasi [AuthRepository] yang mendelegasikan operasi ke [FirebaseAuthDataSource].
///
/// Layer ini bertugas meneruskan panggilan dari domain ke data source,
/// tanpa membocorkan detail Firebase SDK ke lapisan atas.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<AuthUser?> authStateChanges() => _dataSource.authStateChanges();

  @override
  AuthUser? get currentUser => _dataSource.currentUser;

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return _dataSource.createUserWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    return _dataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _dataSource.sendPasswordResetEmail(email);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider untuk instansiasi [FirebaseAuthDataSource].
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSourceImpl();
});

/// Provider untuk instansiasi [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthDataSourceProvider));
});

/// Stream provider status autentikasi — dikonsumsi oleh modul lain (Community, Collaboration).
///
/// KONTRAK PUBLIK: Nama provider ini ([currentAuthUserProvider]) dan tipe return
/// ([AsyncValue<AuthUser?>]) TIDAK BOLEH diubah tanpa koordinasi dengan tim,
/// karena modul Community sudah dikembangkan di atas provider ini.
///
/// Memancarkan [AuthUser] saat ada pengguna login, atau `null` saat logout/belum login.
final currentAuthUserProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
