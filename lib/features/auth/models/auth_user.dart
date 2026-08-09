/// Model ringan yang merepresentasikan identitas pengguna dari Firebase Authentication.
///
/// [AuthUser] BERBEDA dari [UserProfile] (modul `user`) — class ini hanya menyimpan
/// data identitas/kredensial Firebase. Keduanya dihubungkan lewat field [email]
/// melalui [AuthSessionBridge].
class AuthUser {
  /// UID unik dari Firebase Authentication.
  final String uid;

  /// Alamat email yang terdaftar di Firebase.
  final String email;

  /// Nama tampilan pengguna (opsional, bisa null jika belum diset).
  final String? displayName;

  /// Status verifikasi email di Firebase.
  final bool emailVerified;

  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    required this.emailVerified,
  });

  @override
  String toString() {
    return 'AuthUser(uid: $uid, email: $email, '
        'displayName: $displayName, emailVerified: $emailVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.uid == uid && other.email == email;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;
}
