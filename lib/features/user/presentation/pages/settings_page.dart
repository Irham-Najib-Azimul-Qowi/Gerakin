import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../sync/presentation/widgets/sync_status_indicator.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/settings_controller.dart';
import '../../models/user_preference.dart';

/// Halaman Pengaturan Aplikasi terintegrasi dengan preferensi profil dan sesi (Sesuai DESIGN.md).
///
/// Kebijakan Mode Tamu (Task 1):
/// Transisi dari mode Tamu ke akun resmi harus melalui alur Autentikasi/Login/Registrasi (RoutePaths.auth).
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final settingsState = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Pengaturan & Sesi',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: settingsState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _buildSettingsContent(context, ref, profileState, settingsState),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    ProfileState profileState,
    SettingsState settingsState,
  ) {
    final pref = settingsState.preferences;
    final app = settingsState.appSetting;
    final activeProfile = profileState.activeProfile;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SyncStatusIndicator(),
        const SizedBox(height: 16),

        // ── CATEGORY 1: EXERCISE PREFERENCES ────────────────────────
        _buildSectionHeader('Preferensi Latihan & Aksesibilitas'),
        const SizedBox(height: 8),
        if (pref != null) ...[
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderRadiusXxl,
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: AppShadows.softCard,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Petunjuk Suara (Audio Cues)', style: AppTextStyles.labelLarge),
                  subtitle: Text('Mengeluarkan suara saat pergantian repetisi', style: AppTextStyles.captionSmall),
                  value: pref.enableAudioCues,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(settingsControllerProvider.notifier).updatePreferences(
                          pref.copyWith(enableAudioCues: val),
                        );
                  },
                ),
                const Divider(height: 1, color: AppColors.border),
                SwitchListTile(
                  title: Text('Text-to-Speech (TTS)', style: AppTextStyles.labelLarge),
                  subtitle: Text('Membacakan instruksi dan koreksi otomatis', style: AppTextStyles.captionSmall),
                  value: pref.enableTts,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(settingsControllerProvider.notifier).updatePreferences(
                          pref.copyWith(enableTts: val),
                        );
                  },
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  title: Text('Tema Tampilan', style: AppTextStyles.labelLarge),
                  subtitle: Text('Tema aktif: ${pref.themeMode.toUpperCase()}', style: AppTextStyles.captionSmall),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () => _showThemePicker(context, ref, pref),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  title: Text('Pengingat Latihan Harian', style: AppTextStyles.labelLarge),
                  subtitle: Text('Pengingat pada jam: ${pref.dailyReminderTime}', style: AppTextStyles.captionSmall),
                  trailing: const Icon(Icons.access_time_rounded, color: AppColors.textSecondary),
                  onTap: () => _showTimePicker(context, ref, pref),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),

        // ── CATEGORY 2: SESSION & ACCOUNT MANAGEMENT ────────────────
        _buildSectionHeader('Manajemen Sesi & Akun'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderRadiusXxl,
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: AppShadows.softCard,
          ),
          child: Column(
            children: [
              if (activeProfile == null || activeProfile.isGuest) ...[
                // Sesi Tamu (Guest Mode)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.warningContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_outline_rounded, color: Color(0xFFB45309)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      activeProfile?.displayName ?? 'Pengguna Tamu',
                                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                const SizedBox(height: 2),
                                Text(
                                  'Progres hanya tersimpan di perangkat lokal.',
                                  style: AppTextStyles.captionSmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tombol Masuk / Daftar Akun Resmi (Masuk ke halaman Login/Register)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => context.pushNamed(RouteNames.auth),
                          icon: const Icon(Icons.login_rounded, size: 20),
                          label: const Text('Masuk atau Daftar Akun'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tombol Akhiri Sesi Tamu
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            if (activeProfile != null) {
                              await ref.read(profileControllerProvider.notifier).endGuestSession(activeProfile.id);
                            }
                            if (context.mounted) context.go(RoutePaths.auth);
                          },
                          icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                          label: Text(
                            'Keluar Mode Tamu',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Sesi Akun Terdaftar (Authenticated User)
                ListTile(
                  title: Text(activeProfile.displayName, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Akun Terdaftar (${activeProfile.email ?? "-"})',
                    style: AppTextStyles.captionSmall.copyWith(color: AppColors.success),
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(Icons.verified_user_rounded, color: AppColors.primary),
                  ),
                  trailing: TextButton.icon(
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).signOut();
                      await ref.read(profileControllerProvider.notifier).loadProfiles();
                      if (context.mounted) context.go(RoutePaths.auth);
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.error),
                    label: Text(
                      'Keluar',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  title: Text('Hapus Profil Ini', style: AppTextStyles.labelMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                  subtitle: Text('Semua riwayat latihan profil ini akan dihapus secara permanen', style: AppTextStyles.captionSmall),
                  trailing: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                  onTap: () => _confirmDeleteProfile(context, ref, activeProfile.id),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── CATEGORY 3: APP SYSTEM SETTINGS ─────────────────────────
        _buildSectionHeader('Sistem Aplikasi'),
        const SizedBox(height: 8),
        if (app != null) ...[
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderRadiusXxl,
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: AppShadows.softCard,
            ),
            child: SwitchListTile(
              title: Text('Mode Offline-First', style: AppTextStyles.labelLarge),
              subtitle: Text('Mencegah sync otomatis dengan cloud database', style: AppTextStyles.captionSmall),
              value: app.isOfflineMode,
              activeTrackColor: AppColors.primary,
              onChanged: (val) {
                ref.read(settingsControllerProvider.notifier).updateAppSettings(
                      app.copyWith(isOfflineMode: val),
                    );
              },
            ),
          ),
        ],
        const SizedBox(height: 24),

        // ── CATEGORY 4: DEVELOPER MENU ──────────────────────────────
        _buildSectionHeader('Menu Pengembang'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderRadiusXxl,
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: AppShadows.softCard,
          ),
          child: Column(
            children: [
              ListTile(
                title: Text('Design System Component Gallery', style: AppTextStyles.labelLarge),
                subtitle: Text('Komponen galeri dan token visual', style: AppTextStyles.captionSmall),
                leading: const Icon(Icons.palette_rounded, color: AppColors.primary),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                onTap: () => context.pushNamed(RouteNames.componentGallery),
              ),
              const Divider(height: 1, color: AppColors.border),
              ListTile(
                title: Text('Adaptive Training Engine Debugger', style: AppTextStyles.labelLarge),
                subtitle: Text('Dashboard metriks dan evaluasi validator pose', style: AppTextStyles.captionSmall),
                leading: const Icon(Icons.bug_report_rounded, color: AppColors.skyBlue),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                onTap: () => context.pushNamed(RouteNames.adaptiveDebug),
              ),
              const Divider(height: 1, color: AppColors.border),
              ListTile(
                title: Text('AI Validation & Calibration', style: AppTextStyles.labelLarge),
                subtitle: Text('Penyelarasan visual sensor pose AI', style: AppTextStyles.captionSmall),
                leading: const Icon(Icons.speed_rounded, color: AppColors.mint),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                onTap: () => context.pushNamed(RouteNames.aiValidation),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, UserPreference pref) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pilih Tema Tampilan', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.light_mode_rounded, color: AppColors.primary),
                  title: const Text('Light Mode (Terang)'),
                  trailing: pref.themeMode == 'light' ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                  onTap: () {
                    ref.read(settingsControllerProvider.notifier).updatePreferences(
                          pref.copyWith(themeMode: 'light'),
                        );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_rounded, color: AppColors.textSecondary),
                  title: const Text('Dark Mode (Gelap)'),
                  trailing: pref.themeMode == 'dark' ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                  onTap: () {
                    ref.read(settingsControllerProvider.notifier).updatePreferences(
                          pref.copyWith(themeMode: 'dark'),
                        );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_suggest_rounded, color: AppColors.textSecondary),
                  title: const Text('Ikuti Sistem'),
                  trailing: pref.themeMode == 'system' ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                  onTap: () {
                    ref.read(settingsControllerProvider.notifier).updatePreferences(
                          pref.copyWith(themeMode: 'system'),
                        );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTimePicker(BuildContext context, WidgetRef ref, UserPreference pref) async {
    final parts = pref.dailyReminderTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );

    final selected = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selected != null) {
      final hour = selected.hour.toString().padLeft(2, '0');
      final min = selected.minute.toString().padLeft(2, '0');
      ref.read(settingsControllerProvider.notifier).updatePreferences(
            pref.copyWith(dailyReminderTime: '$hour:$min'),
          );
    }
  }

  void _confirmDeleteProfile(BuildContext context, WidgetRef ref, int profileId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
          backgroundColor: AppColors.surface,
          title: Text('Hapus Profil Ini?', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          content: Text(
            'Profil dan riwayat latihan terkait akan dihapus secara permanen.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(profileControllerProvider.notifier).deleteProfile(profileId);
                if (context.mounted) {
                  Navigator.pop(context);
                  context.go(RoutePaths.auth);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
