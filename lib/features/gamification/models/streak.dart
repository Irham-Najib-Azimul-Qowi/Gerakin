import 'package:objectbox/objectbox.dart';

@Entity()
class Streak {
  @Id()
  int id;

  final int userId;
  final int currentStreak;
  final int longestStreak;

  @Property(type: PropertyType.date)
  final DateTime lastActiveDate;

  Streak({
    this.id = 0,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
  });

  Streak copyWith({
    int? id,
    int? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
  }) {
    return Streak(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
