# Technical Requirements Document (TRD)
## Modul: Authentication (`features/auth`)

| | |
|---|---|
| **Proyek** | GerakIn — KMIPN VIII 2026 |
| **Branch** | `feature/auth-module` |
| **Status saat ini** | Placeholder — `auth_page.dart` hanya UI statis tanpa logika. Dependency `firebase_auth` **belum** ada di `pubspec.yaml`. |
| **Folder kerja** | `lib/features/auth/**` (buat baru), plus edit minor di `pubspec.yaml` dan `core/router/app_router.dart` |
| **Dependensi modul lain** | Membaca/menulis ke `UserRepository` yang **sudah ada** di `lib/features/user/**` — jangan dibuat ulang |
| **Ditujukan untuk** | Developer manusia maupun AI coding assistant (Claude Code, dsb.) yang mengerjakan modul ini |

---

## 1. Ringkasan & Tujuan

Modul Auth bertanggung jawab atas registrasi, login, logout, dan reset password pengguna GerakIn menggunakan **Firebase Authentication**, lalu menghubungkan identitas tersebut ke `UserProfile` lokal (ObjectBox) yang sudah dibangun oleh modul `user`. Modul ini **tidak membuat sistem profil baru** — ia hanya menjadi lapisan identitas/kredensial di atas profil yang sudah ada.

Prinsip offline-first proyek harus tetap dipegang: aplikasi harus tetap bisa dipakai dalam mode Guest (`GuestSessionManager` sudah ada) tanpa login, dan transisi guest → akun terdaftar harus mulus tanpa kehilangan data lokal.

## 2. Cakupan

**In-scope:**
- Registrasi email + password
- Login email + password
- Logout
- Reset password (kirim email reset via Firebase)
- Observasi status login (`authStateChanges`) yang tersedia sebagai provider global
- Migrasi profil Guest lokal → akun terdaftar setelah registrasi/login berhasil
- Halaman UI: form login, form register, form lupa password
- Guard dasar: beberapa route (mis. `collaboration`, `settings`) opsional bisa disembunyikan/dibatasi untuk Guest — **diskusikan dengan tim sebelum implementasi**, tidak wajib di versi pertama

**Out-of-scope (jangan dikerjakan di modul ini):**
- Login sosial (Google/Apple Sign-In) — bukan bagian dari proposal
- Manajemen banyak akun sekaligus (sudah ditangani `MultiProfileManager` di modul `user`, itu beda konsep dari akun Firebase)
- Verifikasi email wajib (opsional, boleh dikerjakan di versi lanjutan)
- Perubahan pada `UserProfile` model (field sudah cukup — lihat Bagian 3)

## 3. Kondisi Existing Codebase yang WAJIB Dipakai Ulang

Jangan membuat ulang hal-hal berikut — modul Auth harus terintegrasi dengan ini:

```dart
// lib/features/user/models/user_profile.dart
// Field `email` SUDAH ADA di UserProfile — pakai ini untuk link ke akun Firebase.
// Field `syncStatus` ('local_only' | 'synced') SUDAH ADA untuk menandai status sinkronisasi.
// Field `isGuest` SUDAH ADA.

// lib/features/user/domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<UserProfile?> getActiveProfile();
  Future<int> saveProfile(UserProfile profile);
  // ...gunakan method-method ini, jangan bikin repository baru untuk profil.
}

// lib/features/user/services/guest_session_manager.dart
class GuestSessionManager {
  Future<UserProfile> startGuestSession();
  Future<void> endGuestSession(int guestId);
  // Modul Auth akan MEMANGGIL endGuestSession() saat guest berhasil register,
  // lalu membuat/mengupdate UserProfile dengan email dari Firebase.
}

// Provider yang sudah ada dan bisa langsung dipakai:
// userRepositoryProvider  → lib/features/user/data/repositories/user_repository_impl.dart
```

**Pola arsitektur proyek** (wajib diikuti, lihat `ARCHITECTURE.md` di root repo):
```
lib/features/<feature>/
├── presentation/   # UI widgets + Riverpod Notifier/Controller
├── domain/         # Repository interface (abstraksi)
├── data/           # Implementasi repository + data source
├── services/       # Business logic murni (non-UI, non-storage)
└── models/         # Entity/DTO
```
Layer `presentation` dan `domain` **tidak boleh** bergantung langsung ke Firebase SDK — hanya `data/` yang boleh mengimpor `firebase_auth`.

