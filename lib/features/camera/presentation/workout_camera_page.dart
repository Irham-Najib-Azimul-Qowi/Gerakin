import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_icon_button.dart';
import '../../../shared/widgets/loading/loading_overlay.dart';
import '../../../shared/widgets/states/error_state.dart';
import '../models/detected_pose.dart';
import '../services/camera_service.dart';
import '../services/frame_processor.dart';
import '../services/pose_detector_service.dart';
import 'camera_preview_widget.dart';
import '../../motion/domain/motion_processor.dart';
import '../../motion/models/motion_validation.dart';

/// Halaman utama Kamera Workout & ML Kit Pose Detection.
///
/// MENGHUBUNGKAN:
/// - [CameraService] untuk streaming video realtime.
/// - [PoseDetectorService] untuk deteksi ML Kit Pose.
/// - [FrameProcessor] untuk throttling frame agar aplikasi tidak lag/panas.
/// - [CameraPreviewWidget] & [SkeletonOverlay] untuk visualisasi di layar.
class WorkoutCameraPage extends StatefulWidget {
  const WorkoutCameraPage({super.key});

  @override
  State<WorkoutCameraPage> createState() => _WorkoutCameraPageState();
}

class _WorkoutCameraPageState extends State<WorkoutCameraPage>
    with WidgetsBindingObserver {
  late final CameraService _cameraService;
  late final PoseDetectorService _poseDetectorService;
  late final FrameProcessor _frameProcessor;
  late final MotionProcessor _motionProcessor;

  DetectedPose? _currentPose;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showSkeleton = true;
  bool _showDebugHUD = false;
  int _detectedJointsCount = 0;
  Color _skeletonColor = Colors.white;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraService = CameraService();
    _poseDetectorService = PoseDetectorService();
    _frameProcessor = FrameProcessor(minIntervalMs: 33); // ~30 FPS throttle
    _motionProcessor = MotionProcessor();

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _cameraService.initialize();
      await _startStream();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Gagal membuka kamera: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    }
  }

  Future<void> _startStream() async {
    await _cameraService.startImageStream((CameraImage image) async {
      final camera = _cameraService.currentCamera;
      if (camera == null) return;

      // Jalankan frame processor dengan throttling
      final detectedPose = await _frameProcessor.processFrame<DetectedPose>(
        cameraImage: image,
        cameraDescription: camera,
        onProcess: (inputImage) async {
          return await _poseDetectorService.processImage(
            inputImage: inputImage,
            isFrontCamera: _cameraService.isFrontCamera,
          );
        },
      );

      if (detectedPose != null && mounted) {
        final validJoints = detectedPose.landmarks.values
            .where((lm) => lm.isValid(0.5))
            .length;

        final analysis = _motionProcessor.processPose(detectedPose);
        final color = analysis.validationStatus == MotionValidationStatus.valid
            ? AppColors.success
            : (analysis.validationStatus == MotionValidationStatus.outOfRange
                ? AppColors.warning
                : AppColors.primary);

        setState(() {
          _currentPose = detectedPose;
          _detectedJointsCount = validJoints;
          _skeletonColor = color;
        });
      }
    });
  }

  Future<void> _switchCamera() async {
    setState(() {
      _currentPose = null;
      _detectedJointsCount = 0;
    });
    _frameProcessor.reset();

    await _cameraService.switchCamera((image) async {
      final camera = _cameraService.currentCamera;
      if (camera == null) return;

      final detectedPose = await _frameProcessor.processFrame<DetectedPose>(
        cameraImage: image,
        cameraDescription: camera,
        onProcess: (inputImage) async {
          return await _poseDetectorService.processImage(
            inputImage: inputImage,
            isFrontCamera: _cameraService.isFrontCamera,
          );
        },
      );

      if (detectedPose != null && mounted) {
        final validJoints = detectedPose.landmarks.values
            .where((lm) => lm.isValid(0.5))
            .length;

        setState(() {
          _currentPose = detectedPose;
          _detectedJointsCount = validJoints;
        });
      }
    });

    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraService.stopImageStream();
    } else if (state == AppLifecycleState.resumed) {
      _startStream();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    _poseDetectorService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingOverlay(
        message: 'Menyiapkan kamera & Pose Detector...',
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kamera')),
        body: ErrorState(
          title: 'Akses Kamera Gagal',
          message: _errorMessage,
          retryLabel: 'Coba Lagi',
          onRetry: _initializeCamera,
        ),
      );
    }

    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: Text('Kamera tidak tersedia')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Live Camera Preview + Skeleton Overlay
            Positioned.fill(
              child: CameraPreviewWidget(
                controller: controller,
                pose: _currentPose,
                showSkeleton: _showSkeleton,
                showDebugHUD: _showDebugHUD,
                skeletonColor: _skeletonColor,
              ),
            ),

            // 2. Top Bar Controls
            Positioned(
              top: AppSpacing.lg,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  AppIconButton(
                    icon: Icons.arrow_back_rounded,
                    variant: AppIconButtonVariant.filled,
                    onPressed: () => context.pop(),
                  ),

                  // Actions Group
                  Row(
                    children: [
                      // Toggle Skeleton Button
                      AppIconButton(
                        icon: _showSkeleton
                            ? Icons.accessibility_new_rounded
                            : Icons.accessibility_rounded,
                        variant: _showSkeleton
                            ? AppIconButtonVariant.filled
                            : AppIconButtonVariant.outlined,
                        tooltip: 'Toggle Skeleton',
                        onPressed: () {
                          setState(() {
                            _showSkeleton = !_showSkeleton;
                          });
                        },
                      ),
                      Gap(AppSpacing.sm),
                      // Switch Camera (Front/Back)
                      AppIconButton(
                        icon: Icons.cameraswitch_rounded,
                        variant: AppIconButtonVariant.filled,
                        tooltip: 'Ganti Kamera',
                        onPressed: _switchCamera,
                      ),
                      Gap(AppSpacing.sm),
                      // Toggle Debug HUD Button
                      AppIconButton(
                        icon: Icons.bug_report_rounded,
                        variant: _showDebugHUD
                            ? AppIconButtonVariant.filled
                            : AppIconButtonVariant.outlined,
                        tooltip: 'Toggle Debug Overlay',
                        onPressed: () {
                          setState(() {
                            _showDebugHUD = !_showDebugHUD;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Bottom Status Overlay
            Positioned(
              bottom: AppSpacing.xl,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: Container(
                padding: AppSpacing.paddingAllLg,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withValues(alpha: 0.8),
                  borderRadius: AppRadius.borderRadiusLg,
                  border: Border.all(
                    color: _detectedJointsCount > 0
                        ? AppColors.primary
                        : AppColors.outlineDark,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _detectedJointsCount > 0
                          ? Icons.check_circle_rounded
                          : Icons.center_focus_weak_rounded,
                      color: _detectedJointsCount > 0
                          ? AppColors.primary
                          : AppColors.warning,
                      size: 24,
                    ),
                    Gap(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _detectedJointsCount > 0
                                ? 'Pose Terdeteksi ($_detectedJointsCount sendi)'
                                : 'Memindai pose tubuh...',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.onSurfaceDark,
                            ),
                          ),
                          Gap(AppSpacing.xxs),
                          Text(
                            _cameraService.isFrontCamera
                                ? 'Kamera Depan • ML Kit Pose Stream'
                                : 'Kamera Belakang • ML Kit Pose Stream',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.onSurfaceVariantDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
