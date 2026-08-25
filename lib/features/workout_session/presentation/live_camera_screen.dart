import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/loading/loading_overlay.dart';
import '../../../shared/widgets/states/error_state.dart';
import '../../camera/models/detected_pose.dart';
import '../../camera/presentation/camera_preview_widget.dart';
import '../../camera/services/camera_pose_stream_controller.dart';
import '../../exercise_library/models/full_exercise_definition.dart';
import '../controllers/workout_session_controller.dart';
import '../models/live_alert.dart';
import '../models/movement_phase.dart';
import '../models/workout_state.dart';
import '../widgets/camera_calibration_overlay.dart';
import '../widgets/countdown_overlay.dart';
import '../widgets/dev_debug_overlay.dart';
import '../widgets/exercise_card.dart';
import '../widgets/hold_progress_bar.dart';
import '../widgets/live_alert_banner.dart';
import '../widgets/realtime_coach_bubble.dart';

/// Screen 3: Live Camera Screen (Halaman Terpenting Sesi Latihan Rehabilitasi AI).
///
/// MENGHUBUNGKAN:
/// - [CameraPoseStreamController] untuk image stream kamera & ML Kit Pose Detection real-time.
/// - [WorkoutSessionController] untuk pemrosesan frame, kalibrasi, rep counting, dan alert.
/// - [CameraPreviewWidget] & [SkeletonOverlay] untuk visualisasi skeleton di atas kamera fisik.
class LiveCameraScreen extends ConsumerStatefulWidget {
  const LiveCameraScreen({
    super.key,
    required this.exercise,
  });

  final FullExerciseDefinition exercise;

