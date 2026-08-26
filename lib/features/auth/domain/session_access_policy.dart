import 'app_session_state.dart';

/// Daftar fitur dalam aplikasi GERAKIN yang memiliki aturan hak akses.
enum AppFeature {
  /// Beranda utama / landing.
  home,

  /// Menu pilihan latihan.
  exerciseMenu,

  /// Edukasi dan instruksi gerakan latihan.
  exerciseEducation,

  /// Sesi latihan interaktif dengan kamera & AI pose estimation.
  exerciseCameraSession,

  /// Hasil dan ringkasan sesi latihan (sementara/lokal).
  sessionResult,

  /// Pengaturan umum/dasar aplikasi.
  basicSettings,

  /// Informasi aplikasi & Kebijakan Privasi.
  privacyAndAbout,

  /// Membaca feed postingan komunitas.
  communityRead,

  /// Membuat postingan baru di komunitas.
  communityPost,

  /// Menulis komentar pada postingan komunitas.
  communityComment,

  /// Menyukai postingan komunitas.
  communityLike,

  /// Mengedit data profil pengguna.
  profileEdit,

  /// Melihat riwayat latihan permanen tersinkronisasi cloud.
  permanentHistory,

  /// Sinkronisasi data ke cloud storage.
  cloudSync,

  /// Pengaturan identitas & keamanan akun.
  accountSettings,

  /// Menghapus akun pengguna.
  deleteAccount,

  /// Progres streak & badge gamifikasi permanen.
  streakAndBadges,
}

/// Kebijakan Hak Akses (Access Policy) berdasarkan [AppSessionState].
class SessionAccessPolicy {
  SessionAccessPolicy._();

  /// Memeriksa apakah state session saat ini diperbolehkan mengakses [feature].
  static bool canAccess(AppSessionState session, AppFeature feature) {
    return switch (session) {
      SessionInitializing() => false,
      SessionSignedOut() => _canAccessSignedOut(feature),
      SessionGuest() => _canAccessGuest(feature),
      SessionAuthenticated() => true, // User terautentikasi dapat mengakses semua fitur
    };
  }

  static bool _canAccessSignedOut(AppFeature feature) {
    return feature == AppFeature.privacyAndAbout || feature == AppFeature.basicSettings;
  }

  static bool _canAccessGuest(AppFeature feature) {
    return switch (feature) {
      AppFeature.home => true,
      AppFeature.exerciseMenu => true,
      AppFeature.exerciseEducation => true,
      AppFeature.exerciseCameraSession => true,
      AppFeature.sessionResult => true,
      AppFeature.basicSettings => true,
      AppFeature.privacyAndAbout => true,
      AppFeature.communityRead => true,

      // Fitur yang DIBATASI untuk Guest
      AppFeature.communityPost => false,
      AppFeature.communityComment => false,
      AppFeature.communityLike => false,
      AppFeature.profileEdit => false,
      AppFeature.permanentHistory => false,
      AppFeature.cloudSync => false,
      AppFeature.accountSettings => false,
      AppFeature.deleteAccount => false,
      AppFeature.streakAndBadges => false,
    };
  }

  /// Pesan penjelasan kontekstual mengapa fitur ini terkunci untuk Guest.
  static String getLockedReason(AppFeature feature) {
    return switch (feature) {
      AppFeature.communityPost ||
      AppFeature.communityComment ||
      AppFeature.communityLike =>
        'Masuk dengan akun terdaftar untuk berpartisipasi dan berbagi di komunitas GERAKIN.',
      AppFeature.profileEdit || AppFeature.accountSettings =>
        'Masuk ke akun Anda untuk mengelola profil dan informasi pribadi.',
      AppFeature.permanentHistory || AppFeature.cloudSync =>
        'Masuk untuk menyimpan riwayat latihan secara permanen dan menyinkronkan antar perangkat.',
      AppFeature.streakAndBadges =>
        'Masuk atau buat akun untuk membangun streak latihan harian dan membuka badge pencapaian.',
      _ => 'Fitur ini memerlukan akun terdaftar agar data Anda dapat disimpan dengan aman.',
    };
  }
}
