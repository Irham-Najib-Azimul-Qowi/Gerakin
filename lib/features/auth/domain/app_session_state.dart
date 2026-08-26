import 'package:equatable/equatable.dart';
import '../../user/models/user_profile.dart';
import '../models/auth_user.dart';

/// Sealed class yang merepresentasikan state session aplikasi GERAKIN.
///
/// Mengikuti prinsip **Single Source of Truth** & **Mutually Exclusive Session**:
/// Hanya tepat satu state yang dapat aktif pada satu waktu:
/// - [SessionInitializing]: Saat aplikasi booting & memeriksa session.
/// - [SessionSignedOut]: Saat pengguna belum login dan belum memilih mode Guest.
/// - [SessionGuest]: Saat pengguna masuk dalam Mode Tamu (Guest Mode).
/// - [SessionAuthenticated]: Saat pengguna login terautentikasi melalui Firebase.
sealed class AppSessionState extends Equatable {
  const AppSessionState();

  @override
  List<Object?> get props => [];
}

/// State saat aplikasi sedang memuat dan memvalidasi session dari Firebase / lokal.
class SessionInitializing extends AppSessionState {
  const SessionInitializing();
}

/// State saat tidak ada sesi yang aktif (belum login dan bukan guest).
class SessionSignedOut extends AppSessionState {
  const SessionSignedOut();
}

/// State saat pengguna berada dalam Mode Tamu (Guest Mode).
class SessionGuest extends AppSessionState {
  final UserProfile profile;

  const SessionGuest(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// State saat pengguna berhasil login dengan akun terdaftar (Firebase Auth).
class SessionAuthenticated extends AppSessionState {
  final AuthUser user;
  final UserProfile profile;

  const SessionAuthenticated({
    required this.user,
    required this.profile,
  });

  @override
  List<Object?> get props => [user, profile];
}
