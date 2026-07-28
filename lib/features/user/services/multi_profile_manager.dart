import '../domain/repositories/user_repository.dart';
import '../models/user_profile.dart';

/// Layanan untuk mengelola multi-profil pengguna dalam satu aplikasi.
class MultiProfileManager {
  final UserRepository _repository;

  MultiProfileManager(this._repository);

  /// Mendapatkan daftar semua profil pengguna.
  Future<List<UserProfile>> getAllProfiles() async {
    return _repository.getAllProfiles();
  }

  /// Beralih ke profil aktif lain berdasarkan [profileId].
  Future<void> switchProfile(int profileId) async {
    await _repository.switchProfile(profileId);
  }

  /// Membuat profil pengguna baru.
  Future<UserProfile> createProfile({
    required String displayName,
    required String gender,
    required DateTime birthDate,
    required double height,
    required double weight,
    required String wheelchairType,
    required String mobilityLevel,
    required String dominantHand,
    required String rehabilitationGoal,
    required String medicalNotes,
  }) async {
    // Nonaktifkan profil aktif saat ini jika ada
    final active = await _repository.getActiveProfile();
    if (active != null) {
      await _repository.saveProfile(active.copyWith(isActive: false, updatedAt: DateTime.now()));
    }

    final newProfile = UserProfile(
      displayName: displayName,
      gender: gender,
      birthDate: birthDate,
      height: height,
      weight: weight,
      wheelchairType: wheelchairType,
      mobilityLevel: mobilityLevel,
      dominantHand: dominantHand,
      rehabilitationGoal: rehabilitationGoal,
      medicalNotes: medicalNotes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: 'local_only',
      isGuest: false,
      isActive: true,
    );

    final id = await _repository.saveProfile(newProfile);
    return newProfile.copyWith(id: id);
  }

  /// Menghapus profil tertentu berdasarkan [profileId].
  Future<void> deleteProfile(int profileId) async {
    final profile = await _repository.getProfileById(profileId);
    if (profile == null) return;

    await _repository.deleteProfile(profileId);

    // Jika yang dihapus adalah profil aktif, alihkan ke profil non-tamu pertama yang tersedia
    if (profile.isActive) {
      final all = await _repository.getAllProfiles();
      final nonGuest = all.where((p) => !p.isGuest).toList();
      if (nonGuest.isNotEmpty) {
        await _repository.switchProfile(nonGuest.first.id);
      } else if (all.isNotEmpty) {
        await _repository.switchProfile(all.first.id);
      }
    }
  }
}
