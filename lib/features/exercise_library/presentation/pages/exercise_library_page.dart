import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../domain/exercise_library_controller.dart';
import '../../models/full_exercise_definition.dart';

/// Halaman Katalog Latihan ECMS (Exercise Library Page).
class ExerciseLibraryPage extends ConsumerWidget {
  const ExerciseLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exerciseLibraryProvider);
    final controller = ref.read(exerciseLibraryProvider.notifier);

    final categories = [
      'All',
      'Warm Up',
      'Range Of Motion (ROM)',
      'Strength Training',
      'Coordination',
      'Flexibility',
      'Core Stability',
      'Balance (Sitting Balance)',
      'Shoulder Rehabilitation',
      'Elbow Rehabilitation',
      'Wrist Rehabilitation',
      'Daily Functional Movement',
      'Cool Down',
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      appBar: AppBar(
        title: Text(
          'Katalog Latihan Adaptif',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.onSurfaceDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surfaceContainerDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Search Bar & Filter Header
          Container(
            padding: AppSpacing.paddingPage,
            color: AppColors.surfaceContainerDark,
            child: Column(
              children: [
                AppTextField(
                  hint: 'Cari latihan (misal: arm raise, bahu, cardio)...',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => controller.search(val),
                ),
                Gap(AppSpacing.md),
                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = state.selectedCategory == cat;
                      return Padding(
                        padding: EdgeInsets.only(right: AppSpacing.xs),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(cat),
                          labelStyle: AppTextStyles.labelMedium.copyWith(
                            color: isSelected
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariantDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceVariantDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          onSelected: (_) => controller.selectCategory(cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Content Grid / List
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : state.filteredExercises.isEmpty
                    ? _EmptySearchState(query: state.searchQuery)
                    : ListView.builder(
                        padding: AppSpacing.paddingPage,
                        itemCount: state.filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = state.filteredExercises[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.md),
                            child: _ExerciseCard(
                              exercise: exercise,
                              onTap: () {
                                context.pushNamed(
                                  RouteNames.exerciseDetail,
                                  extra: exercise,
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  final FullExerciseDefinition exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: AppColors.surfaceContainerDark,
      onTap: onTap,
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: Text(
                        exercise.category.toUpperCase(),
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.secondaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    Gap(AppSpacing.xs),
                    Text(
                      '• Level ${exercise.difficulty}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Gap(AppSpacing.xxs),
                Text(
                  exercise.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurfaceDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gap(AppSpacing.xxs),
                Text(
                  exercise.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariantDark,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.onSurfaceVariantDark,
          ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.onSurfaceVariantDark,
            ),
            Gap(AppSpacing.md),
            Text(
              'Tidak ada latihan ditemukan',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurfaceDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(AppSpacing.xs),
            Text(
              query.isNotEmpty
                  ? 'Tidak ada hasil untuk "$query"'
                  : 'Coba ubah filter atau kata kunci pencarian Anda.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariantDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
