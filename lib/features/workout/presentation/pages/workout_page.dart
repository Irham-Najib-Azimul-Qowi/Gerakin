import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/workout_card.dart';
import '../../../exercise/domain/exercise_type.dart';

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
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
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
                  'Akses 3 latihan rehabilitasi adaptif berbasis AI Pose Detection & Guide Overlay Transparan.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Gap(AppSpacing.lg),
                AppButton(
                  label: 'Buka Seated Side Arm Raise',
                  icon: Icons.play_circle_fill_rounded,
                  isExpanded: true,
                  onPressed: () => context.pushNamed(
                    RouteNames.interactiveExercise,
                    extra: ExerciseType.sideArmRaise,
                  ),
                ),
              ],
            ),
          ),

          Gap(AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('3 Latihan Rehabilitasi Utama', style: AppTextStyles.titleMedium),
              TextButton(
                onPressed: () => context.pushNamed(RouteNames.exerciseLibrary),
                child: const Text('Lihat Katalog'),
              ),
            ],
          ),
          Gap(AppSpacing.sm),
          WorkoutCard(
            title: '1. Seated Side Arm Raise',
            duration: '5 min',
            calories: '12 kcal',
            level: 'Level 1',
            icon: Icons.accessible_rounded,
            onTap: () => context.pushNamed(
              RouteNames.interactiveExercise,
              extra: ExerciseType.sideArmRaise,
            ),
          ),
          Gap(AppSpacing.sm),
          WorkoutCard(
            title: '2. Seated Bicep Curl',
            duration: '10 min',
            calories: '18 kcal',
            level: 'Level 2',
            icon: Icons.accessibility_new_rounded,
            iconColor: AppColors.secondary,
            onTap: () => context.pushNamed(
              RouteNames.interactiveExercise,
              extra: ExerciseType.bicepCurl,
            ),
          ),
          Gap(AppSpacing.sm),
          WorkoutCard(
            title: '3. Seated Neck Rotation',
            duration: '12 min',
            calories: '22 kcal',
            level: 'Level 2',
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.tertiary,
            onTap: () => context.pushNamed(
              RouteNames.interactiveExercise,
              extra: ExerciseType.neckRotation,
            ),
          ),
        ],
      ),
    );
  }
}
