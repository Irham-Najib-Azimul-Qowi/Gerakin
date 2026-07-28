import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/workout_card.dart';

/// Halaman Workout dengan Akses Pustaka Latihan Rehabilitasi Kursi Roda & AI Camera.
class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan & Rehabilitasi'),
      ),
      body: ListView(
        padding: AppSpacing.paddingPage,
        children: [
          // 1. Banner Utama Akses Katalog Latihan Rehabilitasi Kursi Roda
          Container(
            padding: AppSpacing.paddingAllLg,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00796B), Color(0xFF004D40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.accessible_forward_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    Gap(AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Katalog Latihan Kursi Roda',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(AppSpacing.xs),
                Text(
                  'Akses 50+ database latihan rehabilitasi adaptif khusus pengguna kursi roda (Warm Up, ROM, Strengths, Core, & Rehab)',
                  style: AppTextStyles.bodySmall.copyWith(
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

          // 2. Banner AI Camera Pose Detection Realtime
          Container(
            padding: AppSpacing.paddingAllLg,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.camera_front_rounded,
                      color: AppColors.primaryDark,
                      size: 28,
                    ),
                    Gap(AppSpacing.sm),
                    Text(
                      'AI Camera Realtime Tracking',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Gap(AppSpacing.xs),
                Text(
                  'Mulai latihan mandiri dengan AI Pose Detection & Sleek White AR Skeleton Overlay',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                Gap(AppSpacing.lg),
                AppButton(
                  label: 'Buka AI Camera Tracker',
                  icon: Icons.linked_camera_rounded,
                  isExpanded: true,
                  onPressed: () => context.pushNamed(RouteNames.camera),
                ),
              ],
            ),
          ),

          Gap(AppSpacing.xxl),
          Text('Program Latihan Rehabilitasi Pilihan', style: AppTextStyles.titleMedium),
          Gap(AppSpacing.md),
          WorkoutCard(
            title: 'Putaran Lengan Duduk (Warm Up)',
            duration: '5 min',
            calories: '25 kcal',
            level: 'Beginner',
            icon: Icons.accessible_rounded,
            onTap: () => context.pushNamed(RouteNames.exerciseLibrary),
          ),
          Gap(AppSpacing.sm),
          WorkoutCard(
            title: 'Fleksi Bahu Duduk (ROM)',
            duration: '10 min',
            calories: '45 kcal',
            level: 'Beginner',
            icon: Icons.accessibility_new_rounded,
            iconColor: AppColors.secondary,
            onTap: () => context.pushNamed(RouteNames.exerciseLibrary),
          ),
          Gap(AppSpacing.sm),
          WorkoutCard(
            title: 'Wheelchair Arm Press (Strength)',
            duration: '15 min',
            calories: '85 kcal',
            level: 'Intermediate',
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.tertiary,
            onTap: () => context.pushNamed(RouteNames.exerciseLibrary),
          ),
        ],
      ),
    );
  }
}
