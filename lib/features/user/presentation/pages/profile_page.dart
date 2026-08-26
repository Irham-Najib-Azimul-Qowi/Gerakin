import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/profile_controller.dart';
import '../../models/user_profile.dart';
import '../../../gamification/presentation/controllers/gamification_controller.dart';

/// Halaman Profil Pengguna untuk aplikasi GERAKIN (Sesuai DESIGN.md).
///
/// Personality: Bright, Friendly, Inclusive, Cheerful, Modern, Premium.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Profil Pengguna',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => context.pushNamed(RouteNames.settings),
            tooltip: 'Pengaturan',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.errorMessage != null
              ? Center(child: Text(state.errorMessage!, style: AppTextStyles.bodyMedium))
              : _buildProfileContent(context, ref, state),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, ProfileState state) {
    final active = state.activeProfile;
    if (active == null) {
      return Center(
        child: Text(
          'Tidak ada profil aktif. Silakan buat profil atau masuk.',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(profileControllerProvider.notifier).loadProfiles(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── GUEST PROMPT BANNER (IF IN GUEST MODE) ─────────────
            if (active.isGuest) ...[
              _buildGuestPromptCard(context),
              const SizedBox(height: 16),
            ],

            // ── PROFILE HEADER (CARD) ──────────────────────────────
            _buildProfileHeaderCard(context, active),
            const SizedBox(height: 16),

            // ── DAILY STREAK CARD ─────────────────────────────────
            _buildStreakCard(context, ref),
            const SizedBox(height: 24),

            // ── PROFILE PICKER / SWITCHER ──────────────────────────
            _buildProfileSwitcherSection(context, ref, state, active),
            const SizedBox(height: 24),

            // ── MOBILITY PROFILE & ATTRIBUTES ──────────────────────
            _buildSectionHeader('Profil Fisik & Aksesibilitas'),
            const SizedBox(height: 12),
            _buildMobilityDetailsCard(context, active),
            const SizedBox(height: 24),

            // ── WIZARD & ACTIONS ───────────────────────────────────
            _buildActionSection(context, active),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestPromptCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: AppRadius.borderRadiusXxl,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.2),
        boxShadow: AppShadows.softCard,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Tamu Aktif',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Masuk untuk menyimpan riwayat latihan & membuka fitur komunitas.',
                  style: AppTextStyles.captionSmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.pushNamed(RouteNames.auth),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(60, 36),
            ),
            child: Text(
              'Masuk',
              style: AppTextStyles.captionMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard(BuildContext context, UserProfile active) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusXxl,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.softCard,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primaryContainer,
            child: active.photoUrl != null && active.photoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Image.network(active.photoUrl!, fit: BoxFit.cover),
                  )
                : Text(
                    active.displayName.isNotEmpty ? active.displayName.substring(0, 1).toUpperCase() : 'G',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        active.displayName,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (active.isGuest)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadius.borderRadiusSm,
                        ),
                        child: Text(
                          'TAMU',
                          style: AppTextStyles.captionSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (active.email != null && active.email!.isNotEmpty)
                  Text(
                    active.email!,
                    style: AppTextStyles.captionMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Text(
                    '${active.gender} • ${active.height.toStringAsFixed(0)} cm • ${active.weight.toStringAsFixed(0)} kg',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSwitcherSection(
    BuildContext context,
    WidgetRef ref,
    ProfileState state,
    UserProfile active,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Ganti Profil Aktif'),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.allProfiles.length + (active.isGuest ? 1 : 1),
            itemBuilder: (context, index) {
              if (index == state.allProfiles.length) {
                // Jika Tamu -> Arahkan ke Login/Register
                if (active.isGuest) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => context.pushNamed(RouteNames.auth),
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text('Masuk Akun'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
                        minimumSize: const Size(48, 44),
                      ),
                    ),
                  );
                }

                // Tombol tambah profil untuk akun terdaftar
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => _showCreateProfileDialog(context, ref),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Profil Baru'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
                      minimumSize: const Size(48, 44),
                    ),
                  ),
                );
              }

              final profile = state.allProfiles[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(profile.displayName),
                  selected: profile.isActive,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(profileControllerProvider.notifier).switchProfile(profile.id);
                    }
                  },
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.surface,
                  labelStyle: AppTextStyles.captionMedium.copyWith(
                    fontWeight: profile.isActive ? FontWeight.bold : FontWeight.w500,
                    color: profile.isActive ? AppColors.primary : AppColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSm, // 8px chip
                    side: BorderSide(
                      color: profile.isActive ? AppColors.primary : AppColors.border,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobilityDetailsCard(BuildContext context, UserProfile active) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusXxl,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        children: [
          _buildDetailRow('Tipe Kursi Roda', active.wheelchairType.toUpperCase()),
          const Divider(color: AppColors.border),
          _buildDetailRow('Tingkat Mobilitas', active.mobilityLevel.toUpperCase()),
          const Divider(color: AppColors.border),
          _buildDetailRow('Tangan Dominan', active.dominantHand == 'right' ? 'KANAN' : 'KIRI'),
          const Divider(color: AppColors.border),
          _buildDetailRow('Target Kebugaran', active.rehabilitationGoal.toUpperCase()),
          if (active.medicalNotes.isNotEmpty) ...[
            const Divider(color: AppColors.border),
            _buildDetailRow('Catatan Kesehatan', active.medicalNotes),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.captionMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, UserProfile active) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => context.pushNamed(RouteNames.settings),
            icon: const Icon(Icons.settings_rounded, size: 20),
            label: const Text('Kelola Profil & Pengaturan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Icons.edit_rounded, size: 20),
            label: const Text('Edit Informasi Fisik'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/assessment-wizard'),
            icon: const Icon(Icons.fitness_center_rounded, size: 20),
            label: const Text('Mulai Uji Mobilitas (Wizard)'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  void _showCreateProfileDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String gender = 'Laki-laki';
    double height = 170;
    double weight = 65;
    String hand = 'right';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
              backgroundColor: AppColors.surface,
              title: Text('Tambah Profil Baru', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                        validator: (val) => val == null || val.isEmpty ? 'Nama harus diisi' : null,
                        onSaved: (val) => name = val!,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: gender,
                        decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                        items: const [
                          DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                          DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                          DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                        ],
                        onChanged: (val) => setState(() => gender = val!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: height.toString(),
                        decoration: const InputDecoration(labelText: 'Tinggi Badan (cm)'),
                        keyboardType: TextInputType.number,
                        onSaved: (val) => height = double.parse(val!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: weight.toString(),
                        decoration: const InputDecoration(labelText: 'Berat Badan (kg)'),
                        keyboardType: TextInputType.number,
                        onSaved: (val) => weight = double.parse(val!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: hand,
                        decoration: const InputDecoration(labelText: 'Tangan Dominan'),
                        items: const [
                          DropdownMenuItem(value: 'right', child: Text('Kanan')),
                          DropdownMenuItem(value: 'left', child: Text('Kiri')),
                        ],
                        onChanged: (val) => setState(() => hand = val!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      ref.read(profileControllerProvider.notifier).createProfile(
                            displayName: name,
                            gender: gender,
                            birthDate: DateTime(2000, 1, 1),
                            height: height,
                            weight: weight,
                            wheelchairType: 'manual',
                            mobilityLevel: 'intermediate',
                            dominantHand: hand,
                            rehabilitationGoal: 'Pelihara Kebugaran',
                            medicalNotes: '',
                          );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStreakCard(BuildContext context, WidgetRef ref) {
    final gamificationState = ref.watch(gamificationControllerProvider);
    final currentStreak = gamificationState.streak?.currentStreak ?? 1;
    final longestStreak = gamificationState.streak?.longestStreak ?? 1;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Warm yellow tint
        borderRadius: AppRadius.borderRadiusXxl,
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        boxShadow: AppShadows.softCard,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak Latihan Harian',
                  style: AppTextStyles.captionSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB45309),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$currentStreak Hari Berturut-turut',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Rekor Terpanjang: $longestStreak Hari',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
