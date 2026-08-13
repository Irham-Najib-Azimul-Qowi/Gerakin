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
import '../../../workout_engine/domain/workout_controller.dart';
import '../../models/full_exercise_definition.dart';
import '../widgets/illustration_image_widget.dart';

/// Halaman Preview Detail Latihan ECMS.
class ExerciseDetailPreviewPage extends ConsumerWidget {
  const ExerciseDetailPreviewPage({
    super.key,
    required this.exercise,
  });

  final FullExerciseDefinition exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      appBar: AppBar(
        title: Text(
          exercise.name,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.onSurfaceDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surfaceContainerDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingPage,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Header
            Container(
              padding: AppSpacing.paddingAllLg,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                  ],
                ),
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        backgroundColor: AppColors.onPrimary.withValues(alpha: 0.2),
                        label: Text(
                          exercise.category,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Level ${exercise.difficulty}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Gap(AppSpacing.sm),
                  Text(
                    exercise.name,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(AppSpacing.xs),
                  Text(
                    exercise.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.lg),

            // 0. Ilustrasi Gerakan (3 Tahap Anatomis)
            SectionCard(
              color: AppColors.surfaceContainerDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ilustrasi Tahapan Gerakan',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurfaceDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(AppSpacing.xs),
                  Text(
                    'Urutan visual 3 posisi: Awal, Puncak Tahan, dan Akhir.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariantDark,
                    ),
                  ),
                  Gap(AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            IllustrationImageWidget(
                              assetPath: exercise.illustrationAssets != null && exercise.illustrationAssets!.isNotEmpty
                                  ? exercise.illustrationAssets![0]
                                  : exercise.thumbnailAsset,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Gap(AppSpacing.xs),
                            Text(
                              '1. Awal',
                              style: AppTextStyles.captionMedium.copyWith(
                                color: AppColors.onSurfaceDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(AppSpacing.xs),
                      Expanded(
                        child: Column(
                          children: [
                            IllustrationImageWidget(
                              assetPath: exercise.illustrationAssets != null && exercise.illustrationAssets!.length > 1
                                  ? exercise.illustrationAssets![1]
                                  : exercise.thumbnailAsset,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Gap(AppSpacing.xs),
                            Text(
                              '2. Puncak',
                              style: AppTextStyles.captionMedium.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(AppSpacing.xs),
                      Expanded(
                        child: Column(
                          children: [
                            IllustrationImageWidget(
                              assetPath: exercise.illustrationAssets != null && exercise.illustrationAssets!.length > 2
                                  ? exercise.illustrationAssets![2]
                                  : exercise.thumbnailAsset,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Gap(AppSpacing.xs),
                            Text(
                              '3. Akhir',
                              style: AppTextStyles.captionMedium.copyWith(
                                color: AppColors.onSurfaceDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.lg),

            // 1. Manfaat & Otot Target Card
            SectionCard(
              color: AppColors.surfaceContainerDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manfaat & Otot Target',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurfaceDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(AppSpacing.xs),
                  Text(
                    exercise.benefit,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariantDark,
                    ),
                  ),
                  Gap(AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: exercise.targetMuscles.map((muscle) {
                      return Chip(
                        backgroundColor: AppColors.surfaceVariantDark,
                        side: const BorderSide(color: AppColors.primary),
                        label: Text(
                          muscle,
                          style: AppTextStyles.captionMedium.copyWith(
                            color: AppColors.primaryLight,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.lg),

            // 2. Pose & Target Angles Card
            SectionCard(
              color: AppColors.surfaceContainerDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panduan Pose & Sudut Target',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurfaceDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(AppSpacing.md),
                  _DetailRow(
                    label: 'Posisi Awal (Start Pose)',
                    value: exercise.startPose,
                  ),
                  _DetailRow(
                    label: 'Posisi Puncak (End Pose)',
                    value: exercise.endPose,
                  ),
                  _DetailRow(
                    label: 'Sendi Utama',
                    value: exercise.targetAngles.primaryJoint.name,
                  ),
                  _DetailRow(
                    label: 'Kisaran Sudut Target',
                    value:
                        '${exercise.targetAngles.startAngle.toInt()}° ➔ ${exercise.targetAngles.targetAngle.toInt()}° (Toleransi ±${exercise.tolerance.toInt()}°)',
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.lg),

            // 3. Dosis & Dosis Latihan (Reps, Sets, Rest, Calories)
            SectionCard(
              color: AppColors.surfaceContainerDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dosis Latihan',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurfaceDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatBadge(
                        label: 'Repetisi',
                        value: '${exercise.repetitionTarget} rep',
                      ),
                      _StatBadge(
                        label: 'Set',
                        value: '${exercise.setTarget} set',
                      ),
                      _StatBadge(
                        label: 'Istirahat',
                        value: '${exercise.restDuration} detik',
                      ),
                      _StatBadge(
                        label: 'Kalori',
                        value: '${exercise.estimatedCalories.toInt()} kcal',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.lg),

            // 4. Petunjuk Suara & Peringatan
            SectionCard(
              color: AppColors.surfaceContainerDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Petunjuk Suara & Keselamatan',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurfaceDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.record_voice_over_rounded,
                          color: AppColors.primary),
                      Gap(AppSpacing.sm),
                      Expanded(
                        child: Text(
                          exercise.voiceInstruction,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurfaceDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppColors.warning),
                      Gap(AppSpacing.sm),
                      Expanded(
                        child: Text(
                          exercise.warning,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.xxl),

            // Button Start Workout
            AppButton(
              label: 'Mulai Latihan Sekarang',
              icon: Icons.play_arrow_rounded,
              isExpanded: true,
              onPressed: () {
                final workoutDef = exercise.toWorkoutExerciseDefinition();
                ref.read(workoutControllerProvider.notifier).startWorkout(workoutDef);
                context.pushNamed(RouteNames.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.onSurfaceVariantDark,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.onSurfaceVariantDark,
          ),
        ),
      ],
    );
  }
}
