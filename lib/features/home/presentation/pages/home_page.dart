import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';

/// Halaman Beranda (HomePage) aplikasi GERAKIN dengan Dashboard Rehabilitasi Adaptif.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.accessible_forward_rounded, color: AppColors.primary),
            Gap(AppSpacing.xs),
            Text(
              'GERAKIN',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
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
      body: ListView(
        padding: AppSpacing.paddingPage,
        children: [
          // 1. Hero Card - Akses Utama Katalog Latihan Rehabilitasi Kursi Roda
          Container(
            padding: AppSpacing.paddingAllLg,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004D40), Color(0xFF00796B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'WHEELCHAIR REHABILITATION KNOWLEDGE BASE',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Gap(AppSpacing.sm),
                Text(
                  '50+ Pustaka Latihan Rehabilitasi Kursi Roda',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gap(AppSpacing.xs),
                Text(
                  'Latihan adaptif untuk pengguna kursi roda manual & elektrik (Warm Up, ROM, Strengths, Core, Balance & Rehab).',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Gap(AppSpacing.lg),
                AppButton(
                  label: 'Buka Katalog Latihan (50+ Latihan)',
                  icon: Icons.grid_view_rounded,
                  isExpanded: true,
                  onPressed: () => context.pushNamed(RouteNames.exerciseLibrary),
                ),
              ],
            ),
          ),

          Gap(AppSpacing.xl),
          Text('Akses Cepat Fitur', style: AppTextStyles.titleMedium),
          Gap(AppSpacing.md),

          // 2. Card AI Camera Realtime
          SectionCard(
            onTap: () => context.pushNamed(RouteNames.camera),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_front_rounded, color: AppColors.primary, size: 28),
                ),
                Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Camera Pose Detection', style: AppTextStyles.titleMedium),
                      Text('Sleek White AR Overlay Tracking', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          Gap(AppSpacing.sm),

          // 3. Card Dashboard Fisioterapis & Caregiver
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
          Gap(AppSpacing.sm),

          // 4. Card Gamifikasi
          SectionCard(
            onTap: () => context.pushNamed(RouteNames.gamification),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
                ),
                Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gamification & XP Streaks', style: AppTextStyles.titleMedium),
                      Text('Level progression & daily challenges', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
