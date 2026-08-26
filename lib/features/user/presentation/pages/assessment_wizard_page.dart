import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/assessment_wizard_controller.dart';
import '../controllers/profile_controller.dart';

/// Halaman Uji Fisik Penilaian Awal (Assessment Wizard) interaktif (Sesuai DESIGN.md).
///
/// Evaluasi 3 Dimensi Fisik:
/// 1. Kekuatan Tubuh Bagian Atas (Upper Body Strength & ROM)
/// 2. Stabilitas Otot Inti (Core Stability)
/// 3. Tingkat Daya Tahan / Ketahanan (Endurance Level)
class AssessmentWizardPage extends ConsumerWidget {
  const AssessmentWizardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(assessmentWizardControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Penilaian Fisik Awal',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: wizardState.currentStep > 0 && wizardState.currentStep < 5
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: () => ref.read(assessmentWizardControllerProvider.notifier).prevStep(),
              )
            : null,
      ),
      body: wizardState.isSubmitting
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _buildWizardStepContent(context, ref, wizardState),
    );
  }

  Widget _buildWizardStepContent(
    BuildContext context,
    WidgetRef ref,
    AssessmentWizardState state,
  ) {
    switch (state.currentStep) {
      case 0:
        return _buildWelcomeStep(context, ref);
      case 1:
        return _buildUpperBodyStep(context, ref, state);
      case 2:
        return _buildCoreStabilityStep(context, ref, state);
      case 3:
        return _buildEnduranceStep(context, ref, state);
      case 4:
        return _buildGoalsStep(context, ref, state);
      case 5:
        return _buildCompletionStep(context, ref, state);
      default:
        return const Center(child: Text('Error: Langkah tidak dikenal.'));
    }
  }

  // ── STEP 0: WELCOME ──────────────────────────────────────────────
  Widget _buildWelcomeStep(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_rounded,
              size: 72,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Selamat Datang di Uji Fisik',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Mari ketahui tingkat mobilitas fisik dan ketahanan Anda saat ini agar GERAKIN dapat menyusun intensitas latihan adaptif yang aman dan tepat sasaran.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => ref.read(assessmentWizardControllerProvider.notifier).nextStep(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
              ),
              child: Text(
                'Mulai Penilaian',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 1: UPPER BODY MOBILITY ──────────────────────────────────
  Widget _buildUpperBodyStep(BuildContext context, WidgetRef ref, AssessmentWizardState state) {
    return _buildSliderStep(
      context: context,
      stepNumber: '1 dari 4',
      title: 'Kekuatan Tubuh Bagian Atas',
      icon: Icons.fitness_center_rounded,
      description: 'Gunakan slider di bawah untuk menilai kekuatan dan rentang gerak (ROM) lengan, pundak, dan bahu Anda (skala 0 - 100).',
      value: state.upperBodyScore.toDouble(),
      onChanged: (val) {
        ref.read(assessmentWizardControllerProvider.notifier).updateScores(upper: val.round());
      },
      onNext: () => ref.read(assessmentWizardControllerProvider.notifier).nextStep(),
    );
  }

  // ── STEP 2: CORE STABILITY ───────────────────────────────────────
  Widget _buildCoreStabilityStep(BuildContext context, WidgetRef ref, AssessmentWizardState state) {
    return _buildSliderStep(
      context: context,
      stepNumber: '2 dari 4',
      title: 'Stabilitas Otot Inti (Core)',
      icon: Icons.accessibility_new_rounded,
      description: 'Nilai kemampuan otot perut dan punggung Anda untuk menahan posisi duduk tegak selama latihan adaptif (skala 0 - 100).',
      value: state.coreScore.toDouble(),
      onChanged: (val) {
        ref.read(assessmentWizardControllerProvider.notifier).updateScores(core: val.round());
      },
      onNext: () => ref.read(assessmentWizardControllerProvider.notifier).nextStep(),
    );
  }

  // ── STEP 3: ENDURANCE (KETAHANAN) ─────────────────────────────────
  Widget _buildEnduranceStep(BuildContext context, WidgetRef ref, AssessmentWizardState state) {
    return _buildSliderStep(
      context: context,
      stepNumber: '3 dari 4',
      title: 'Tingkat Daya Tahan (Ketahanan)',
      icon: Icons.timer_rounded,
      description: 'Nilai kapasitas stamina dan ketahanan kardiovaskular Anda dalam melakukan latihan gerakan berulang-ulang tanpa lelah (skala 0 - 100).',
      value: state.enduranceScore.toDouble(),
      onChanged: (val) {
        ref.read(assessmentWizardControllerProvider.notifier).updateScores(endurance: val.round());
      },
      onNext: () => ref.read(assessmentWizardControllerProvider.notifier).nextStep(),
    );
  }

  Widget _buildSliderStep({
    required BuildContext context,
    required String stepNumber,
    required String title,
    required IconData icon,
    required String description,
    required double value,
    required ValueChanged<double> onChanged,
    required VoidCallback onNext,
  }) {
    String ratingLabel = 'Sedang';
    Color ratingColor = AppColors.warning;
    if (value < 40) {
      ratingLabel = 'Pemula / Rendah';
      ratingColor = const Color(0xFFEF4444);
    } else if (value >= 75) {
      ratingLabel = 'Tinggi / Mahir';
      ratingColor = AppColors.success;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(
                  'Langkah $stepNumber',
                  style: AppTextStyles.captionSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Icon(icon, color: AppColors.primary, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const Spacer(),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderRadiusXxl,
                boxShadow: AppShadows.softCard,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    value.toStringAsFixed(0),
                    style: AppTextStyles.displayMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: ratingColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Text(
                      ratingLabel,
                      style: AppTextStyles.captionSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ratingColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              onChanged: onChanged,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
              ),
              child: Text(
                'Lanjutkan',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 4: REHABILITATION GOALS ─────────────────────────────────
  Widget _buildGoalsStep(BuildContext context, WidgetRef ref, AssessmentWizardState state) {
    final goals = [
      {'type': 'strength', 'label': 'Meningkatkan Kekuatan Otot (Strength)', 'icon': Icons.fitness_center_rounded},
      {'type': 'endurance', 'label': 'Meningkatkan Stamina & Ketahanan (Endurance)', 'icon': Icons.battery_charging_full_rounded},
      {'type': 'rom', 'label': 'Melatih Kelenturan Sendi (ROM)', 'icon': Icons.sync_rounded},
      {'type': 'mobility', 'label': 'Aktivitas Harian Mandiri (Mobility)', 'icon': Icons.accessible_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Text(
              'Langkah 4 dari 4',
              style: AppTextStyles.captionSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Target Rehabilitasi Utama',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih fokus target pemulihan latihan fisik yang ingin Anda prioritaskan selama sebulan ke depan.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final g = goals[index];
                final isSelected = state.goalType == g['type'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.3) : AppColors.surface,
                    borderRadius: AppRadius.borderRadiusXxl,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.8 : 1,
                    ),
                    boxShadow: AppShadows.softCard,
                  ),
                  child: ListTile(
                    leading: Icon(
                      g['icon'] as IconData,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    title: Text(
                      g['label'] as String,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref.read(assessmentWizardControllerProvider.notifier).updateGoalType(g['type'] as String);
                    },
                  ),
                );
              },
            ),
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                state.errorMessage!,
                style: AppTextStyles.captionSmall.copyWith(color: AppColors.error),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                final success =
                    await ref.read(assessmentWizardControllerProvider.notifier).submitAssessment();
                if (success) {
                  ref.read(profileControllerProvider.notifier).loadProfiles();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
              ),
              child: Text(
                'Selesaikan Penilaian',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 5: COMPLETION ───────────────────────────────────────────
  Widget _buildCompletionStep(BuildContext context, WidgetRef ref, AssessmentWizardState state) {
    final profileState = ref.watch(profileControllerProvider);
    final active = profileState.activeProfile;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 72,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Penilaian Fisik Selesai! 🎉',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hasil evaluasi kebugaran dan ketahanan Anda berhasil disimpan.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // ── Assessment Summary Card ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderRadiusXxl,
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.softCard,
            ),
            child: Column(
              children: [
                _buildScoreRow('Kekuatan Tubuh Atas', '${state.upperBodyScore}/100'),
                const Divider(color: AppColors.border),
                _buildScoreRow('Stabilitas Inti (Core)', '${state.coreScore}/100'),
                const Divider(color: AppColors.border),
                _buildScoreRow('Skor Daya Tahan (Ketahanan)', '${state.enduranceScore}/100'),
                const Divider(color: AppColors.border),
                _buildScoreRow(
                  'Tingkat Mobilitas',
                  active?.mobilityLevel.toUpperCase() ?? 'INTERMEDIATE',
                  isHighlight: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RoutePaths.home);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
              ),
              child: Text(
                'Selesai & Ke Beranda',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
