/// Exception yang merepresentasikan kegagalan operasi autentikasi.
///
/// Dilempar oleh [FirebaseAuthDataSource] setelah men-translate
/// [FirebaseAuthException] Firebase — sehingga layer di atas `data/`
/// (domain, presentation) tidak perlu mengimport `firebase_auth` SDK.
class AuthException implements Exception {
  /// Kode error asli dari Firebase (contoh: 'user-not-found').
  final String code;

  /// Pesan error dalam Bahasa Indonesia yang sudah siap ditampilkan ke UI.
  final String message;

  const AuthException({required this.code, required this.message});

  @override
  String toString() => 'AuthException($code): $message';
}
