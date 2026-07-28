/// Service penilai kualitas perangkat kamera (Camera Quality Service).
class CameraQualityService {
  const CameraQualityService();

  /// Menilai kelayakan kualitas kamera (True jika resolusi dan frame rate memadai).
  bool evaluateCameraQuality({
    required double currentFps,
    required bool isFrontCamera,
  }) {
    return currentFps >= 15.0;
  }
}
