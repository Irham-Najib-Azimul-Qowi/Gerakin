import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../domain/validation_engine_facade.dart';
import '../widgets/calibration_flow_widget.dart';

/// Halaman AI Validation Dashboard yang menampilkan 9 metrik utama vision & kalibrasi.
///
/// METRIK WAJIB:
/// 1. FPS
/// 2. Processing Time
/// 3. Pose Confidence
/// 4. Tracking Stability
/// 5. Camera Distance
/// 6. Lighting Score
/// 7. Pose Quality
/// 8. Latency
/// 9. Current ROM
class AiValidationDashboardPage extends ConsumerWidget {
  const AiValidationDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final validationState = ref.watch(validationEngineProvider);
    final m = validationState.metrics;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'AI Validation Dashboard',
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
            // 1. Pre-workout Calibration Flow Widget
            CalibrationFlowWidget(
              calibrationStatus: validationState.calibrationStatus,
            ),

            Gap(AppSpacing.lg),

            // Banner Vision Telemetry
            Container(
              padding: AppSpacing.paddingAllLg,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.secondary,
                    AppColors.secondaryDark,
                  ],
                ),
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.analytics_rounded,
                    color: AppColors.onSecondary,
                    size: 36,
                  ),
                  Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Computer Vision Telemetry',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Gap(AppSpacing.xs),
                        Text(
                          'Real-time Pose Quality & Camera Performance Metrics',
                          style: AppTextStyles.captionMedium.copyWith(
                            color: AppColors.onSecondary.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.lg),

            // 9 Core Metrics Grid
            SectionCard(
              color: AppColors.surfaceContainerLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '9 Metrik Validasi Vision',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Parameter performa deteksi pose & lingkungan',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  Gap(AppSpacing.md),

                  // Row 1: FPS, Processing Time, Latency
                  Row(
                    children: [
                      _MetricTile(
                        label: '1. FPS',
                        value: '${m.fps.toInt()}',
                        unit: 'fps',
                        icon: Icons.speed_rounded,
                        color: m.fps >= 24 ? AppColors.success : AppColors.warning,
                      ),
                      _MetricTile(
                        label: '2. Processing Time',
                        value: '${m.processingTimeMs.toInt()}',
                        unit: 'ms',
                        icon: Icons.timer_rounded,
                        color: AppColors.primary,
                      ),
                      _MetricTile(
                        label: '8. Latency',
                        value: '${m.latencyMs.toInt()}',
                        unit: 'ms',
                        icon: Icons.network_check_rounded,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),

                  Gap(AppSpacing.sm),

                  // Row 2: Pose Confidence, Tracking Stability, Pose Quality
                  Row(
                    children: [
                      _MetricTile(
                        label: '3. Confidence',
                        value: '${m.poseConfidence.toInt()}',
                        unit: '%',
                        icon: Icons.verified_user_rounded,
                        color: AppColors.success,
                      ),
                      _MetricTile(
                        label: '4. Stability',
                        value: '${m.trackingStability.toInt()}',
                        unit: '%',
                        icon: Icons.health_and_safety_rounded,
                        color: AppColors.primary,
                      ),
                      _MetricTile(
                        label: '7. Pose Quality',
                        value: '${m.poseQualityScore.toInt()}',
                        unit: '%',
                        icon: Icons.high_quality_rounded,
                        color: AppColors.success,
                      ),
                    ],
                  ),

                  Gap(AppSpacing.sm),

                  // Row 3: Camera Distance, Lighting Score, Current ROM
                  Row(
                    children: [
                      _MetricTile(
                        label: '5. Distance',
                        value: '${m.cameraDistanceMeters}',
                        unit: 'm',
                        icon: Icons.straighten_rounded,
                        color: AppColors.tertiary,
                      ),
                      _MetricTile(
                        label: '6. Lighting',
                        value: '${m.lightingScore.toInt()}',
                        unit: '%',
                        icon: Icons.wb_sunny_rounded,
                        color: AppColors.warning,
                      ),
                      _MetricTile(
                        label: '9. Current ROM',
                        value: '${m.currentRom.toInt()}',
                        unit: '°',
                        icon: Icons.accessibility_new_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.xl),

            // Recording & Replay Controls Section
            SectionCard(
              color: AppColors.surfaceContainerLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Recording & Replay Debugging',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rekam sesi ke format JSON dan putar kembali tanpa kamera',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  Gap(AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: validationState.isRecording
                              ? 'Hentikan Perekaman'
                              : 'Rekam Sesi (JSON)',
                          icon: validationState.isRecording
                              ? Icons.stop_rounded
                              : Icons.videocam_rounded,
                          onPressed: () {
                            final facade = ref.read(validationEngineProvider.notifier);
                            if (validationState.isRecording) {
                              facade.stopRecording();
                            } else {
                              facade.startRecording('arm_raise');
                            }
                          },
                        ),
                      ),
                      Gap(AppSpacing.md),
                      Expanded(
                        child: AppButton(
                          label: validationState.isReplaying
                              ? 'Replay Aktif...'
                              : 'Putar Replay JSON',
                          icon: Icons.play_arrow_rounded,
                          onPressed: validationState.recordedSession != null
                              ? () {
                                  ref.read(validationEngineProvider.notifier).startReplay(
                                        validationState.recordedSession!,
                                      );
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

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
            Icon(icon, color: color, size: 22),
            Gap(AppSpacing.xxs),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.neutral600,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.neutral600,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
