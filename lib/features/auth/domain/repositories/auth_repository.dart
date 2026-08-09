import '../../models/auth_user.dart';

/// Kontrak abstrak repositori autentikasi.
///
/// Layer [presentation] dan [domain] hanya boleh bergantung ke interface ini —
/// tidak boleh mengimpor `firebase_auth` secara langsung. Implementasi konkret
/// ada di `data/repositories/auth_repository_impl.dart`.
abstract class AuthRepository {
  /// Stream yang memancarkan [AuthUser] saat pengguna login,
  /// atau `null` saat pengguna logout / belum login.
  ///
  /// Ini adalah sumber kebenaran (source of truth) untuk status autentikasi
  /// yang dikonsumsi oleh [currentAuthUserProvider].
  Stream<AuthUser?> authStateChanges();

  /// Pengguna yang sedang aktif saat ini, atau `null` jika belum login.
  AuthUser? get currentUser;

  /// Mendaftarkan pengguna baru dengan email dan password.
  ///
  /// Melempar [FirebaseAuthException] (via layer data) jika registrasi gagal.
  /// Error diterjemahkan ke pesan Bahasa Indonesia di layer [presentation].
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Login pengguna yang sudah terdaftar dengan email dan password.
  ///
  /// Melempar [FirebaseAuthException] (via layer data) jika login gagal.
  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  /// Logout pengguna yang sedang aktif.
  Future<void> signOut();

  /// Mengirim email tautan reset password ke alamat [email].
  ///
  /// Melempar exception jika email tidak terdaftar atau request gagal.
  Future<void> sendPasswordResetEmail(String email);
}
