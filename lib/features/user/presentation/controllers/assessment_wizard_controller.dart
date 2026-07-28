import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../models/rehabilitation_goal.dart';
import '../../services/assessment_wizard_service.dart';
import 'profile_controller.dart';

/// State untuk Assessment Wizard.
class AssessmentWizardState {
  final int currentStep;
  final int upperBodyScore;
  final int coreScore;
  final int enduranceScore;
  final String goalType;
  final bool isSubmitting;
  final String? errorMessage;

  AssessmentWizardState({
    required this.currentStep,
    required this.upperBodyScore,
    required this.coreScore,
    required this.enduranceScore,
    required this.goalType,
    required this.isSubmitting,
    this.errorMessage,
  });

  AssessmentWizardState copyWith({
    int? currentStep,
    int? upperBodyScore,
    int? coreScore,
    int? enduranceScore,
    String? goalType,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return AssessmentWizardState(
      currentStep: currentStep ?? this.currentStep,
      upperBodyScore: upperBodyScore ?? this.upperBodyScore,
      coreScore: coreScore ?? this.coreScore,
      enduranceScore: enduranceScore ?? this.enduranceScore,
      goalType: goalType ?? this.goalType,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller (Notifier) untuk mengelola penaksiran fisik pengguna secara bertahap.
class AssessmentWizardController extends Notifier<AssessmentWizardState> {
  late final UserRepository _repository;
  late final AssessmentWizardService _wizardService;

  @override
  AssessmentWizardState build() {
    _repository = ref.watch(userRepositoryProvider);
    _wizardService = AssessmentWizardService(_repository);

    return AssessmentWizardState(
      currentStep: 0,
      upperBodyScore: 50,
      coreScore: 50,
      enduranceScore: 50,
      goalType: 'strength',
      isSubmitting: false,
    );
  }

  /// Pindah ke langkah berikutnya.
  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  /// Pindah ke langkah sebelumnya.
  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Memperbarui nilai skor penaksiran fisik.
  void updateScores({int? upper, int? core, int? endurance}) {
    state = state.copyWith(
      upperBodyScore: upper ?? state.upperBodyScore,
      coreScore: core ?? state.coreScore,
      enduranceScore: endurance ?? state.enduranceScore,
    );
  }

  /// Memperbarui tipe target rehabilitasi.
  void updateGoalType(String type) {
    state = state.copyWith(goalType: type);
  }

  /// Menyimpan semua data penilaian dan menyelesaikannya.
  Future<bool> submitAssessment() async {
    final activeProfile = ref.read(profileControllerProvider).activeProfile;
    if (activeProfile == null) {
      state = state.copyWith(errorMessage: 'Tidak ada profil aktif.');
      return false;
    }

    try {
      state = state.copyWith(isSubmitting: true, errorMessage: null);

      // 1. Simpan hasil penilaian fisik
      await _wizardService.saveAssessmentResult(
        userId: activeProfile.id,
        upperBodyScore: state.upperBodyScore,
        coreScore: state.coreScore,
        enduranceScore: state.enduranceScore,
      );

      // 2. Hitung tingkat mobilitas & simpan ke profile aktif
      final mobility = _wizardService.calculateMobilityLevel(
        upperBodyScore: state.upperBodyScore,
        coreScore: state.coreScore,
        enduranceScore: state.enduranceScore,
      );

      final updatedProfile = activeProfile.copyWith(
        mobilityLevel: mobility,
        rehabilitationGoal: state.goalType,
        updatedAt: DateTime.now(),
      );
      await ref.read(profileControllerProvider.notifier).updateActiveProfile(updatedProfile);

      // 3. Simpan target rehabilitasi default
      final goal = RehabilitationGoal(
        userId: activeProfile.id,
        goalType: state.goalType,
        targetValue: 100.0,
        currentValue: 0.0,
        deadline: DateTime.now().add(const Duration(days: 30)),
      );
      await _repository.saveGoal(goal);

      state = state.copyWith(isSubmitting: false, currentStep: 5);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}

/// Provider untuk instansiasi [AssessmentWizardController].
final assessmentWizardControllerProvider =
    NotifierProvider<AssessmentWizardController, AssessmentWizardState>(
  AssessmentWizardController.new,
);
