import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Service pengelola inisialisasi dan lifecycle `CameraController`.
///
/// PERFORMA & MANAJEMEN MEMORI:
/// - Menggunakan resolution preset [ResolutionPreset.medium] (~720p). Resolution ini adalah
///   sweet spot optimal: memberikan detail koordinat sendi yang sangat akurat bagi ML Kit Pose Detection
///   tanpa membebani memori RAM dan GPU kamera saat stream frame.
class CameraService {
  CameraService({
    this.initialDirection = CameraLensDirection.front,
    this.resolutionPreset = ResolutionPreset.medium,
  });

  final CameraLensDirection initialDirection;
  final ResolutionPreset resolutionPreset;

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isStreaming = false;

  /// Instance Controller kamera aktif.
  CameraController? get controller => _controller;

  /// List seluruh kamera fisik yang tersedia pada perangkat.
  List<CameraDescription> get cameras => _cameras;

  /// Kamera aktif saat ini.
  CameraDescription? get currentCamera =>
      _cameras.isNotEmpty ? _cameras[_selectedCameraIndex] : null;

  /// Apakah kamera aktif menghadap depan.
  bool get isFrontCamera =>
      currentCamera?.lensDirection == CameraLensDirection.front;

  /// Apakah controller terinisialisasi dan siap digunakan.
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  /// Inisialisasi daftar kamera dan jalankan controller awal.
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('Tidak ada kamera ditemukan pada perangkat.');
      }

      // Cari indeks kamera awal sesuai preferensi
      final targetIndex = _cameras.indexWhere(
        (cam) => cam.lensDirection == initialDirection,
      );
      _selectedCameraIndex = targetIndex != -1 ? targetIndex : 0;

      await _startController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      debugPrint('Error initializing camera service: $e');
      rethrow;
    }
  }

  /// Memulai controller untuk kamera spesifik.
  Future<void> _startController(CameraDescription cameraDescription) async {
    await _controller?.dispose();

    _controller = CameraController(
      cameraDescription,
      resolutionPreset,
      enableAudio: false,
      imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
  }

  /// Mulai mendengarkan real-time frame stream dari kamera.
  Future<void> startImageStream(onLatestImageAvailable onAvailable) async {
    if (_controller == null || !isInitialized || _isStreaming) return;
    _isStreaming = true;
    await _controller!.startImageStream(onAvailable);
  }

  /// Hentikan stream frame kamera.
  Future<void> stopImageStream() async {
    if (_controller == null || !_isStreaming) return;
    _isStreaming = false;
    await _controller!.stopImageStream();
  }

  /// Ganti antara kamera depan dan belakang.
  Future<void> switchCamera(onLatestImageAvailable? onAvailable) async {
    if (_cameras.length <= 1) return;

    if (_isStreaming) {
      await stopImageStream();
    }

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _startController(_cameras[_selectedCameraIndex]);

    if (onAvailable != null) {
      await startImageStream(onAvailable);
    }
  }

  /// Membebaskan seluruh resource kamera.
  Future<void> dispose() async {
    if (_isStreaming) {
      await stopImageStream();
    }
    await _controller?.dispose();
    _controller = null;
  }
}
