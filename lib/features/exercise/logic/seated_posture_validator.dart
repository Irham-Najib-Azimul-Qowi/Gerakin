import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../camera/models/pose_landmark_model.dart';
import 'angle_calculator.dart';

/// State Postur Tubuh Pengguna Saat Latihan Adaptif.
enum UserPostureState {
  /// Postur duduk terkonfirmasi (Optimal untuk latihan adaptif/kursi roda)
  sitting,

  /// Postur berdiri terkonfirmasi (Memicu peringatan & jeda latihan)
  standing,

  /// Tidak dapat dipastikan (Misal bagian bawah tubuh occluded/terpotong)
  uncertain,
}

/// Hasil Evaluasi Postur Tubuh.
class PostureValidationResult {
  final UserPostureState state;
  final double standingConfidence;
  final double sittingConfidence;
  final String message;

  const PostureValidationResult({
    required this.state,
    required this.standingConfidence,
    required this.sittingConfidence,
    required this.message,
  });
}

/// Modul Validator Postur Duduk vs. Berdiri (SeatedPostureValidator).
///
/// MENGGUNAKAN HEURISTIK MULTI-FAKTOR:
/// 1. Knee Extension Angle (Beda sudut siku lutut panggul-lutut-pergelangan)
/// 2. Hip-Knee Verticality Ratio (Rasio jarak vertikal panggul ke lutut terhadap panjang torso)
/// 3. Temporal Stability Guard (Debounce 800ms / 15-frame konsisten)
class SeatedPostureValidator {
  SeatedPostureValidator({
    this.standingThreshold = 0.72,
    this.sittingThreshold = 0.60,
    this.consecutiveFramesRequired = 12,
  });

  final double standingThreshold;
  final double sittingThreshold;
  final int consecutiveFramesRequired;

  int _consecutiveStandingFrames = 0;
  int _consecutiveSittingFrames = 0;
  UserPostureState _currentState = UserPostureState.sitting;

  UserPostureState get currentState => _currentState;

