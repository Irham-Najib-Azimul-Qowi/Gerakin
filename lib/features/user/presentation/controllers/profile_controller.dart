import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../models/user_profile.dart';
import '../../services/guest_session_manager.dart';
import '../../services/multi_profile_manager.dart';

/// State untuk manajemen profil.
class ProfileState {
  final UserProfile? activeProfile;
  final List<UserProfile> allProfiles;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.activeProfile,
    required this.allProfiles,
    required this.isLoading,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserProfile? activeProfile,
    List<UserProfile>? allProfiles,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      activeProfile: activeProfile ?? this.activeProfile,
      allProfiles: allProfiles ?? this.allProfiles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller (Notifier) untuk mengelola operasi profil pengguna.
class ProfileController extends Notifier<ProfileState> {
  late final UserRepository _repository;
  late final GuestSessionManager _guestManager;
  late final MultiProfileManager _profileManager;

  @override
  ProfileState build() {
    _repository = ref.watch(userRepositoryProvider);
    _guestManager = GuestSessionManager(_repository);
    _profileManager = MultiProfileManager(_repository);

    // Muat data profil secara async setelah widget build selesai
    Future.microtask(() => loadProfiles());

    return ProfileState(
      allProfiles: const [],
      isLoading: true,
    );
  }

  /// Memuat profil aktif dan semua profil dari database lokal.
  Future<void> loadProfiles() async {
    try {
      state = state.copyWith(isLoading: true);

      final active = await _repository.getActiveProfile();
      final all = await _repository.getAllProfiles();

      // Jika belum ada profil sama sekali di database lokal, buat profil guest awal sebagai default
      if (all.isEmpty) {
        final guest = await _guestManager.startGuestSession();
        state = state.copyWith(
          activeProfile: guest,
          allProfiles: [guest],
          isLoading: false,
          errorMessage: null,
        );
        return;
      }

      state = state.copyWith(
        activeProfile: active ?? (all.isNotEmpty ? all.first : null),
        allProfiles: all,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat profil: $e',
      );
    }
  }

  /// Mulai sesi tamu baru.
  Future<void> startGuestSession() async {
    try {
      state = state.copyWith(isLoading: true);
      await _guestManager.startGuestSession();
      await loadProfiles();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Akhiri sesi tamu tertentu.
  Future<void> endGuestSession(int id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _guestManager.endGuestSession(id);
      await loadProfiles();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Beralih ke profil pengguna lain.
  Future<void> switchProfile(int id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _profileManager.switchProfile(id);
      await loadProfiles();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Membuat profil pengguna baru.
  Future<void> createProfile({
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
    try {
      state = state.copyWith(isLoading: true);
      await _profileManager.createProfile(
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
      );
      await loadProfiles();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Memperbarui informasi profil pengguna aktif saat ini.
  Future<void> updateActiveProfile(UserProfile updated) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.saveProfile(updated.copyWith(updatedAt: DateTime.now()));
      await loadProfiles();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Menghapus profil pengguna tertentu.
  Future<void> deleteProfile(int id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _profileManager.deleteProfile(id);
      await loadProfiles();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

/// Provider untuk instansiasi [ProfileController].
final profileControllerProvider = NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);
