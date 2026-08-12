import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../controllers/assessment_wizard_controller.dart';
import '../controllers/profile_controller.dart';

/// Halaman Uji Fisik Penilaian Awal (Assessment Wizard) interaktif.
class AssessmentWizardPage extends ConsumerWidget {
  const AssessmentWizardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(assessmentWizardControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Penilaian Fisik Awal', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: wizardState.currentStep > 0 && wizardState.currentStep < 5
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => ref.read(assessmentWizardControllerProvider.notifier).prevStep(),
              )
            : null,
      ),
      body: wizardState.isSubmitting
          ? const Center(child: CircularProgressIndicator())
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
        return _buildCompletionStep(context, ref);
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
          Icon(
            Icons.spa_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          const Text(
            'Selamat Datang di Uji Fisik',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Mari ketahui tingkat mobilitas fisik Anda saat ini agar GERAKIN dapat menyusun intensitas latihan adaptif yang sesuai.',
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => ref.read(assessmentWizardControllerProvider.notifier).nextStep(),
              child: const Text('Mulai Penilaian'),
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
      title: 'Kekuatan Tubuh Bagian Atas',
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
      title: 'Stabilitas Otot Inti (Core)',
      description: 'Nilai kemampuan otot perut dan punggung Anda untuk menahan posisi seated tegak selama latihan adaptif (skala 0 - 100).',
      value: state.coreScore.toDouble(),
      onChanged: (val) {
        ref.read(assessmentWizardControllerProvider.notifier).updateScores(core: val.round());
      },
      onNext: () => ref.read(assessmentWizardControllerProvider.notifier).nextStep(),
    );
  }

  // ── STEP 3: ENDURANCE ────────────────────────────────────────────
  Widget _buildEnduranceStep(BuildContext context, WidgetRef ref, AssessmentWizardState state) {
    return _buildSliderStep(
      context: context,
      title: 'Tingkat Daya Tahan (Endurance)',
      description: 'Nilai kapasitas stamina kardiovaskular Anda dalam melakukan latihan gerakan berulang-ulang (skala 0 - 100).',
      value: state.enduranceScore.toDouble(),
      onChanged: (val) {
        ref.read(assessmentWizardControllerProvider.notifier).updateScores(endurance: val.round());
      },
      onNext: () => ref.read(assessmentWizardControllerProvider.notifier).nextStep(),
    );
  }

  Widget _buildSliderStep({
    required BuildContext context,
    required String title,
    required String description,
    required double value,
    required ValueChanged<double> onChanged,
    required VoidCallback onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.6)),
          const Spacer(),
          Center(
            child: Text(
              value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Slider(
            value: value,
            min: 0,
            max: 100,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Lanjutkan'),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 4: REHABILITATION GOALS ─────────────────────────────────
  Widget _buildGoalsStep(BuildContext context, WidgetRef ref, AssessmentWizardState state) {
    final goals = [
      {'type': 'strength', 'label': 'Meningkatkan Kekuatan Otot (Strength)'},
      {'type': 'endurance', 'label': 'Meningkatkan Stamina & Daya Tahan (Endurance)'},
      {'type': 'rom', 'label': 'Melatih Kelenturan Sendi (ROM)'},
      {'type': 'mobility', 'label': 'Aktivitas Harian Mandiri (Mobility)'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Target Rehabilitasi Utama', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
            'Pilih fokus target pemulihan latihan fisik yang ingin Anda prioritaskan selama sebulan ke depan.',
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.6),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final g = goals[index];
                final isSelected = state.goalType == g['type'];
                return Card(
                  elevation: 0,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 0.8,
                    ),
                  ),
                  child: ListTile(
                    title: Text(g['label']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      ref.read(assessmentWizardControllerProvider.notifier).updateGoalType(g['type']!);
                    },
                  ),
                );
              },
            ),
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final success =
                    await ref.read(assessmentWizardControllerProvider.notifier).submitAssessment();
                if (success) {
                  ref.read(profileControllerProvider.notifier).loadProfiles();
                }
              },
              child: const Text('Selesaikan Penilaian'),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 5: COMPLETION ───────────────────────────────────────────
  Widget _buildCompletionStep(BuildContext context, WidgetRef ref) {
    final active = ref.read(profileControllerProvider).activeProfile;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            'Penilaian Fisik Selesai!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (active != null) ...[
            Text(
              'Tingkat mobilitas Anda teridentifikasi sebagai: ${active.mobilityLevel.toUpperCase()}\nGERAKIN telah merancang intensitas latihan dan kalibrasi sensor otomatis.',
              style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RoutePaths.home);
                }
              },
              child: const Text('Selesai & Ke Beranda'),
            ),
          ),
        ],
      ),
    );
  }
}
