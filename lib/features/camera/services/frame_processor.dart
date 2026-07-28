import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Processor untuk konversi [CameraImage] menjadi [InputImage] serta membatasi (throttling) pemrosesan frame.
///
/// PERFORMA & ARSITEKTUR:
/// 1. Busy-lock (`_isProcessing`): Jika frame sebelumnya belum selesai dianalisis oleh ML Kit,
///    frame kamera baru yang masuk DIBUANG (skipped) secara instan.
/// 2. Time-throttling (`minIntervalMs`): Menjaga interval pemrosesan minimal antar frame
///    (misal: 30ms ≈ ~33 FPS) agar GPU/CPU tidak mengalami throttling panas (thermal throttling).
class FrameProcessor {
  FrameProcessor({this.minIntervalMs = 30});

  /// Interval waktu minimal antar pemrosesan frame dalam milidetik.
  final int minIntervalMs;

  bool _isProcessing = false;
  int _lastProcessTimestamp = 0;

  /// Apakah processor sedang sibuk mengolah frame.
  bool get isProcessing => _isProcessing;

  /// Mengeksekusi pemrosesan [CameraImage] jika tidak sibuk dan memenuhi interval waktu.
  ///
  /// Mengembalikan `null` jika frame di-skip untuk menjaga FPS tetap mulus.
  Future<T?> processFrame<T>({
    required CameraImage cameraImage,
    required CameraDescription cameraDescription,
    required Future<T?> Function(InputImage inputImage) onProcess,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Time Throttling: Skip jika belum mencapai interval minimal
    if (now - _lastProcessTimestamp < minIntervalMs) {
      return null;
    }

    // 2. Busy Locking: Skip jika frame sebelumnya belum selesai diproses
    if (_isProcessing) {
      return null;
    }

    _isProcessing = true;
    _lastProcessTimestamp = now;

    try {
      final inputImage = _inputImageFromCameraImage(
        image: cameraImage,
        camera: cameraDescription,
      );

      if (inputImage == null) return null;

      return await onProcess(inputImage);
    } catch (e) {
      debugPrint('Error in FrameProcessor: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Memetakan format [CameraImage] platform (YUV420/NV21/BGRA8888) ke [InputImage] ML Kit.
  InputImage? _inputImageFromCameraImage({
    required CameraImage image,
    required CameraDescription camera,
  }) {
    // Determine image rotation
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    final rotationValue = sensorOrientation;

    switch (rotationValue) {
      case 90:
        rotation = InputImageRotation.rotation90deg;
        break;
      case 180:
        rotation = InputImageRotation.rotation180deg;
        break;
      case 270:
        rotation = InputImageRotation.rotation270deg;
        break;
      case 0:
      default:
        rotation = InputImageRotation.rotation0deg;
        break;
    }

    // Determine format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    // Build planes metadata
    if (image.planes.length != 1 && format != InputImageFormat.yuv420) {
      return null;
    }

    // Concatenate plane bytes
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  /// Reset state throttling.
  void reset() {
    _isProcessing = false;
    _lastProcessTimestamp = 0;
  }
}
