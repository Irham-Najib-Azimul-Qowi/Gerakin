import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/workout_card.dart';
import '../../../exercise/domain/exercise_type.dart';

/// Halaman Program / Workout GERAKIN (Sesuai DESIGN.md).
///
/// Akses Pustaka Latihan Adaptif Kursi Roda berbasis AI Pose Detection.
class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Program Latihan',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: AppSpacing.paddingPage,
        children: [
          // 1. Banner Utama Akses Katalog Latihan Rehabilitasi Kursi Roda
          Container(
            padding: AppSpacing.paddingAllXl,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.borderRadiusXxl, // 24px radius
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.accessible_forward_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
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
                Gap(AppSpacing.sm),
                Text(
                  'Latihan rehabilitasi & kebugaran adaptif dengan panduan visual AI dan koreksi pose real-time.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.4,
                  ),
                ),
                Gap(AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () => context.pushNamed(
                    RouteNames.exerciseEducation,
                    extra: ExerciseType.sideArmRaise,
                  ),
                  icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 22),
                  label: Text(
                    'Buka Seated Side Arm Raise',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latihan Unggulan',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.pushNamed(RouteNames.exerciseLibrary),
                child: Text(
                  'Lihat Semua',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Gap(AppSpacing.sm),
          WorkoutCard(
            title: '1. Seated Side Arm Raise',
            duration: '5 menit',
            calories: '12 kcal',
            level: 'Beginner',
            icon: Icons.accessible_rounded,
            iconColor: AppColors.primary,
            onTap: () => context.pushNamed(
              RouteNames.exerciseEducation,
              extra: ExerciseType.sideArmRaise,
            ),
          ),
          Gap(AppSpacing.md),
          WorkoutCard(
            title: '2. Seated Bicep Curl',
            duration: '10 menit',
            calories: '18 kcal',
            level: 'Intermediate',
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.secondary,
            onTap: () => context.pushNamed(
              RouteNames.exerciseEducation,
              extra: ExerciseType.bicepCurl,
            ),
          ),
          Gap(AppSpacing.md),
          WorkoutCard(
            title: '3. Seated Neck Rotation',
            duration: '12 menit',
            calories: '22 kcal',
            level: 'Beginner',
            icon: Icons.accessibility_new_rounded,
            iconColor: AppColors.tertiary,
            onTap: () => context.pushNamed(
              RouteNames.exerciseEducation,
              extra: ExerciseType.neckRotation,
            ),
          ),
        ],
      ),
    );
  }
}
