import 'package:flutter/material.dart';

/// Progress ring/bar indikator durasi hold posisi puncak (Isometric Hold).
class HoldProgressBar extends StatelessWidget {
  const HoldProgressBar({
    super.key,
    required this.progress,
    required this.isHolding,
  });

  final double progress;
  final bool isHolding;

  @override
  Widget build(BuildContext context) {
    if (!isHolding && progress <= 0) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_outlined, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              'TAHAN POSISI (${(progress * 100).toInt()}%)',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: 200,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
        ),
      ],
    );
  }
}
