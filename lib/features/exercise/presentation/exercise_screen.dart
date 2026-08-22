import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../analytics/data/repositories/workout_history_repository_impl.dart';
import '../../analytics/models/workout_session.dart';
import '../../camera/models/detected_pose.dart';
import '../../camera/presentation/camera_preview_widget.dart';
import '../../camera/services/camera_pose_stream_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading/loading_overlay.dart';
import '../../../shared/widgets/states/error_state.dart';
import '../domain/exercise_result.dart';
import '../domain/exercise_type.dart';
import '../exercises/arm_raise_engine.dart';
import '../exercises/base_exercise_engine.dart';
import '../exercises/bicep_curl_engine.dart';
import '../exercises/neck_rotation_engine.dart';
import '../logic/seated_posture_validator.dart';
import 'widgets/exercise_guide_overlay.dart';
import 'widgets/feedback_banner.dart';
import 'widgets/pose_overlay.dart';
import 'widgets/repetition_hud.dart';
import 'widgets/rest_timer_dialog.dart';

/// Halaman Sesi Latihan Utama AI Computer Vision (ExerciseScreen).
///
/// MENYATUKAN:
/// 1. Real-time Camera Preview & ML Kit Pose Stream
/// 2. Skeleton Pose Overlay (Visualisasi sendi & garis tubuh)
/// 3. Exercise Guide Overlay Transparan (Transisi animasi per MovementPhase)
/// 4. Repetition HUD & Feedback Banner Real-Time
/// 5. Engine Analisis spesifik (Side Arm Raise, Bicep Curl, Neck Rotation)
/// 6. Dialog Hasil Sesi Latihan & Penyimpanan Lokal Offline
class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({
    super.key,
    required this.exerciseType,
  });

  final ExerciseType exerciseType;

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen>
    with WidgetsBindingObserver {
  late final CameraPoseStreamController _cameraStreamController;
  late final BaseExerciseEngine _engine;

  DetectedPose? _currentPose;
  bool _isLoading = true;
  bool _showGuide = true;
  bool _showDebugHUD = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraStreamController = CameraPoseStreamController(minIntervalMs: 33);

    // Instansiasi engine sesuai jenis latihan yang dipilih
    switch (widget.exerciseType) {
      case ExerciseType.sideArmRaise:
        _engine = ArmRaiseEngine();
        break;
      case ExerciseType.bicepCurl:
        _engine = BicepCurlEngine();
        break;
      case ExerciseType.neckRotation:
        _engine = NeckRotationEngine();
        break;
    }

    _engine.addListener(_onEngineStateChanged);
    _initializeCamera();
  }

  void _onEngineStateChanged() {
    if (mounted) {
      setState(() {});

      // Tampilkan dialog hasil saat latihan telah selesai
      if (_engine.isCompleted) {
        _saveAndShowSummary();
      }
    }
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
          _errorMessage = 'Gagal membuka kamera: ${e.toString().replaceAll('Exception: ', '')}';
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

        // Teruskan data landmark pose ke Engine Latihan
        _engine.processFrame(detectedPose.landmarks.values.toList());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraStreamController.cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraStreamController.stopStream();
      _engine.pause();
    } else if (state == AppLifecycleState.resumed) {
      _startStream();
      _engine.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _engine.removeListener(_onEngineStateChanged);
    _engine.ttsService.stop();
    _cameraStreamController.dispose();
    super.dispose();
  }

  Future<void> _saveAndShowSummary() async {
    final summary = _engine.generateSummary();

    // Simpan hasil ke database lokal ObjectBox (offline-first)
    try {
      final repo = ref.read(workoutHistoryRepositoryProvider);
      final session = WorkoutSession(
        workoutId: summary.exerciseType.id,
        workoutName: summary.exerciseType.displayName,
        startTime: summary.startedAt,
        durationInSeconds: summary.durationInSeconds,
        caloriesBurned: summary.completedReps * 1.8,
        completedReps: summary.completedReps,
        targetReps: summary.targetReps,
        accuracy: summary.averageAccuracy,
        averageRom: 85.0,
        isCompleted: true,
        recoveryScore: 90,
      );

      await repo.saveWorkoutSession(session);
    } catch (_) {}

    if (mounted) {
      _showSummaryDialog(context, summary);
    }
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
        appBar: AppBar(title: Text(widget.exerciseType.displayName)),
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Layer Kamera Fisik Full Screen Edge-to-Edge (100% Opacity)
          Positioned.fill(
            child: CameraPreviewWidget(
              controller: cameraController,
              pose: _currentPose,
              showSkeleton: false, // Digantikan PoseOverlay kustom di atas guide
            ),
          ),

          // 2. Layer Overlay Gambar Panduan 9:16 Transparan (Ghost Guide ~43-45% Opacity)
          Positioned.fill(
            child: ExerciseGuideOverlay(
              exerciseType: widget.exerciseType,
              phase: _engine.currentPhase,
              isVisible: _showGuide,
            ),
          ),

          // 3. Layer Overlay Skeleton Sendi Tubuh High-Contrast (100% Opacity)
          Positioned.fill(
            child: PoseOverlay(
              pose: _currentPose,
              postureState: _engine.postureState,
              color: _engine.currentAccuracy > 80
                  ? Colors.white
                  : _engine.currentAccuracy > 60
                      ? Colors.amberAccent
                      : Colors.orangeAccent,
              showDebugHUD: _showDebugHUD,
            ),
          ),

          // 4. Top HUD Display (Set, Reps, Accuracy %) & Back Navigation Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Bar Translusen Ringan (Light Translucent)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
                            onPressed: () => _showExitDialog(context),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.exerciseType.displayName,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.88),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.bug_report_rounded,
                                  color: _showDebugHUD ? AppColors.secondaryDark : AppColors.onSurfaceVariant,
                                  size: 18,
                                ),
                                tooltip: 'Toggle Debug HUD',
                                onPressed: () {
                                  setState(() {
                                    _showDebugHUD = !_showDebugHUD;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.88),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _showGuide ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: _showGuide ? AppColors.primaryDark : AppColors.onSurfaceVariant,
                                ),
                                tooltip: _showGuide ? 'Sembunyikan Panduan' : 'Tampilkan Panduan',
                                onPressed: () {
                                  setState(() {
                                    _showGuide = !_showGuide;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Peringatan Postur Berdiri Light Theme (Jika User Berdiri)
                  if (_engine.postureState == UserPostureState.standing)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade700, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Posisi Tidak Sesuai — Silakan Lakukan Latihan dalam Posisi Duduk',
                              style: TextStyle(color: Colors.amber.shade900, fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                  RepetitionHud(
                    exerciseType: widget.exerciseType,
                    currentSet: _engine.currentSet,
                    totalSets: _engine.totalSets,
                    completedReps: _engine.completedReps,
                    targetReps: _engine.targetReps,
                    accuracyPercentage: _engine.currentAccuracy,
                  ),
                ],
              ),
            ),
          ),

          // 5. Banner Umpan Balik Teks & Koreksi Real-time
          Positioned(
            bottom: 95,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: FeedbackBanner(
                  feedback: _engine.currentFeedback,
                ),
              ),
            ),
          ),

          // 6. Bilah Kontrol Bawah Light Translucent (Pause/Resume, Toggle Guide, Stop)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute/Unmute Suara TTS
                    IconButton(
                      icon: Icon(
                        _engine.ttsService.isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: AppColors.onSurface,
                      ),
                      onPressed: () {
                        setState(() {
                          _engine.ttsService.toggleMute();
                        });
                      },
                    ),

                    // Toggle Gambar Panduan Transparan
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showGuide = !_showGuide;
                        });
                      },
                      icon: Icon(
                        _showGuide ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: _showGuide ? AppColors.primaryDark : AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                      label: Text(
                        _showGuide ? 'Panduan ON' : 'Panduan OFF',
                        style: TextStyle(
                          color: _showGuide ? AppColors.primaryDark : AppColors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Pause / Resume Session (Tombol Akselerasi Primary)
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _engine.isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_engine.isPaused) {
                              _engine.resume();
                            } else {
                              _engine.pause();
                            }
                          });
                        },
                      ),
                    ),

                    // Selesaikan / Stop Session
                    IconButton(
                      icon: const Icon(
                        Icons.stop_rounded,
                        color: AppColors.error,
                        size: 26,
                      ),
                      onPressed: () => _saveAndShowSummary(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Rest Timer Dialog (Saat Istirahat Antar-Set)
          if (_engine.isResting)
            Positioned.fill(
              child: RestTimerDialog(
                currentSet: _engine.currentSet,
                totalSets: _engine.totalSets,
                secondsRemaining: _engine.restSecondsRemaining,
                onSkip: () => _engine.skipRest(),
              ),
            ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    _engine.pause();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hentikan Sesi Latihan?', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
        content: const Text(
          'Progres sesi ini akan disimpan sebagian. Yakin ingin keluar?',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _engine.resume();
            },
            child: const Text('Lanjutkan', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSummaryDialog(BuildContext context, ExerciseSessionSummary summary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉 LATIHAN SELESAI 🎉', style: TextStyle(color: AppColors.primaryDark, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(summary.exerciseType.displayName, style: const TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildSummaryRow('Total Set', '${summary.completedSets} / ${summary.totalSets}'),
              _buildSummaryRow('Total Repetisi', '${summary.completedReps} Reps'),
              _buildSummaryRow('Rata-rata Akurasi', '${summary.averageAccuracy.toStringAsFixed(1)}%'),
              _buildSummaryRow('Durasi Sesi', '${summary.durationInSeconds} Detik'),
              _buildSummaryRow('Jumlah Koreksi', '${summary.totalCorrectionsCount} Kali'),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('Selesai & Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.primaryDark, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
