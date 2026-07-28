import 'workout_set.dart';
import 'workout_summary.dart';
import 'recorded_frame.dart';

/// Representation of a whole Workout Session in GERAKIN Rehabilitation Engine.
class WorkoutSessionData {
  const WorkoutSessionData({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.startTime,
    required this.endTime,
    required this.totalDurationSeconds,
    required this.sets,
    required this.summary,
    this.recordedFrames = const [],
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final DateTime startTime;
  final DateTime endTime;
  final int totalDurationSeconds;
  final List<WorkoutSet> sets;
  final WorkoutSummary summary;
  final List<RecordedFrame> recordedFrames;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalDurationSeconds': totalDurationSeconds,
      'sets': sets.map((s) => s.toJson()).toList(),
      'summary': summary.toJson(),
      'recordedFrames': recordedFrames.map((f) => f.toJson()).toList(),
    };
  }

  factory WorkoutSessionData.fromJson(Map<String, dynamic> json) {
    final rawSets = json['sets'] as List? ?? [];
    final rawFrames = json['recordedFrames'] as List? ?? [];

    return WorkoutSessionData(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalDurationSeconds: (json['totalDurationSeconds'] as num).toInt(),
      sets: rawSets.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>)).toList(),
      summary: WorkoutSummary.fromJson(json['summary'] as Map<String, dynamic>),
      recordedFrames: rawFrames.map((e) => RecordedFrame.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
