import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State untuk mengontrol Mode Demo Presentasi KMIPN.
class DemoModeState {
  final bool isDemoActive;
  final double simulatedAngle;
  final double simulatedConfidence;
  final double simulatedFps;

  DemoModeState({
    required this.isDemoActive,
    required this.simulatedAngle,
    required this.simulatedConfidence,
    required this.simulatedFps,
  });

  DemoModeState copyWith({
    bool? isDemoActive,
    double? simulatedAngle,
    double? simulatedConfidence,
    double? simulatedFps,
  }) {
    return DemoModeState(
      isDemoActive: isDemoActive ?? this.isDemoActive,
      simulatedAngle: simulatedAngle ?? this.simulatedAngle,
      simulatedConfidence: simulatedConfidence ?? this.simulatedConfidence,
      simulatedFps: simulatedFps ?? this.simulatedFps,
    );
  }
}

/// Layanan simulasi sensor visual dan data pose real-time untuk presentasi juri KMIPN.
class DemoModeService extends Notifier<DemoModeState> {
  Timer? _simulationTimer;

  @override
  DemoModeState build() {
    return DemoModeState(
      isDemoActive: false,
      simulatedAngle: 90.0,
      simulatedConfidence: 0.98,
      simulatedFps: 60.0,
    );
  }

  /// Mengaktifkan atau menonaktifkan simulasi mode demo.
  void toggleDemoMode() {
    final nextState = !state.isDemoActive;
    state = state.copyWith(isDemoActive: nextState);

    if (nextState) {
      _startSimulation();
    } else {
      _stopSimulation();
    }
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
    double currentAngle = 45.0;
    bool increasing = true;

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (increasing) {
        currentAngle += 3.0;
        if (currentAngle >= 165.0) increasing = false;
      } else {
        currentAngle -= 3.0;
        if (currentAngle <= 45.0) increasing = true;
      }

      state = state.copyWith(
        simulatedAngle: currentAngle,
        simulatedConfidence: 0.96 + (currentAngle % 3) * 0.01,
        simulatedFps: 60.0,
      );
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }
}

/// Provider untuk instansiasi [DemoModeService].
final demoModeServiceProvider = NotifierProvider<DemoModeService, DemoModeState>(
  DemoModeService.new,
);
