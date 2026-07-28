class MonthlySummary {
  final int year;
  final int month;
  final int totalSessions;
  final double totalDurationInMinutes;
  final double totalCalories;
  final double averageAccuracy;
  final double averageRom;
  final List<double> weeklyAccuracy; // Average accuracy for each week of the month
  final List<double> weeklyRom;      // Average ROM for each week of the month

  MonthlySummary({
    required this.year,
    required this.month,
    required this.totalSessions,
    required this.totalDurationInMinutes,
    required this.totalCalories,
    required this.averageAccuracy,
    required this.averageRom,
    required this.weeklyAccuracy,
    required this.weeklyRom,
  });

  factory MonthlySummary.empty(int year, int month) {
    return MonthlySummary(
      year: year,
      month: month,
      totalSessions: 0,
      totalDurationInMinutes: 0.0,
      totalCalories: 0.0,
      averageAccuracy: 0.0,
      averageRom: 0.0,
      weeklyAccuracy: const [],
      weeklyRom: const [],
    );
  }
}
