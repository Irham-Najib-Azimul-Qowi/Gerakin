import 'package:flutter/material.dart';
import '../models/detected_pose.dart';
import '../services/coordinate_mapper.dart';
import 'debug_overlay.dart';
import 'pose_renderer.dart';
import 'skeleton_painter.dart';

/// Top-Level Container Widget untuk Rendering Overlay Skeleton & Diagnostics.
class PoseOverlay extends StatefulWidget {
  const PoseOverlay({
    super.key,
    required this.pose,
    this.fit = BoxFit.cover,
    this.minConfidence = 0.25,
    this.showDebugHUD = false,
    this.fps = 60.0,
    this.skeletonColor = Colors.white,
    this.alpha = 0.45,
  });

  final DetectedPose? pose;
  final BoxFit fit;
  final double minConfidence;
  final bool showDebugHUD;
  final double fps;
  final Color skeletonColor;
  final double alpha;

  @override
  State<PoseOverlay> createState() => _PoseOverlayState();
}

class _PoseOverlayState extends State<PoseOverlay> {
  late final PoseRenderer _renderer;

  @override
  void initState() {
    super.initState();
    _renderer = PoseRenderer(alpha: widget.alpha);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pose == null) return const SizedBox.shrink();
    final pose = widget.pose!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        final metrics = CoordinateMapper.computeMetrics(
          rawImageSize: pose.imageSize,
          canvasSize: canvasSize,
          rotation: pose.rotation,
          isFrontCamera: pose.isFrontCamera,
          fit: widget.fit,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: SkeletonPainter(
                pose: pose,
                metrics: metrics,
                renderer: _renderer,
                minConfidence: widget.minConfidence,
                skeletonColor: widget.skeletonColor,
              ),
              child: const SizedBox.expand(),
            ),

            if (widget.showDebugHUD)
              DebugOverlay(
                metrics: metrics,
                detectedJointsCount: pose.landmarks.length,
                fps: widget.fps,
              ),
          ],
        );
      },
    );
  }
}
