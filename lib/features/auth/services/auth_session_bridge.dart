import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../user/data/repositories/user_repository_impl.dart';
import '../../user/domain/repositories/user_repository.dart';
import '../../user/models/user_profile.dart';
import '../../user/services/guest_session_manager.dart';
import '../models/auth_user.dart';

/// Enum yang mendeskripsikan hasil dari [AuthSessionBridge.linkAuthToProfile].
///
/// Digunakan oleh [AuthController] untuk menentukan arah navigasi setelah
/// login/register berhasil.
enum LinkAuthResult {
  /// Profil guest berhasil dimigrasi ke akun terdaftar → arahkan ke Home.
  guestMigrated,

  /// Ditemukan profil lokal dengan email yang sama → diaktifkan → arahkan ke Home.
  existingProfileActivated,

  /// Tidak ada profil → dibuat profil baru minimal → arahkan ke Assessment Wizard.
  newProfileCreated,
}

/// Hasil kembalian dari [AuthSessionBridge.linkAuthToProfile].
class LinkAuthOutput {
  final UserProfile profile;
  final LinkAuthResult result;

  const LinkAuthOutput({required this.profile, required this.result});
}

/// Service jembatan antara identitas Firebase [AuthUser] dan [UserProfile] lokal.
///
/// Bertanggung jawab atas tiga skenario yang terjadi setelah login/register berhasil:
/// 1. Migrasi profil Guest aktif → akun terdaftar.
/// 2. Aktivasi profil lokal yang emailnya sudah cocok (misalnya dari device lain).
/// 3. Pembuatan profil baru minimal jika tidak ada profil sebelumnya.
///
/// Class ini TIDAK membuat [UserRepository] atau [GuestSessionManager] baru —
/// keduanya di-inject dari modul `user` yang sudah ada.
class AuthSessionBridge {
  final UserRepository _userRepository;
  final GuestSessionManager _guestManager; // dipakai oleh authSessionBridgeProvider

  AuthSessionBridge(this._userRepository, this._guestManager);

  /// Mengakhiri sesi guest yang aktif dan menghapus profilnya.
  /// Dipanggil secara internal saat migrasi jika diperlukan di masa depan.
  // ignore: unused_field — field ini disimpan untuk kebutuhan extensibility
  GuestSessionManager get guestManager => _guestManager;

  /// Menghubungkan [AuthUser] Firebase ke [UserProfile] lokal.
  ///
  /// Dipanggil tepat setelah `signUp` atau `signIn` Firebase berhasil.
  ///
  /// **Logika urutan:**
  /// ```
  /// 1. Ambil profil aktif saat ini.
  ///    └── Jika profil aktif adalah Guest → MIGRASI:
  ///        • Salin semua data fisik yang ada (wheelchairType, mobilityLevel, dll.)
  ///        • Ubah: email, displayName (jika ada), isGuest=false, syncStatus='pending_sync'
  ///        • Simpan → return [LinkAuthResult.guestMigrated]
  ///
  /// 2. Jika profil aktif bukan Guest (atau tidak ada) → cari semua profil:
  ///    └── Ada yang emailnya cocok? → Aktifkan profil itu
  ///        → return [LinkAuthResult.existingProfileActivated]
  ///
  /// 3. Tidak ada profil sama sekali / tidak ada email yang cocok:
  ///    → Buat [UserProfile] minimal baru (data fisik diisi lewat Assessment Wizard)
  ///    → return [LinkAuthResult.newProfileCreated]
  /// ```
  Future<LinkAuthOutput> linkAuthToProfile(AuthUser authUser) async {
    // ── Skenario 1: Ada profil Guest aktif → Migrasi ──────────────────────
    final activeProfile = await _userRepository.getActiveProfile();

    if (activeProfile != null && activeProfile.isGuest) {
      final migratedProfile = activeProfile.copyWith(
        email: authUser.email,
        displayName: authUser.displayName ?? activeProfile.displayName,
        isGuest: false,
        syncStatus: 'pending_sync',
        updatedAt: DateTime.now(),
      );

      await _userRepository.saveProfile(migratedProfile);

      return LinkAuthOutput(
        profile: migratedProfile,
        result: LinkAuthResult.guestMigrated,
      );
    }

    // ── Skenario 2: Cari profil lokal dengan email yang cocok ─────────────
    final allProfiles = await _userRepository.getAllProfiles();
    final emailMatch = allProfiles
        .where((p) => p.email?.toLowerCase() == authUser.email.toLowerCase())
        .toList();

    if (emailMatch.isNotEmpty) {
      final matchedProfile = emailMatch.first;
      await _userRepository.switchProfile(matchedProfile.id);

      // Perbarui syncStatus jika masih 'local_only'
      if (matchedProfile.syncStatus == 'local_only') {
        final updated = matchedProfile.copyWith(
          syncStatus: 'pending_sync',
          updatedAt: DateTime.now(),
        );
        await _userRepository.saveProfile(updated);
        return LinkAuthOutput(
          profile: updated,
          result: LinkAuthResult.existingProfileActivated,
        );
      }

      return LinkAuthOutput(
        profile: matchedProfile,
        result: LinkAuthResult.existingProfileActivated,
      );
    }

    // ── Skenario 3: Tidak ada profil cocok → Buat profil baru minimal ─────
    // Data fisik (wheelchairType, mobilityLevel, dll.) akan diisi lewat
    // Assessment Wizard yang sudah ada di lib/features/user/presentation/pages/
    final now = DateTime.now();
    final newProfile = UserProfile(
      displayName: authUser.displayName ?? authUser.email.split('@').first,
      email: authUser.email,
      gender: 'Lainnya',
      birthDate: DateTime(2000, 1, 1),
      height: 170.0,
      weight: 60.0,
      wheelchairType: 'none',
      mobilityLevel: 'intermediate',
      dominantHand: 'right',
      rehabilitationGoal: 'Pelihara Kebugaran',
      medicalNotes: '',
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending_sync',
      isGuest: false,
      isActive: true,
    );

    // Nonaktifkan profil aktif yang ada (jika ada) sebelum menyimpan yang baru
    if (activeProfile != null) {
      await _userRepository.saveProfile(
        activeProfile.copyWith(isActive: false, updatedAt: now),
      );
    }

    final savedId = await _userRepository.saveProfile(newProfile);

    return LinkAuthOutput(
      profile: newProfile.copyWith(id: savedId),
      result: LinkAuthResult.newProfileCreated,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider untuk instansiasi [AuthSessionBridge].
///
/// Meng-inject [UserRepository] dan [GuestSessionManager] dari modul `user`
/// yang sudah ada — tidak membuat repository baru.
final authSessionBridgeProvider = Provider<AuthSessionBridge>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthSessionBridge(
    userRepository,
    GuestSessionManager(userRepository),
  );
});
