import '../models/workout_state.dart';

/// Service pengatur navigasi & alur (Workflow Step Manager).
class WorkoutFlowManager {
  WorkoutFlowManager();

  WorkoutState _currentState = WorkoutState.idle;

  WorkoutState get currentState => _currentState;

  void transitionTo(WorkoutState newState) {
    _currentState = newState;
  }

  bool canTransitionTo(WorkoutState targetState) {
    // Validasi alur transisi state machine
    switch (_currentState) {
      case WorkoutState.idle:
        return targetState == WorkoutState.preparing || targetState == WorkoutState.calibrating;
      case WorkoutState.preparing:
        return targetState == WorkoutState.calibrating || targetState == WorkoutState.cancelled;
      case WorkoutState.calibrating:
        return targetState == WorkoutState.ready || targetState == WorkoutState.cancelled;
      case WorkoutState.ready:
        return targetState == WorkoutState.countdown || targetState == WorkoutState.cancelled;
      case WorkoutState.countdown:
        return targetState == WorkoutState.workout || targetState == WorkoutState.cancelled;
      case WorkoutState.workout:
        return targetState == WorkoutState.rest ||
            targetState == WorkoutState.paused ||
            targetState == WorkoutState.completed ||
            targetState == WorkoutState.cancelled;
      case WorkoutState.rest:
        return targetState == WorkoutState.workout || targetState == WorkoutState.completed;
      case WorkoutState.paused:
        return targetState == WorkoutState.workout || targetState == WorkoutState.cancelled;
      case WorkoutState.completed:
      case WorkoutState.cancelled:
      case WorkoutState.error:
        return targetState == WorkoutState.idle || targetState == WorkoutState.preparing;
    }
  }
}
