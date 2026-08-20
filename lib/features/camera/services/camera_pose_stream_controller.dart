import 'package:camera/camera.dart';

import '../models/detected_pose.dart';
import 'camera_service.dart';
import 'frame_processor.dart';
import 'pose_detector_service.dart';

/// Controller terpusat pengelola siklus hidup CameraService + PoseDetectorService + FrameProcessor.
///
/// Menyediakan abstraksi tunggal untuk menginisialisasi kamera, streaming pose detector,
/// pergantian kamera, dan manajemen memori/dispose.
class CameraPoseStreamController {
  CameraPoseStreamController({int minIntervalMs = 33})
      : cameraService = CameraService(),
        poseDetectorService = PoseDetectorService(),
        frameProcessor = FrameProcessor(minIntervalMs: minIntervalMs);

  final CameraService cameraService;
  final PoseDetectorService poseDetectorService;
  final FrameProcessor frameProcessor;

  CameraController? get cameraController => cameraService.controller;
  bool get isInitialized => cameraService.isInitialized;
  bool get isFrontCamera => cameraService.isFrontCamera;

  /// Menginisialisasi perangkat kamera dan pose detector.
  Future<void> initialize() async {
    await cameraService.initialize();
  }

  /// Memulai image streaming dari kamera ke ML Kit Pose Detector.
  Future<void> startStream(void Function(DetectedPose pose) onPoseDetected) async {
    await cameraService.startImageStream((CameraImage image) async {
      final camera = cameraService.currentCamera;
      if (camera == null) return;

      final detectedPose = await frameProcessor.processFrame<DetectedPose>(
        cameraImage: image,
        cameraDescription: camera,
        onProcess: (inputImage) async {
          return await poseDetectorService.processImage(
            inputImage: inputImage,
            isFrontCamera: cameraService.isFrontCamera,
          );
        },
      );

      if (detectedPose != null) {
        onPoseDetected(detectedPose);
      }
    });
  }

  /// Menghentikan image stream tanpa menutup controller kamera.
  Future<void> stopStream() async {
    await cameraService.stopImageStream();
  }

  /// Mengganti ke kamera depan/belakang dan mereset frame processor.
  Future<void> switchCamera(void Function(DetectedPose pose) onPoseDetected) async {
    frameProcessor.reset();
    await cameraService.switchCamera((image) async {
      final camera = cameraService.currentCamera;
      if (camera == null) return;

      final detectedPose = await frameProcessor.processFrame<DetectedPose>(
        cameraImage: image,
        cameraDescription: camera,
        onProcess: (inputImage) async {
          return await poseDetectorService.processImage(
            inputImage: inputImage,
            isFrontCamera: cameraService.isFrontCamera,
          );
        },
      );

      if (detectedPose != null) {
        onPoseDetected(detectedPose);
      }
    });
  }

  /// Membersihkan sumber daya memori dan kamera.
  void dispose() {
    cameraService.dispose();
    poseDetectorService.close();
  }
}
