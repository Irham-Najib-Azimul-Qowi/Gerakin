import 'package:flutter/material.dart';

import '../models/detected_pose.dart';
import '../pose_overlay/pose_overlay.dart';

/// Top-level Skeleton Overlay Widget wrapper.
class SkeletonOverlay extends StatelessWidget {
  const SkeletonOverlay({
    super.key,
    required this.pose,
    this.minConfidence = 0.25,
    this.fit = BoxFit.cover,
    this.showDebugHUD = false,
    this.skeletonColor = Colors.white,
    this.alpha = 0.45,
  });

  final DetectedPose? pose;
  final double minConfidence;
  final BoxFit fit;
  final bool showDebugHUD;
  final Color skeletonColor;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return PoseOverlay(
      pose: pose,
      minConfidence: minConfidence,
      fit: fit,
      showDebugHUD: showDebugHUD,
      skeletonColor: skeletonColor,
      alpha: alpha,
    );
  }
}
