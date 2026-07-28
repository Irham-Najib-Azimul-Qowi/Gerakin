class WorkoutStatistics {
  final int totalSessions;
  final double totalDurationInMinutes;
  final double totalCalories;
  final double averageAccuracy;
  final double averageRom;
  final double completionRate;

  WorkoutStatistics({
    required this.totalSessions,
    required this.totalDurationInMinutes,
    required this.totalCalories,
    required this.averageAccuracy,
    required this.averageRom,
    required this.completionRate,
  });

  factory WorkoutStatistics.empty() {
    return WorkoutStatistics(
      totalSessions: 0,
      totalDurationInMinutes: 0.0,
      totalCalories: 0.0,
      averageAccuracy: 0.0,
      averageRom: 0.0,
      completionRate: 0.0,
    );
  }
}
