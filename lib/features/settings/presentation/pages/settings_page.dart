import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';

/// Halaman Settings dengan opsi membuka Component Gallery.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: AppSpacing.paddingPage,
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppSpacing.paddingAllMd,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: const Icon(
                        Icons.palette_rounded,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Gap(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Design System',
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            'Component Gallery & Design Tokens',
                            style: AppTextStyles.captionMedium.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(AppSpacing.lg),
                AppButton(
                  label: 'Buka Component Gallery',
                  icon: Icons.auto_awesome_rounded,
                  isExpanded: true,
                  onPressed: () => context.pushNamed(RouteNames.componentGallery),
                ),
              ],
            ),
          ),
          Gap(AppSpacing.lg),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppSpacing.paddingAllMd,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: const Icon(
                        Icons.developer_mode_rounded,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                    Gap(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adaptive Training Engine',
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            'Developer Debug Dashboard & Metrics',
                            style: AppTextStyles.captionMedium.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(AppSpacing.lg),
                AppButton(
                  label: 'Buka Adaptive Debug Dashboard',
                  icon: Icons.bug_report_rounded,
                  isExpanded: true,
                  onPressed: () => context.pushNamed(RouteNames.adaptiveDebug),
                ),
              ],
            ),
          ),
          Gap(AppSpacing.lg),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppSpacing.paddingAllMd,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Gap(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Validation & Calibration',
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            'AI Validation Dashboard & Calibration',
                            style: AppTextStyles.captionMedium.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(AppSpacing.lg),
                AppButton(
                  label: 'Buka AI Validation Dashboard',
                  icon: Icons.speed_rounded,
                  isExpanded: true,
                  onPressed: () => context.pushNamed(RouteNames.aiValidation),
                ),
              ],
            ),
          ),
          Gap(AppSpacing.lg),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppSpacing.paddingAllMd,
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: const Icon(
                        Icons.local_library_rounded,
                        color: AppColors.tertiary,
                      ),
                    ),
                    Gap(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exercise Content Management',
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            'Katalog Latihan Adaptif Kursi Roda & Seated',
                            style: AppTextStyles.captionMedium.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(AppSpacing.lg),
                AppButton(
                  label: 'Buka Katalog Latihan (ECMS)',
                  icon: Icons.fitness_center_rounded,
                  isExpanded: true,
                  onPressed: () => context.pushNamed(RouteNames.exerciseLibrary),
                ),
              ],
            ),
          ),
          Gap(AppSpacing.lg),
          Center(
            child: Text(
              'GERAKIN - ECMS Dynamic Asset Loaded',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