  @override
  ConsumerState<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends ConsumerState<LiveCameraScreen>
    with WidgetsBindingObserver {
  late final CameraPoseStreamController _cameraStreamController;

  DetectedPose? _currentPose;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraStreamController = CameraPoseStreamController(minIntervalMs: 33);
    _initializeCamera();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(workoutSessionControllerProvider(widget.exercise).notifier)
          .startCalibration();
    });
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _cameraStreamController.initialize();
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
    await _cameraStreamController.startStream((detectedPose) {
      if (mounted) {
        setState(() {
          _currentPose = detectedPose;
        });
        ref
            .read(workoutSessionControllerProvider(widget.exercise).notifier)
            .processFrame(detectedPose.landmarks.values.toList());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraStreamController.cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraStreamController.stopStream();
    } else if (state == AppLifecycleState.resumed) {
      _startStream();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraStreamController.dispose();
    super.dispose();
  }

  Color _alertToSkeletonColor(LiveAlert? alert) {
    if (alert == null) return AppColors.success;
    return alert.severity == AlertSeverity.critical
        ? AppColors.error
        : AppColors.warning;
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
        appBar: AppBar(title: Text(widget.exercise.name)),
        body: ErrorState(
          title: 'Akses Kamera Gagal',
          message: _errorMessage,
          retryLabel: 'Coba Lagi',
          onRetry: _initializeCamera,
        ),
      );
    }

    final cameraController = _cameraStreamController.cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Scaffold(
        body: Center(child: Text('Kamera tidak tersedia')),
      );
    }

    final uiState = ref.watch(workoutSessionControllerProvider(widget.exercise));
    final controller = ref.read(workoutSessionControllerProvider(widget.exercise).notifier);

    // Auto navigate to summary screen when completed
    ref.listen<WorkoutSessionUIState>(
      workoutSessionControllerProvider(widget.exercise),
      (prev, next) {
        if (next.workoutState == WorkoutState.completed && next.summary != null) {
          context.pushReplacement('/workout-session/summary', extra: next.summary);
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Live Camera Preview + Skeleton Overlay
            Positioned.fill(
              child: CameraPreviewWidget(
                controller: cameraController,
                pose: _currentPose,
                showSkeleton: true,
                showDebugHUD: uiState.isDevModeEnabled,
                skeletonColor: _alertToSkeletonColor(uiState.activeAlert),
              ),
            ),

            // 2. Top HUD Exercise Card
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ExerciseCardHUD(
                exerciseName: widget.exercise.name,
                currentRep: uiState.currentRep,
                targetReps: uiState.targetReps,
                currentSet: uiState.currentSet,
                targetSets: uiState.targetSets,
                elapsedSeconds: uiState.elapsedSeconds,
                currentAngle: uiState.currentAngle,
                targetAngle: uiState.targetAngle,
                poseConfidence: uiState.poseConfidence,
              ),
            ),

            // 3. Realtime AI Coach Speech Bubble
            Positioned(
              top: 130,
              left: 0,
              right: 0,
              child: RealtimeCoachBubble(
                message: uiState.currentCoachMessage,
                isMuted: uiState.isMuted,
                onToggleMute: controller.toggleMute,
              ),
            ),

            // 3b. Live Alert Banner (Warning / Critical Visual Alert)
            if (uiState.activeAlert != null)
              Positioned(
                top: 215,
                left: 0,
                right: 0,
                child: LiveAlertBanner(
                  alert: uiState.activeAlert,
                ),
              ),

            // 4. Isometric Hold Progress Ring / Bar
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: HoldProgressBar(
                progress: uiState.holdProgress,
                isHolding: uiState.movementPhase == MovementPhase.hold,
              ),
            ),

            // 5. Developer Debug Overlay
            if (uiState.isDevModeEnabled)
              Positioned(
                top: 210,
                right: 16,
                child: DevDebugOverlay(
                  currentAngle: uiState.currentAngle,
                  targetAngle: uiState.targetAngle,
                  phase: uiState.movementPhase,
                  state: uiState.workoutState,
                  confidence: uiState.poseConfidence,
                  fps: uiState.fps,
                  repCount: uiState.currentRep,
                  setCount: uiState.currentSet,
                  processingTimeMs: uiState.lastProcessingTimeMs,
                  landmarkCount: uiState.landmarks.length,
                ),
              ),

            // 6. Action Control Buttons (Pause, Dev Mode, Emergency Stop, Exit)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.workoutSurfaceDark.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Exit Button
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 28),
                      onPressed: () {
                        _showExitConfirmationDialog(context, controller);
                      },
                    ),

                    // Developer Mode Toggle Button
                    IconButton(
                      icon: Icon(
                        Icons.developer_mode_rounded,
                        color: uiState.isDevModeEnabled ? Colors.cyanAccent : Colors.grey,
                        size: 28,
                      ),
                      onPressed: controller.toggleDevMode,
                    ),

                    // Pause / Resume Button
                    FloatingActionButton(
                      heroTag: 'pause_btn',
                      backgroundColor: AppColors.workoutAccentGreen,
                      foregroundColor: Colors.black,
                      onPressed: () {
                        if (uiState.workoutState == WorkoutState.paused) {
                          controller.resumeWorkout();
                        } else {
                          controller.pauseWorkout();
                        }
                      },
                      child: Icon(
                        uiState.workoutState == WorkoutState.paused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 32,
                      ),
                    ),

                    // Emergency Stop Button
                    IconButton(
                      icon: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 28),
                      onPressed: () {
                        controller.cancelWorkout();
                        context.pop();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 7. Camera Calibration Overlay
            if (uiState.workoutState == WorkoutState.calibrating ||
                uiState.workoutState == WorkoutState.ready)
              CameraCalibrationOverlay(
                calibrationResult: controller.engine.calibrationResult,
                onStartWorkout: controller.startCountdown,
              ),

            // 8. Countdown Overlay (3, 2, 1, Mulai!)
            if (uiState.workoutState == WorkoutState.countdown)
              CountdownOverlay(
                onCountdownComplete: () {
                  controller.startCountdownComplete();
                },
              ),

            // 9. Rest Timer Overlay
            if (uiState.workoutState == WorkoutState.rest)
              _buildRestOverlay(uiState, controller),

            // 10. Paused Modal Overlay
            if (uiState.workoutState == WorkoutState.paused)
              _buildPausedOverlay(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildRestOverlay(WorkoutSessionUIState state, WorkoutSessionController controller) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.workoutCardDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.info, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.self_improvement_rounded, color: AppColors.info, size: 56),
              const SizedBox(height: 12),
              Text(
                'WAKTU ISTIRAHAT SET ${state.currentSet - 1}',
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                '${state.restSecondsRemaining}',
                style: AppTextStyles.displayLarge.copyWith(color: AppColors.info, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text('detik', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.skipRest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('LEWATI ISTIRAHAT (SKIP)', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPausedOverlay(WorkoutSessionController controller) {
    return Container(
      color: Colors.black.withValues(alpha: 0.77),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.workoutCardDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, color: AppColors.workoutAccentGreen, size: 64),
              const SizedBox(height: 12),
              Text('LATIHAN DI-PAUSE', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.resumeWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.workoutAccentGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('LANJUTKAN LATIHAN', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirmationDialog(BuildContext context, WorkoutSessionController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.workoutCardDark,
        title: Text('Keluar dari Latihan?', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
        content: Text(
          'Kemajuan sesi saat ini tidak akan disimpan jika Anda keluar sebelum selesai.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('BATAL', style: AppTextStyles.labelLarge.copyWith(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.cancelWorkout();
              context.pop();
            },
            child: Text('YA, KELUAR', style: AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
