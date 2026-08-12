import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../sync/presentation/widgets/sync_status_indicator.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/settings_controller.dart';
import '../../models/user_preference.dart';

/// Halaman Pengaturan Aplikasi terintegrasi dengan preferensi profil dan sesi.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final settingsState = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Sesi', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: settingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
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
        _buildSectionHeader('Preferensi Latihan'),
        const SizedBox(height: 8),
        if (pref != null) ...[
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Petunjuk Suara (Audio Cues)'),
                  subtitle: const Text('Mengeluarkan suara saat pergantian repetisi'),
                  value: pref.enableAudioCues,
                  onChanged: (val) {
                    ref.read(settingsControllerProvider.notifier).updatePreferences(
                          pref.copyWith(enableAudioCues: val),
                        );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Text-to-Speech (TTS)'),
                  subtitle: const Text('Membacakan deskripsi gerakan secara otomatis'),
                  value: pref.enableTts,
                  onChanged: (val) {
                    ref.read(settingsControllerProvider.notifier).updatePreferences(
                          pref.copyWith(enableTts: val),
                        );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Tema Tampilan'),
                  subtitle: Text('Tema aktif: ${pref.themeMode.toUpperCase()}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showThemePicker(context, ref, pref),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Pengingat Latihan Harian'),
                  subtitle: Text('Pengingat pada jam: ${pref.dailyReminderTime}'),
                  trailing: const Icon(Icons.access_time_rounded),
                  onTap: () => _showTimePicker(context, ref, pref),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),

        // ── CATEGORY 2: SESSION MANAGEMENT ──────────────────────────
        _buildSectionHeader('Manajemen Sesi Profil'),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
          ),
          child: Column(
            children: [
              if (activeProfile == null) ...[
                ListTile(
                  title: const Text('Belum Ada Sesi Aktif'),
                  subtitle: const Text('Masuk dengan akun atau gunakan mode tamu'),
                  leading: const Icon(Icons.account_circle_outlined, color: Colors.grey),
                  trailing: TextButton.icon(
                    onPressed: () => context.go(RoutePaths.auth),
                    icon: const Icon(Icons.login_rounded, size: 16),
                    label: const Text('Masuk / Daftar'),
                  ),
                ),
              ] else ...[
                ListTile(
                  title: Text(activeProfile.displayName),
                  subtitle: Text(activeProfile.isGuest
                      ? 'Sesi Tamu Aktif'
                      : 'Profil Terdaftar (${activeProfile.email ?? "-"})'),
                  leading: Icon(
                    activeProfile.isGuest ? Icons.person_outline_rounded : Icons.verified_user_outlined,
                    color: activeProfile.isGuest ? Colors.grey : Colors.green,
                  ),
                  trailing: activeProfile.isGuest
                      ? TextButton.icon(
                          onPressed: () async {
                            await ref
                                .read(profileControllerProvider.notifier)
                                .endGuestSession(activeProfile.id);
                            if (context.mounted) context.go(RoutePaths.auth);
                          },
                          icon: const Icon(Icons.exit_to_app_rounded, size: 16, color: Colors.red),
                          label: const Text('Akhiri Tamu', style: TextStyle(color: Colors.red)),
                        )
                      : TextButton.icon(
                          onPressed: () async {
                            await ref.read(authControllerProvider.notifier).signOut();
                            await ref.read(profileControllerProvider.notifier).loadProfiles();
                            if (context.mounted) context.go(RoutePaths.auth);
                          },
                          icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.red),
                          label: const Text('Keluar (Sign Out)', style: TextStyle(color: Colors.red)),
                        ),
                ),
              ],
              if (activeProfile != null && !activeProfile.isGuest) ...[
                const Divider(height: 1),
                ListTile(
                  title: const Text('Hapus Profil Ini', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Semua riwayat latihan profil ini akan dihapus secara permanen'),
                  trailing: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
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
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mode Offline-First'),
                  subtitle: const Text('Mencegah sync otomatis dengan cloud database'),
                  value: app.isOfflineMode,
                  onChanged: (val) {
                    ref.read(settingsControllerProvider.notifier).updateAppSettings(
                          app.copyWith(isOfflineMode: val),
                        );
                  },
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),

        // ── CATEGORY 4: DEVELOPER MENU ──────────────────────────────
        _buildSectionHeader('Menu Pengembang'),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text('Design System Component Gallery'),
                subtitle: const Text('Komponen galeri dan token visual'),
                leading: const Icon(Icons.palette_rounded),
                onTap: () => context.pushNamed(RouteNames.componentGallery),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Adaptive Training Engine Debugger'),
                subtitle: const Text('Dashboard metriks dan evaluasi validator pose'),
                leading: const Icon(Icons.bug_report_rounded),
                onTap: () => context.pushNamed(RouteNames.adaptiveDebug),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('AI Validation & Calibration'),
                subtitle: const Text('Penyelarasan visual sensor pose AI'),
                leading: const Icon(Icons.speed_rounded),
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
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, UserPreference pref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Terang (Light)'),
                onTap: () {
                  ref.read(settingsControllerProvider.notifier).updatePreferences(
                        pref.copyWith(themeMode: 'light'),
                      );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Gelap (Dark)'),
                onTap: () {
                  ref.read(settingsControllerProvider.notifier).updatePreferences(
                        pref.copyWith(themeMode: 'dark'),
                      );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Sistem'),
                onTap: () {
                  ref.read(settingsControllerProvider.notifier).updatePreferences(
                        pref.copyWith(themeMode: 'system'),
                      );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTimePicker(BuildContext context, WidgetRef ref, UserPreference pref) async {
    final parts = pref.dailyReminderTime.split(':');
    final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final picked = await showTimePicker(
      context: context,
      initialTime: time,
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minStr = picked.minute.toString().padLeft(2, '0');
      ref.read(settingsControllerProvider.notifier).updatePreferences(
            pref.copyWith(dailyReminderTime: '$hourStr:$minStr'),
          );
    }
  }

  void _confirmDeleteProfile(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Profil?'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus profil ini? Semua riwayat latihan profil ini akan dihapus secara permanen.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            TextButton(
              onPressed: () {
                ref.read(profileControllerProvider.notifier).deleteProfile(id);
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
