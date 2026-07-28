/// Model pengaturan suara Text-to-Speech (TTS).
class VoiceSettings {
  const VoiceSettings({
    this.isVoiceEnabled = true,
    this.volume = 1.0,
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.cooldownSeconds = 3,
  });

  /// Status aktif/non-aktif suara feedback.
  final bool isVoiceEnabled;

  /// Volume suara (0.0 s/d 1.0).
  final double volume;

  /// Kecepatan bicara / speech rate (0.0 s/d 1.0).
  final double speechRate;

  /// Nada bicara / pitch (0.5 s/d 2.0).
  final double pitch;

  /// Durasi jeda minimal (cooldown) dalam detik antar pesan suara.
  final int cooldownSeconds;

  VoiceSettings copyWith({
    bool? isVoiceEnabled,
    double? volume,
    double? speechRate,
    double? pitch,
    int? cooldownSeconds,
  }) {
    return VoiceSettings(
      isVoiceEnabled: isVoiceEnabled ?? this.isVoiceEnabled,
      volume: volume ?? this.volume,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
    );
  }
}
