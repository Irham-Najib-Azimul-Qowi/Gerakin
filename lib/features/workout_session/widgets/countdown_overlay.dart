import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Overlay hitung mundur (3, 2, 1, Mulai!) dengan animasi skala & suara.
class CountdownOverlay extends StatefulWidget {
  const CountdownOverlay({
    super.key,
    required this.onCountdownComplete,
  });

  final VoidCallback onCountdownComplete;

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> with SingleTickerProviderStateMixin {
  int _counter = 3;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.3, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _startTimer();
  }

  void _startTimer() {
    _animController.forward(from: 0.0);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 1) {
        if (mounted) {
          setState(() {
            _counter -= 1;
          });
          _animController.forward(from: 0.0);
        }
      } else if (_counter == 1) {
        if (mounted) {
          setState(() {
            _counter = 0; // "MULAI!"
          });
          _animController.forward(from: 0.0);
        }
      } else {
        timer.cancel();
        widget.onCountdownComplete();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
            decoration: BoxDecoration(
              color: AppColors.workoutSurfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.workoutAccentGreen, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.workoutAccentGreen.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text(
              _counter > 0 ? '$_counter' : 'MULAI!',
              style: TextStyle(
                color: _counter > 0 ? Colors.white : AppColors.workoutAccentGreen,
                fontSize: _counter > 0 ? 72 : 48,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
