import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../analytics/presentation/controller/analytics_dashboard_controller.dart';
import '../../../analytics/services/analytics_engine.dart';
import '../../../gamification/presentation/controllers/gamification_controller.dart';
import '../../../user/presentation/controllers/profile_controller.dart';

/// Halaman Beranda (HomePage) aplikasi GERAKIN.
///
/// Menyajikan Dashboard Utama, Ringkasan Progres Analitik, & Widget Streak Harian.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsDashboardControllerProvider);
    final gamificationState = ref.watch(gamificationControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    final currentStreak = gamificationState.streak?.currentStreak ?? 1;
    final activeProfile = profileState.activeProfile;

    // Hitung metrik hari ini
    final now = DateTime.now();
    final todaySessions = analyticsState.sessions.where((s) =>
        s.startTime.year == now.year &&
        s.startTime.month == now.month &&
        s.startTime.day == now.day).toList();

    final double todayDuration = todaySessions.fold(0.0, (sum, s) => sum + s.durationInSeconds) / 60.0;
    final double todayCalories = todaySessions.fold(0.0, (sum, s) => sum + s.caloriesBurned);
    final int todayReps = todaySessions.fold(0, (sum, s) => sum + s.completedReps);

    final analyticsEngine = AnalyticsEngine();
    final romTrend = analyticsEngine.getRomTrend(analyticsState.sessions);
    final accuracyTrend = analyticsEngine.getAccuracyTrend(analyticsState.sessions);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.accessible_forward_rounded, color: AppColors.primary),
            Gap(AppSpacing.xs),
            Text(
              'GerakIn',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          // ── Streak Harian Chip Header ─────────────────────────────
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$currentStreak Hari',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.stars_rounded, color: Colors.amber),
            tooltip: 'Gamifikasi & Achievements',
            onPressed: () => context.pushNamed(RouteNames.gamification),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Pengaturan',
            onPressed: () => context.pushNamed(RouteNames.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(analyticsDashboardControllerProvider.notifier).refresh();
          if (activeProfile != null) {
            ref.read(gamificationControllerProvider.notifier).loadGamificationData(activeProfile.id);
          }
        },
        child: ListView(
          padding: AppSpacing.paddingPage,
          children: [
            // 1. Hero Card - Poin Utama & Streak Harian
            Container(
              padding: AppSpacing.paddingAllLg,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.onPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'DASHBOARD REHABILITASI ADAPTIF',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              'Streak: $currentStreak Hari',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(AppSpacing.sm),
                  Text(
                    'Selamat Datang Kembali! 👋',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(AppSpacing.xs),
                  Text(
                    'Pertahankan streak harian latihanmu! Lakukan latihan adaptif 10 menit untuk menjaga mobilitas & vitalitas tubuh.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  Gap(AppSpacing.lg),
                  AppButton(
                    label: 'Mulai Latihan Sekarang (3 Latihan)',
                    icon: Icons.play_arrow_rounded,
                    isExpanded: true,
                    onPressed: () => context.pushNamed(RouteNames.workout),
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.xl),

            // 2. DASHBOARD PROGRES ANALITIK HARI INI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progres & Aktivitas Hari Ini', style: AppTextStyles.titleMedium),
                TextButton.icon(
                  onPressed: () => context.pushNamed(RouteNames.progress),
                  icon: const Icon(Icons.analytics_rounded, size: 16),
                  label: const Text('Detail Progres'),
                ),
              ],
            ),
            Gap(AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Menit Aktif',
                    value: '${todayDuration.toStringAsFixed(1)} m',
                    icon: Icons.timer_outlined,
                    color: Colors.blue,
                  ),
                ),
                Gap(AppSpacing.sm),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Kalori',
                    value: '${todayCalories.toStringAsFixed(0)} kcal',
                    icon: Icons.local_fire_department_outlined,
                    color: Colors.orange,
                  ),
                ),
                Gap(AppSpacing.sm),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Repetisi',
                    value: '$todayReps kali',
                    icon: Icons.fitness_center_outlined,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),

            Gap(AppSpacing.lg),

            // 3. KARTU RINGKASAN REHABILITASI & ROM
            SectionCard(
              color: AppColors.surfaceContainerLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ringkasan Biomekanik & ROM',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.show_chart_rounded, color: AppColors.primary),
                    ],
                  ),
                  Gap(AppSpacing.xs),
                  Text(
                    'Evaluasi perkembangan rentang gerak sendi & kestabilan pose.',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  Gap(AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        'Rata-rata ROM',
                        '${romTrend.isEmpty ? 85.0 : romTrend.last.toStringAsFixed(0)}°',
                        AppColors.primary,
                      ),
                      _buildStatColumn(
                        'Akurasi Pose',
                        '${accuracyTrend.isEmpty ? 92.0 : accuracyTrend.last.toStringAsFixed(0)}%',
                        AppColors.secondary,
                      ),
                      _buildStatColumn(
                        'Status Pemulihan',
                        'Optimal',
                        AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.xl),
            Text('Akses Cepat Fitur', style: AppTextStyles.titleMedium),
            Gap(AppSpacing.md),

            // 5. Card Dashboard Fisioterapis & Caregiver
            SectionCard(
              onTap: () => context.pushNamed(RouteNames.collaboration),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medical_services_rounded, color: Colors.purple, size: 28),
                  ),
                  Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hub Fisioterapis & Caregiver', style: AppTextStyles.titleMedium),
                        Text('Preskripsi latihan & rekam medis pasien', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.paddingAllMd,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          Gap(AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}