  /// Mengevaluasi snapshot [Map<PoseLandmarkType, PoseLandmarkModel>] untuk menentukan postur.
  PostureValidationResult evaluate(Map<PoseLandmarkType, PoseLandmarkModel> landmarks) {
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    // Keandalan minimal landmark panggul & lutut (likelihood >= 0.40)
    final bool hasLeftLeg = leftHip != null && leftKnee != null &&
        leftHip.likelihood >= 0.40 && leftKnee.likelihood >= 0.40;
    final bool hasRightLeg = rightHip != null && rightKnee != null &&
        rightHip.likelihood >= 0.40 && rightKnee.likelihood >= 0.40;

    if (!hasLeftLeg && !hasRightLeg) {
      // Landmark kaki bagian bawah tidak cukup terlihat
      return PostureValidationResult(
        state: UserPostureState.uncertain,
        standingConfidence: 0.0,
        sittingConfidence: 0.0,
        message: 'Pastikan tubuh dan posisi duduk terlihat jelas di kamera.',
      );
    }

    double totalStandingScore = 0.0;
    double totalSittingScore = 0.0;
    int samples = 0;

    // 1. Evaluasi Kaki Kiri
    if (hasLeftLeg && leftAnkle != null && leftAnkle.likelihood >= 0.40) {
      final kneeAngle = AngleCalculator.calculateAngle(
        Offset(leftHip.x, leftHip.y),
        Offset(leftKnee.x, leftKnee.y),
        Offset(leftAnkle.x, leftAnkle.y),
      );
      final scores = _evaluateLegGeometry(leftHip, leftKnee, leftAnkle, leftShoulder, kneeAngle);
      totalStandingScore += scores[0];
      totalSittingScore += scores[1];
      samples++;
    }

    // 2. Evaluasi Kaki Kanan
    if (hasRightLeg && rightAnkle != null && rightAnkle.likelihood >= 0.40) {
      final kneeAngle = AngleCalculator.calculateAngle(
        Offset(rightHip.x, rightHip.y),
        Offset(rightKnee.x, rightKnee.y),
        Offset(rightAnkle.x, rightAnkle.y),
      );
      final scores = _evaluateLegGeometry(rightHip, rightKnee, rightAnkle, rightShoulder, kneeAngle);
      totalStandingScore += scores[0];
      totalSittingScore += scores[1];
      samples++;
    }

    // Jika ankle tidak terlihat tetapi hip & knee terlihat
    if (samples == 0) {
      if (hasLeftLeg && leftShoulder != null) {
        final ratio = (leftKnee.y - leftHip.y).abs() / ((leftHip.y - leftShoulder.y).abs() + 1.0);
        if (ratio > 1.25) {
          totalStandingScore += 0.65;
        } else {
          totalSittingScore += 0.70;
        }
        samples++;
      }
    }

    final double standingConfidence = samples > 0 ? (totalStandingScore / samples).clamp(0.0, 1.0) : 0.0;
    final double sittingConfidence = samples > 0 ? (totalSittingScore / samples).clamp(0.0, 1.0) : 0.0;

    // 3. Temporal Stability Guard (Debounce Konsekutif Frame)
    if (standingConfidence >= standingThreshold && standingConfidence > sittingConfidence) {
      _consecutiveStandingFrames++;
      _consecutiveSittingFrames = 0;
    } else if (sittingConfidence >= sittingThreshold) {
      _consecutiveSittingFrames++;
      _consecutiveStandingFrames = 0;
    }

    // Konfirmasi Perubahan State setelah N Frame Konsekutif
    if (_consecutiveStandingFrames >= consecutiveFramesRequired) {
      _currentState = UserPostureState.standing;
    } else if (_consecutiveSittingFrames >= 4) {
      _currentState = UserPostureState.sitting;
    }

    String message;
    switch (_currentState) {
      case UserPostureState.sitting:
        message = 'Posisi duduk terkonfirmasi ✓';
        break;
      case UserPostureState.standing:
        message = 'Posisi tidak sesuai. Silakan lakukan latihan dalam posisi duduk.';
        break;
      case UserPostureState.uncertain:
        message = 'Pastikan tubuh dan posisi duduk terlihat di kamera.';
        break;
    }

    return PostureValidationResult(
      state: _currentState,
      standingConfidence: standingConfidence,
      sittingConfidence: sittingConfidence,
      message: message,
    );
  }

  /// Evaluasi geometri 1 kaki (Hip, Knee, Ankle)
  /// Return [standingScore, sittingScore]
  List<double> _evaluateLegGeometry(
    PoseLandmarkModel hip,
    PoseLandmarkModel knee,
    PoseLandmarkModel ankle,
    PoseLandmarkModel? shoulder,
    double kneeAngle,
  ) {
    double standingScore = 0.0;
    double sittingScore = 0.0;

    // A. Knee Extension Angle
    // Saat berdiri lutut lurus: ~160° - 180°
    // Saat duduk lutut tekuk: ~80° - 140°
    if (kneeAngle >= 158.0) {
      standingScore += 0.50;
    } else if (kneeAngle <= 138.0) {
      sittingScore += 0.50;
    } else {
      // Linear interpolation untuk zona transisi
      final standingRatio = (kneeAngle - 138.0) / 20.0;
      standingScore += 0.50 * standingRatio;
      sittingScore += 0.50 * (1.0 - standingRatio);
    }

    // B. Hip-Knee Vertical Offset Ratio (Relatif terhadap Torso)
    final double torsoH = shoulder != null ? (hip.y - shoulder.y).abs() : 200.0;
    final double legVerticalH = (ankle.y - hip.y).abs();
    final double ratio = legVerticalH / (torsoH > 10.0 ? torsoH : 200.0);

    if (ratio >= 1.35) {
      standingScore += 0.50;
    } else {
      sittingScore += 0.50;
    }

    return [standingScore, sittingScore];
  }

  /// Reset counter state
  void reset() {
    _consecutiveStandingFrames = 0;
    _consecutiveSittingFrames = 0;
    _currentState = UserPostureState.sitting;
  }
}