## 4. Struktur Folder yang Harus Dibuat

```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   └── firebase_auth_data_source.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   └── repositories/
│       └── auth_repository.dart
├── models/
│   └── auth_user.dart
├── services/
│   └── auth_session_bridge.dart      # jembatan Auth ↔ UserRepository (guest → registered)
└── presentation/
    ├── controllers/
    │   └── auth_controller.dart       # Notifier, mengganti isi auth_page.dart saat ini
    ├── pages/
    │   ├── login_page.dart
    │   ├── register_page.dart
    │   └── forgot_password_page.dart
    └── widgets/
        └── auth_error_banner.dart
```
Hapus isi lama `lib/features/auth/presentation/pages/auth_page.dart` atau jadikan halaman pemilihan (Login / Register / Lanjutkan sebagai Tamu) yang mengarahkan ke tiga halaman baru di atas.

## 5. Kontrak Domain (`AuthRepository`)

```dart
// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();
  AuthUser? get currentUser;

  Future<AuthUser> signUp({required String email, required String password, required String displayName});
  Future<AuthUser> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}
```

```dart
// lib/features/auth/models/auth_user.dart
class AuthUser {
  final String uid;
  final String email;
  final String? displayName;
  final bool emailVerified;

  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    required this.emailVerified,
  });
}
```

> Catatan: `AuthUser` adalah model ringan milik modul Auth, **berbeda** dari `UserProfile` (modul `user`). Jangan digabung jadi satu class. Keduanya dihubungkan lewat field `email` dan lewat `AuthSessionBridge` (Bagian 6).

## 6. Service Kunci: `AuthSessionBridge`

Ini bagian paling penting secara teknis — logika penghubung antara akun Firebase dan `UserProfile` lokal:

```dart
// lib/features/auth/services/auth_session_bridge.dart
class AuthSessionBridge {
  final UserRepository _userRepository;      // dari modul user, JANGAN buat ulang
  final GuestSessionManager _guestManager;   // dari modul user, JANGAN buat ulang

  AuthSessionBridge(this._userRepository, this._guestManager);

  /// Dipanggil setelah signUp/signIn Firebase berhasil.
  /// Logika:
  /// 1. Cek apakah ada UserProfile lokal dengan email yang sama (kemungkinan sinkron dari device lain).
  /// 2. Jika ada guest profile aktif → migrasikan: update profile itu jadi
  ///    email = authUser.email, isGuest = false, syncStatus = 'pending_sync'.
  /// 3. Jika tidak ada profile sama sekali → buat UserProfile baru minimal
  ///    (displayName dari authUser, sisanya diisi lewat Assessment Wizard yang SUDAH ADA
  ///    di lib/features/user/presentation/pages/assessment_wizard_page.dart).
  Future<UserProfile> linkAuthToProfile(AuthUser authUser) async { ... }
}
```

Alasan desain ini: proyek sudah punya **Assessment Wizard** untuk mengisi data fisik/kursi roda pengguna baru — modul Auth tidak perlu menduplikasi form itu. Setelah `linkAuthToProfile()`, arahkan navigasi ke `/assessment-wizard` jika profil baru dibuat.

## 7. Riverpod Providers (WAJIB — ini yang dipakai modul Community)

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSourceImpl(FirebaseAuth.instance);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthDataSourceProvider));
});

