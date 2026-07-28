/// Model data frame tunggal yang direkam ke format JSON.
class RecordedFrame {
  const RecordedFrame({
    required this.timestampMs,
    required this.shoulderAngle,
    required this.elbowAngle,
    required this.confidence,
    required this.validationStatus,
  });

  final int timestampMs;
  final double shoulderAngle;
  final double elbowAngle;
  final double confidence;
  final String validationStatus;

  Map<String, dynamic> toJson() {
    return {
      'timestampMs': timestampMs,
      'shoulderAngle': shoulderAngle,
      'elbowAngle': elbowAngle,
      'confidence': confidence,
      'validationStatus': validationStatus,
    };
  }

  factory RecordedFrame.fromJson(Map<String, dynamic> json) {
    return RecordedFrame(
      timestampMs: (json['timestampMs'] as num).toInt(),
      shoulderAngle: (json['shoulderAngle'] as num).toDouble(),
      elbowAngle: (json['elbowAngle'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      validationStatus: json['validationStatus'] as String,
    );
  }
}
