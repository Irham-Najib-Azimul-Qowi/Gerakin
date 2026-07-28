/// Enum tahap alur kalibrasi pra-latihan.
enum CalibrationStep {
  notStarted,
  checkingEnvironment,
  checkingDistance,
  checkingBaseline,
  completed,
  failed,
}

/// Model status proses kalibrasi real-time.
class CalibrationStatus {
  const CalibrationStatus({
    required this.step,
    required this.progressPercentage,
    required this.statusMessage,
  });

  final CalibrationStep step;
  final double progressPercentage;
  final String statusMessage;

  bool get isCompleted => step == CalibrationStep.completed;
  bool get isFailed => step == CalibrationStep.failed;

  factory CalibrationStatus.initial() {
    return const CalibrationStatus(
      step: CalibrationStep.notStarted,
      progressPercentage: 0.0,
      statusMessage: 'Siap melakukan kalibrasi pra-latihan',
    );
  }

  CalibrationStatus copyWith({
    CalibrationStep? step,
    double? progressPercentage,
    String? statusMessage,
  }) {
    return CalibrationStatus(
      step: step ?? this.step,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
