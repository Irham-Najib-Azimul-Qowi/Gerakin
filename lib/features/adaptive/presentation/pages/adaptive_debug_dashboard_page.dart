import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../domain/adaptive_engine_facade.dart';
import '../../models/coach_decision.dart';
import '../../models/fatigue_status.dart';

/// Halaman Developer Debug Dashboard untuk memantau mesin adaptif secara real-time.
///
/// MENAMPILKAN METRIK:
/// - ROM (Shoulder & Elbow)
/// - Difficulty Level (1–5)
/// - Fatigue Status
/// - Coach Decision
/// - Recommended Exercise
/// - Safety Score
class AdaptiveDebugDashboardPage extends ConsumerWidget {
  const AdaptiveDebugDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adaptiveState = ref.watch(adaptiveEngineProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Developer Debug Dashboard',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
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
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.developer_mode_rounded,
                    color: AppColors.onPrimary,
                    size: 36,
                  ),
                  Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adaptive Training Engine',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Gap(AppSpacing.xs),
                        Text(
                          'Real-time Biomechanics & AI Decision Metrics',
                          style: AppTextStyles.captionMedium.copyWith(
                            color: AppColors.onPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.lg),

            // 1. Safety Score Card
            _SafetyScoreCard(safetyScore: adaptiveState.safety.safetyScore),

            Gap(AppSpacing.lg),

            // 2. Difficulty Level & Fitness Rating Card
            _DifficultyCard(
              level: adaptiveState.profile.difficultyLevel,
              rating: adaptiveState.profile.fitnessRating,
            ),

            Gap(AppSpacing.lg),

            // 3. ROM (Range of Motion) Card
            _RomCard(
              shoulderRom: adaptiveState.profile.shoulderRom,
              elbowRom: adaptiveState.profile.elbowRom,
              stability: adaptiveState.profile.stabilityScore,
            ),

            Gap(AppSpacing.lg),

            // 4. Fatigue Status Card
            _FatigueCard(fatigue: adaptiveState.fatigue),

            Gap(AppSpacing.lg),

            // 5. Coach Decision Card
            _CoachDecisionCard(decision: adaptiveState.decision),

            Gap(AppSpacing.lg),

            // 6. Recommended Exercise Card
            _RecommendationCard(
              recommendation: adaptiveState.recommendation,
              dynamicAngle: adaptiveState.dynamicTargetAngle,
              adaptiveRest: adaptiveState.adaptiveRestTime,
            ),

            Gap(AppSpacing.xl),

            // Action Button Simulation
            Center(
              child: AppButton(
                label: 'Simulasikan Penilaian Fisik Awal',
                icon: Icons.refresh_rounded,
                isExpanded: true,
                onPressed: () {
                  ref.read(adaptiveEngineProvider.notifier).runAssessment([]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        Gap(AppSpacing.sm),
      ],
    );
  }
}

class _SafetyScoreCard extends StatelessWidget {
  const _SafetyScoreCard({required this.safetyScore});

  final double safetyScore;

  @override
  Widget build(BuildContext context) {
    final color = safetyScore >= 80.0
        ? AppColors.success
        : (safetyScore >= 60.0 ? AppColors.warning : AppColors.error);

    return SectionCard(
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'Safety Score (Skor Keselamatan)',
            subtitle: 'Evaluasi risiko cidera & keabsahan postur',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${safetyScore.toInt()}%',
                style: AppTextStyles.displayMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Chip(
                backgroundColor: color.withValues(alpha: 0.15),
                side: BorderSide(color: color),
                label: Text(
                  safetyScore >= 60.0 ? 'SAFE' : 'HAZARD',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Gap(AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.borderRadiusSm,
            child: LinearProgressIndicator(
              value: safetyScore / 100.0,
              color: color,
              backgroundColor: AppColors.surfaceContainer,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.level,
    required this.rating,
  });

  final int level;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'Difficulty Level (Tingkat Kesulitan)',
            subtitle: 'Level adaptif 1 s/d 5',
          ),
          Row(
            children: List.generate(5, (index) {
              final isFilled = (index + 1) <= level;
              return Expanded(
                child: Container(
                  height: 12,
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? AppColors.primary
                        : AppColors.surfaceContainer,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                ),
              );
            }),
          ),
          Gap(AppSpacing.md),
          Text(
            'Level $level — $rating',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RomCard extends StatelessWidget {
  const _RomCard({
    required this.shoulderRom,
    required this.elbowRom,
    required this.stability,
  });

  final double shoulderRom;
  final double elbowRom;
  final double stability;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'ROM & Stability (Rentang Gerak)',
            subtitle: 'Pengukuran kapasitas biomekanik',
          ),
          Row(
            children: [
              _RomMetricTile(
                label: 'Shoulder ROM',
                value: '${shoulderRom.toInt()}°',
                icon: Icons.accessibility_new_rounded,
              ),
              _RomMetricTile(
                label: 'Elbow ROM',
                value: '${elbowRom.toInt()}°',
                icon: Icons.fitness_center_rounded,
              ),
              _RomMetricTile(
                label: 'Stability',
                value: '${stability.toInt()}%',
                icon: Icons.health_and_safety_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RomMetricTile extends StatelessWidget {
  const _RomMetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: AppSpacing.paddingAllSm,
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            Gap(AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.neutral600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FatigueCard extends StatelessWidget {
  const _FatigueCard({required this.fatigue});

  final FatigueStatus fatigue;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'Fatigue Status (Kelelahan Otot)',
            subtitle: 'Deteksi penurunan kestabilan & kecepatan',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fatigue.level.name.toUpperCase(),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: fatigue.level == FatigueLevel.severe
                          ? AppColors.error
                          : (fatigue.level == FatigueLevel.moderate
                              ? AppColors.warning
                              : AppColors.success),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(AppSpacing.xxs),
                  Text(
                    'Degradasi: ${fatigue.degradationPercentage.toInt()}%',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
              if (fatigue.recommendRest)
                Chip(
                  backgroundColor: AppColors.error.withValues(alpha: 0.15),
                  side: const BorderSide(color: AppColors.error),
                  label: Text(
                    'REST NEEDED',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoachDecisionCard extends StatelessWidget {
  const _CoachDecisionCard({required this.decision});

  final CoachDecision decision;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'Coach Decision (Keputusan AI)',
            subtitle: 'Rule-Based AI Recommendation Engine',
          ),
          Row(
            children: [
              const Icon(
                Icons.psychology_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              Gap(AppSpacing.md),
              Expanded(
                child: Text(
                  decision.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Gap(AppSpacing.sm),
          Text(
            decision.reasoning,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.dynamicAngle,
    required this.adaptiveRest,
  });

  final dynamic recommendation;
  final double dynamicAngle;
  final int adaptiveRest;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'Recommended Exercise (Target Adaptif)',
            subtitle: 'Target dinamis terpersonalisasi',
          ),
          Text(
            recommendation.recommendedExerciseName.toString(),
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dynamic Angle: ${dynamicAngle.toInt()}°',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'Rest: ${adaptiveRest}s',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
