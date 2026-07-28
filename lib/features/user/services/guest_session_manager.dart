import '../domain/repositories/user_repository.dart';
import '../models/user_profile.dart';

/// Manajer sesi pengguna untuk mode Tamu (Guest Mode).
class GuestSessionManager {
  final UserRepository _repository;

  GuestSessionManager(this._repository);

  /// Memulai sesi Guest Mode. Membuat profile tamu baru dan mengaktifkannya.
  Future<UserProfile> startGuestSession() async {
    // Nonaktifkan semua profil aktif yang ada
    final active = await _repository.getActiveProfile();
    if (active != null) {
      await _repository.saveProfile(active.copyWith(isActive: false, updatedAt: DateTime.now()));
    }

    final guestProfile = UserProfile(
      displayName: 'Tamu (Guest)',
      gender: 'Lainnya',
      birthDate: DateTime(2000, 1, 1),
      height: 170.0,
      weight: 60.0,
      wheelchairType: 'none',
      mobilityLevel: 'intermediate',
      dominantHand: 'right',
      rehabilitationGoal: 'Pelihara Kebugaran',
      medicalNotes: 'Sesi Guest Mode.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: 'local_only',
      isGuest: true,
      isActive: true,
    );

    final id = await _repository.saveProfile(guestProfile);
    return guestProfile.copyWith(id: id);
  }

  /// Keluar dari sesi Guest Mode dan menghapus profil tamu dari penyimpanan lokal.
  Future<void> endGuestSession(int guestId) async {
    await _repository.deleteProfile(guestId);

    // Cari profil non-tamu pertama untuk diaktifkan kembali jika ada
    final all = await _repository.getAllProfiles();
    final nonGuest = all.where((p) => !p.isGuest).toList();
    if (nonGuest.isNotEmpty) {
      await _repository.switchProfile(nonGuest.first.id);
    }
  }
}
