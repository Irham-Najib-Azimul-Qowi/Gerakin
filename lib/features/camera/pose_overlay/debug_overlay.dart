import 'package:flutter/material.dart';
import '../services/coordinate_mapper.dart';

/// Overlay HUD Diagnostik Komputer Visi untuk Inspeksi Real-Time Transformasi Koordinat.
class DebugOverlay extends StatelessWidget {
  const DebugOverlay({
    super.key,
    required this.metrics,
    required this.detectedJointsCount,
    required this.fps,
  });

  final CoordinateTransformMetrics metrics;
  final int detectedJointsCount;
  final double fps;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      top: 70,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.6), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CV POSE DIAGNOSTICS HUD',
              style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _buildRow('Image Size', '${metrics.rawImageSize.width.toInt()}x${metrics.rawImageSize.height.toInt()}'),
            _buildRow('Preview Size', '${metrics.effectivePreviewSize.width.toInt()}x${metrics.effectivePreviewSize.height.toInt()}'),
            _buildRow('Canvas Size', '${metrics.canvasSize.width.toInt()}x${metrics.canvasSize.height.toInt()}'),
            _buildRow('Rotation', metrics.rotation.name),
            _buildRow('Scale (X/Y)', '${metrics.scaleX.toStringAsFixed(2)} / ${metrics.scaleY.toStringAsFixed(2)} (${metrics.scale.toStringAsFixed(2)})'),
            _buildRow('Offset (X/Y)', '${metrics.offsetX.toStringAsFixed(1)} / ${metrics.offsetY.toStringAsFixed(1)}'),
            _buildRow('Mirror Front', metrics.isFrontCamera ? 'YES' : 'NO'),
            _buildRow('Frame FPS', '${fps.toStringAsFixed(1)} FPS'),
            _buildRow('Landmarks', '$detectedJointsCount joints'),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
          Text(value, style: const TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
