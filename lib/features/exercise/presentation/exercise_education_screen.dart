import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:gerakin/core/router/route_names.dart';
import 'package:gerakin/core/theme/app_colors.dart';
import 'package:gerakin/core/theme/app_spacing.dart';
import 'package:gerakin/core/theme/app_text_styles.dart';

import '../domain/exercise_config.dart';
import '../domain/exercise_education_config.dart';
import '../domain/exercise_type.dart';
import 'widgets/animated_exercise_tutorial.dart';

/// Halaman Edukasi & Pre-Session Preview Latihan GERAKIN (ExerciseEducationScreen).
///
/// TUJUAN:
/// Memberikan panduan visual 100% opacity, sekuens cara melakukan gerakan,
/// target set & repetisi, serta persiapan posisi kamera sebelum sesi latihan aktif.
class ExerciseEducationScreen extends StatelessWidget {
  const ExerciseEducationScreen({
    super.key,
    required this.exerciseType,
  });

  final ExerciseType exerciseType;

  @override
  Widget build(BuildContext context) {
    final config = ExerciseConfig.forType(exerciseType);
    final eduConfig = ExerciseEducationConfig.forType(exerciseType);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Panduan Latihan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Konten Edukasi yang dapat di-scroll
            Expanded(
              child: ListView(
                padding: AppSpacing.paddingPage,
                children: [
                  // 1. Header Judul Latihan & Kategori
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exerciseType.displayName,
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              exerciseType.category,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: AppColors.primaryDark,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exerciseType.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),

                  Gap(AppSpacing.md),

                  // 2. HERO ANIMATED TUTORIAL DEMONSTRATION (100% Opacity Vivid PNG)
                  AnimatedExerciseTutorial(config: eduConfig),

                  Gap(AppSpacing.lg),

                  // 3. TARGET DOSAGE CARDS (Single Source of Truth dari ExerciseConfig)
                  Row(
                    children: [
                      Expanded(
                        child: _buildDosageCard(
                          context,
                          label: 'TARGET SET',
                          value: '${config.targetSets}',
                          subtext: 'Set Latihan',
                          icon: Icons.repeat_rounded,
                          accentColor: AppColors.secondaryDark,
                        ),
                      ),
                      Gap(AppSpacing.sm),
                      Expanded(
                        child: _buildDosageCard(
                          context,
                          label: 'REPETISI',
                          value: '${config.targetRepsPerSet}',
                          subtext: 'Rep / Set',
                          icon: Icons.fitness_center_rounded,
                          accentColor: AppColors.primaryDark,
                        ),
                      ),
                      Gap(AppSpacing.sm),
                      Expanded(
                        child: _buildDosageCard(
                          context,
                          label: 'ISTIRAHAT',
                          value: '${config.restDurationSeconds}s',
                          subtext: 'Antar Set',
                          icon: Icons.timer_rounded,
                          accentColor: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),

                  Gap(AppSpacing.xl),

                  // 4. POSISI SEBELUM MULAI & PERSIAPAN KAMERA
                  _buildSectionContainer(
                    context,
                    title: 'Posisi Anda & Persiapan Kamera',
                    icon: Icons.camera_front_rounded,
                    iconColor: AppColors.primaryDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: eduConfig.userPostureTips.map((tip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  Gap(AppSpacing.md),

                  // 5. POSISI AWAL
                  _buildSectionContainer(
                    context,
                    title: eduConfig.startingPositionTitle,
                    icon: Icons.airline_seat_recline_normal_rounded,
                    iconColor: AppColors.secondaryDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: eduConfig.startingPositionBullets.map((bullet) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                              Expanded(
                                child: Text(
                                  bullet,
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  Gap(AppSpacing.md),

                  // 6. CARA MELAKUKAN (Langkah Demi Langkah)
                  _buildSectionContainer(
                    context,
                    title: 'Cara Melakukan Latihan',
                    icon: Icons.format_list_numbered_rounded,
                    iconColor: AppColors.primaryDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: eduConfig.stepByStepInstructions.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final stepText = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$index',
                                    style: const TextStyle(
                                      color: AppColors.primaryDark,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  stepText,
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  Gap(AppSpacing.md),

                  // 7. PERHATIKAN (Hal yang Harus Diperhatikan & Diatur)
                  _buildSectionContainer(
                    context,
                    title: 'Perhatikan',
                    icon: Icons.verified_user_rounded,
                    iconColor: const Color(0xFFD97706),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: eduConfig.importantReminders.map((reminder) {
                        final isWarning = reminder.startsWith('!');
                        final color = isWarning ? const Color(0xFFDC2626) : const Color(0xFF008E76);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isWarning ? '⚠️ ' : '✓ ',
                                style: TextStyle(color: color, fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  reminder.replaceAll('✓ ', '').replaceAll('! ', ''),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  Gap(AppSpacing.xxl),
                ],
              ),
            ),

            // 8. STICKY CTA BOTTOM ACTION BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.pushNamed(
                        RouteNames.interactiveExercise,
                        extra: exerciseType,
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                    label: const Text(
                      'MULAI LATIHAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kamera akan diaktifkan untuk deteksi pose real-time.',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDosageCard(
    BuildContext context, {
    required String label,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtext,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