/// KONTRAK PENTING: provider ini dipakai modul lain (Community, Collaboration)
/// untuk tahu siapa user yang sedang login. Nama dan tipe return TIDAK BOLEH diubah
/// tanpa koordinasi tim, karena modul Community sudah dikembangkan di atas provider ini.
final currentAuthUserProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
```

> **Untuk pengembangan paralel:** buat provider `currentAuthUserProvider` ini di commit **paling awal** (hari pertama), meski implementasinya masih dummy/return `null` terus. Developer Community akan langsung develop di atasnya tanpa menunggu Auth selesai penuh.

`AuthController` (Notifier) membungkus pemanggilan `AuthRepository` untuk dipakai oleh `login_page.dart`, `register_page.dart`, `forgot_password_page.dart` — ikuti pola persis `ProfileController` di `lib/features/user/presentation/controllers/profile_controller.dart` (state class dengan `isLoading` + `errorMessage`, method async yang set state sebelum/sesudah operasi, `try/catch`).

## 8. Routing

Edit `lib/core/router/route_names.dart` — tambahkan (jangan ubah nama/path yang sudah ada):
```dart
static const String login = 'login';
static const String register = 'register';
static const String forgotPassword = 'forgotPassword';
// paths:
static const String login = '/auth/login';
static const String register = '/auth/register';
static const String forgotPassword = '/auth/forgot-password';
```

Edit `lib/core/router/app_router.dart` — tambahkan 3 `GoRoute` baru di bawah route `RoutePaths.auth` yang sudah ada (jangan hapus route `auth` yang existing, jadikan halaman pemilihan). **Ini file yang juga disentuh modul Community** — tambahkan di blok terpisah dengan komentar `// ── Auth Routes ──`, jangan sisipkan di tengah kode orang lain.

## 9. Dependency Baru (`pubspec.yaml`)

```yaml
dependencies:
  firebase_auth: ^5.3.0   # samakan versi major dengan firebase_core: ^3.3.0 yang sudah ada
```
Tambahkan di bawah baris `firebase_core: ^3.3.0` yang sudah ada di section "Cloud & Connectivity". Jangan reformat/reorder dependency lain.

## 10. Keamanan & Privasi

- Password tidak pernah disimpan di ObjectBox lokal — hanya token session Firebase (dikelola otomatis oleh SDK `firebase_auth`).
- Gunakan `SecurityHardening` yang sudah ada di `lib/core/security/security_hardening.dart` untuk sanitasi input email/nama sebelum dikirim ke Firebase.
- Pesan error dari Firebase (`FirebaseAuthException`) harus di-translate ke Bahasa Indonesia yang ramah pengguna di layer `presentation`, jangan tampilkan `error.code` mentah ke UI.

## 11. Definition of Done

- [ ] `firebase_auth` ditambahkan ke `pubspec.yaml`, `flutter pub get` berhasil
- [ ] Register, login, logout, reset password berfungsi end-to-end dengan Firebase project GerakIn
- [ ] `AuthSessionBridge` berhasil migrasi guest profile → akun terdaftar tanpa kehilangan data (`wheelchairType`, `mobilityLevel`, dll. tetap ada setelah login)
- [ ] `currentAuthUserProvider` bisa dikonsumsi modul lain tanpa error
- [ ] Unit test untuk `AuthSessionBridge.linkAuthToProfile()` (mock `UserRepository`, ikuti pola mock repository di `ARCHITECTURE.md` bagian Testing Strategy)
- [ ] Tidak ada import `firebase_auth` di luar folder `data/`
- [ ] `flutter analyze` bersih (proyek pakai `flutter_lints`)

## 12. Catatan Khusus untuk AI Coding Assistant

Jika kamu (AI) mengerjakan modul ini secara otomatis:
1. **Baca dulu** `lib/features/user/**` secara menyeluruh sebelum menulis kode apa pun — jangan berasumsi tentang bentuk `UserProfile`.
2. Ikuti gaya penamaan file **snake_case**, class **PascalCase**, sesuai contoh di Bagian 4–7.
3. Gunakan `Notifier`/`NotifierProvider` dari Riverpod (bukan `StateNotifier` lama) — lihat `profile_controller.dart` sebagai referensi versi Riverpod yang dipakai proyek ini (`flutter_riverpod: ^3.3.2`).
4. Jangan menyentuh file di `lib/features/community/**`, `lib/features/user/models/**`, atau `lib/data/local/objectbox_store.dart` — di luar cakupan modul ini.
5. Jika perlu regenerasi kode ObjectBox (karena ada entity baru), jalankan `dart run build_runner build --delete-conflicting-outputs` — tapi modul Auth **tidak butuh entity ObjectBox baru** (token session ditangani otomatis oleh Firebase SDK), jadi seharusnya tidak perlu.