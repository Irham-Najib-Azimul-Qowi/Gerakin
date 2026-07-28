import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motion/models/motion_analysis.dart';

import '../models/assessment_result.dart';
import '../models/coach_decision.dart';
import '../models/fatigue_status.dart';
import '../models/physical_profile.dart';
import '../models/safety_status.dart';
import '../models/workout_recommendation.dart';
import '../services/adaptive_difficulty_engine.dart';
import '../services/adaptive_workout_planner.dart';
import '../services/coach_decision_engine.dart';
import '../services/fatigue_detection_engine.dart';
import '../services/initial_assessment_service.dart';
import '../services/physical_profile_service.dart';
import '../services/recommendation_engine.dart';
import '../services/safety_engine.dart';

/// Class pembungkus State Adaptif untuk UI & Debug Dashboard.
class AdaptiveState {
  const AdaptiveState({
    required this.profile,
    required this.fatigue,
    required this.safety,
    required this.decision,
    required this.recommendation,
    required this.dynamicTargetAngle,
    required this.adaptiveRestTime,
  });

  final PhysicalProfile profile;
  final FatigueStatus fatigue;
  final SafetyStatus safety;
  final CoachDecision decision;
  final WorkoutRecommendation recommendation;
  final double dynamicTargetAngle;
  final int adaptiveRestTime;

  factory AdaptiveState.initial() {
    final profile = PhysicalProfile.defaultProfile();
    final fatigue = FatigueStatus.fresh();
    final safety = SafetyStatus.optimal();

    return AdaptiveState(
      profile: profile,
      fatigue: fatigue,
      safety: safety,
      decision: CoachDecision.initial(),
      recommendation: WorkoutRecommendation.defaultRecommendation(),
      dynamicTargetAngle: 140.0,
      adaptiveRestTime: 15,
    );
  }
}

/// Riverpod Provider untuk [AdaptiveEngineFacade].
final adaptiveEngineProvider =
    NotifierProvider<AdaptiveEngineFacade, AdaptiveState>(
  AdaptiveEngineFacade.new,
);

/// Facade Controller utama pengelola Adaptive Training Engine.
class AdaptiveEngineFacade extends Notifier<AdaptiveState> {
  AdaptiveEngineFacade({
    InitialAssessmentService? assessmentService,
    PhysicalProfileService? profileService,
    AdaptiveDifficultyEngine? difficultyEngine,
    FatigueDetectionEngine? fatigueEngine,
    SafetyEngine? safetyEngine,
    RecommendationEngine? recommendationEngine,
    CoachDecisionEngine? decisionEngine,
    AdaptiveWorkoutPlanner? planner,
  })  : _assessmentService = assessmentService ?? const InitialAssessmentService(),
        _profileService = profileService ?? PhysicalProfileService(),
        _fatigueEngine = fatigueEngine ?? FatigueDetectionEngine(),
        _safetyEngine = safetyEngine ?? const SafetyEngine(),
        _recommendationEngine = recommendationEngine ?? const RecommendationEngine(),
        _decisionEngine = decisionEngine ?? const CoachDecisionEngine(),
        _planner = planner ?? const AdaptiveWorkoutPlanner();

  final InitialAssessmentService _assessmentService;
  final PhysicalProfileService _profileService;
  final FatigueDetectionEngine _fatigueEngine;
  final SafetyEngine _safetyEngine;
  final RecommendationEngine _recommendationEngine;
  final CoachDecisionEngine _decisionEngine;
  final AdaptiveWorkoutPlanner _planner;

  @override
  AdaptiveState build() {
    return AdaptiveState.initial();
  }

  /// Memproses frame real-time dan memperbarui seluruh state adaptif.
  void processFrame(MotionAnalysis motion) {
    final fatigue = _fatigueEngine.processFrame(analysis: motion);
    final safety = _safetyEngine.evaluateSafety(motion);
    final profile = _profileService.currentProfile;

    final decision = _decisionEngine.evaluateDecision(
      profile: profile,
      fatigue: fatigue,
      safety: safety,
    );

    final recommendation = _recommendationEngine.generateRecommendation(
      profile: profile,
      fatigue: fatigue,
    );

    final dynamicAngle = _planner.computeDynamicTargetAngle(
      baseTargetAngle: 140.0,
      profile: profile,
    );

    final adaptiveRest = _planner.computeAdaptiveRestTime(
      baseRestSeconds: 15,
      fatigue: fatigue,
    );

    state = AdaptiveState(
      profile: profile,
      fatigue: fatigue,
      safety: safety,
      decision: decision,
      recommendation: recommendation,
      dynamicTargetAngle: dynamicAngle,
      adaptiveRestTime: adaptiveRest,
    );
  }

  /// Menjalankan sesi pengujian fisik awal (Initial Assessment).
  AssessmentResult runAssessment(List<MotionAnalysis> samples) {
    final result = _assessmentService.analyzeAssessmentSamples(samples);
    final updatedProfile = _profileService.updateProfileFromAssessment(result);

    state = AdaptiveState(
      profile: updatedProfile,
      fatigue: state.fatigue,
      safety: state.safety,
      decision: state.decision,
      recommendation: _recommendationEngine.generateRecommendation(
        profile: updatedProfile,
        fatigue: state.fatigue,
      ),
      dynamicTargetAngle: _planner.computeDynamicTargetAngle(
        baseTargetAngle: 140.0,
        profile: updatedProfile,
      ),
      adaptiveRestTime: state.adaptiveRestTime,
    );

    return result;
  }
}
