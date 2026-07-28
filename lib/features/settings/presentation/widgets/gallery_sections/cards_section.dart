import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/cards/achievement_card.dart';
import '../../../../../shared/widgets/cards/progress_card.dart';
import '../../../../../shared/widgets/cards/section_card.dart';
import '../../../../../shared/widgets/cards/statistic_card.dart';
import '../../../../../shared/widgets/cards/workout_card.dart';

/// Section cards di Component Gallery.
class CardsSection extends StatelessWidget {
  const CardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cards', style: AppTextStyles.headlineSmall),
        Gap(AppSpacing.lg),

        // Section Card
        Text('Section Card', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        SectionCard(
          child: Text(
            'Ini adalah Section Card dasar yang bisa digunakan '
            'sebagai container untuk konten apa pun.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Gap(AppSpacing.xxl),

        // Workout Card
        Text('Workout Card', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        WorkoutCard(
          title: 'Push Up Challenge',
          duration: '15 min',
          calories: '120 kcal',
          level: 'Beginner',
        ),
        Gap(AppSpacing.sm),
        WorkoutCard(
          title: 'HIIT Cardio Blast',
          duration: '30 min',
          calories: '350 kcal',
          level: 'Intermediate',
          icon: Icons.directions_run_rounded,
          iconColor: AppColors.tertiary,
        ),
        Gap(AppSpacing.sm),
        WorkoutCard(
          title: 'Advanced Plank Hold',
          duration: '10 min',
          calories: '80 kcal',
          level: 'Advanced',
          icon: Icons.self_improvement_rounded,
          iconColor: AppColors.secondary,
        ),
        Gap(AppSpacing.xxl),

        // Progress Card
        Text('Progress Card', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        ProgressCard(
          title: 'Target Harian',
          value: '7.500 / 10.000',
          subtitle: 'langkah',
          progress: 0.75,
        ),
        Gap(AppSpacing.sm),
        ProgressCard(
          title: 'Kalori Terbakar',
          value: '450 kcal',
          subtitle: 'dari target 600 kcal',
          progress: 0.75,
          color: AppColors.tertiary,
          useCircular: true,
        ),
        Gap(AppSpacing.xxl),

        // Statistic Card
        Text('Statistic Card', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatisticCard(
                label: 'Workout',
                value: '24',
                icon: Icons.fitness_center_rounded,
                trend: TrendDirection.up,
                trendValue: '+12%',
              ),
            ),
            Gap(AppSpacing.md),
            Expanded(
              child: StatisticCard(
                label: 'Kalori',
                value: '1.8k',
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.tertiary,
                trend: TrendDirection.down,
                trendValue: '-5%',
              ),
            ),
          ],
        ),
        Gap(AppSpacing.xxl),

        // Achievement Card
        Text('Achievement Card', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        AchievementCard(
          title: 'Warrior Pagi',
          description: 'Selesaikan 7 workout sebelum jam 8 pagi',
          isUnlocked: true,
        ),
        Gap(AppSpacing.sm),
        AchievementCard(
          title: 'Marathon Runner',
          description: 'Lari total 42 km dalam sebulan',
          icon: Icons.directions_run_rounded,
          isUnlocked: false,
        ),
      ],
    );
  }
}
