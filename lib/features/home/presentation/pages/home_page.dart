import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../analytics/presentation/controller/analytics_dashboard_controller.dart';
import '../../../analytics/services/analytics_engine.dart';
import '../../../gamification/presentation/controllers/gamification_controller.dart';
import '../../../user/presentation/controllers/profile_controller.dart';

/// Halaman Beranda (HomePage) aplikasi GERAKIN (Sesuai DESIGN.md).
///
/// Personality: Bright, Friendly, Inclusive, Cheerful, Modern, Premium.
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.accessible_forward_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            Gap(AppSpacing.sm),
            Text(
              'GerakIn',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          // ── Streak Harian Chip Header ─────────────────────────────
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7), // Warm yellow tint
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$currentStreak Hari',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: const Color(0xFFD97706),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B)),
            tooltip: 'Gamifikasi & Pencapaian',
            onPressed: () => context.pushNamed(RouteNames.gamification),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textSecondary),
            tooltip: 'Pengaturan',
            onPressed: () => context.pushNamed(RouteNames.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
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
              padding: AppSpacing.paddingAllXl,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7C5CFC), // Primary Purple
                    Color(0xFF5EC8FF), // Sky Blue Accent Gradient
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.borderRadiusXxl, // 24px radius
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'FITNES ADAPTIF AI',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFACC15), // Warning/Amber
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              'Streak: $currentStreak Hari',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: const Color(0xFF713F12),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(AppSpacing.md),
                  Text(
                    'Semangat Berlatih! 👋',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(AppSpacing.xs),
                  Text(
                    'Pertahankan kebiasaan sehatmu. Latihan 10 menit hari ini untuk menjaga mobilitas & kekuatan otot tubuh bagian atas.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.4,
                    ),
                  ),
                  Gap(AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () => context.pushNamed(RouteNames.workout),
                    icon: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 24),
                    label: Text(
                      'Mulai Latihan Sekarang',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusXxl,
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.xl),

            // 2. DASHBOARD PROGRES ANALITIK HARI INI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktivitas Hari Ini',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.pushNamed(RouteNames.progress),
                  icon: const Icon(Icons.analytics_rounded, size: 16, color: AppColors.primary),
                  label: Text(
                    'Lihat Progres',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    color: AppColors.skyBlue,
                  ),
                ),
                Gap(AppSpacing.sm),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Kalori',
                    value: '${todayCalories.toStringAsFixed(0)} kcal',
                    icon: Icons.local_fire_department_outlined,
                    color: const Color(0xFFF97316),
                  ),
                ),
                Gap(AppSpacing.sm),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Repetisi',
                    value: '$todayReps kali',
                    icon: Icons.fitness_center_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            Gap(AppSpacing.lg),

            // 3. KARTU RINGKASAN REHABILITASI & ROM
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ringkasan Rentang Gerak (ROM)',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 18),
                      ),
                    ],
                  ),
                  Gap(AppSpacing.xs),
                  Text(
                    'Evaluasi perkembangan fleksibilitas bahu & rentang gerak sendi.',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textSecondary,
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
                      Container(width: 1, height: 32, color: AppColors.border),
                      _buildStatColumn(
                        'Akurasi Pose',
                        '${accuracyTrend.isEmpty ? 92.0 : accuracyTrend.last.toStringAsFixed(0)}%',
                        AppColors.skyBlue,
                      ),
                      Container(width: 1, height: 32, color: AppColors.border),
                      _buildStatColumn(
                        'Status Mobilitas',
                        'Optimal',
                        AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.xl),
            Text(
              'Akses Cepat',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(AppSpacing.sm),

            // 4. Card Hub Fisioterapis & Caregiver
            SectionCard(
              onTap: () => context.pushNamed(RouteNames.collaboration),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.secondary.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 24),
                  ),
                  Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hub Fisioterapis & Caregiver',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Gap(2),
                        Text(
                          'Preskripsi latihan & catatan perkembangan',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
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
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusXxl,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Gap(AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
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
        Gap(2),
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
