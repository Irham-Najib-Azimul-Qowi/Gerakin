class WeeklySummary {
  final DateTime startDate;
  final DateTime endDate;
  final int totalSessions;
  final double totalDurationInMinutes;
  final double totalCalories;
  final double averageAccuracy;
  final double averageRom;
  final List<int> dailySessionCounts; // Mon-Sun index (0-6)
  final List<double> dailyAccuracy;     // Mon-Sun accuracy averages
  final List<double> dailyRom;          // Mon-Sun ROM averages

  WeeklySummary({
    required this.startDate,
    required this.endDate,
    required this.totalSessions,
    required this.totalDurationInMinutes,
    required this.totalCalories,
    required this.averageAccuracy,
    required this.averageRom,
    required this.dailySessionCounts,
    required this.dailyAccuracy,
    required this.dailyRom,
  });

  factory WeeklySummary.empty(DateTime start, DateTime end) {
    return WeeklySummary(
      startDate: start,
      endDate: end,
      totalSessions: 0,
      totalDurationInMinutes: 0.0,
      totalCalories: 0.0,
      averageAccuracy: 0.0,
      averageRom: 0.0,
      dailySessionCounts: List.filled(7, 0),
      dailyAccuracy: List.filled(7, 0.0),
      dailyRom: List.filled(7, 0.0),
    );
  }
}
