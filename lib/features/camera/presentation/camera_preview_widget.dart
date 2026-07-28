import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../models/detected_pose.dart';
import 'skeleton_overlay.dart';

/// Widget pembungkus CameraPreview dan SkeletonOverlay.
///
/// Menyesuaikan aspect ratio kamera dengan aspect ratio layar agar tidak terdistorsi (gepeng/melar).
class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({
    super.key,
    required this.controller,
    required this.pose,
    this.showSkeleton = true,
    this.showDebugHUD = false,
  });

  final CameraController controller;
  final DetectedPose? pose;
  final bool showSkeleton;
  final bool showDebugHUD;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Camera Preview
            CameraPreview(controller),

            // 2. Realtime Skeleton Overlay & Debug HUD
            if (showSkeleton && pose != null)
              SkeletonOverlay(
                pose: pose,
                showDebugHUD: showDebugHUD,
              ),
          ],
        );
      },
    );
  }
}
