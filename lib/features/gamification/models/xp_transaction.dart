import 'package:objectbox/objectbox.dart';

@Entity()
class XPTransaction {
  @Id()
  int id;

  final int userId;
  final int amount;
  final String source; // e.g., 'workout_completion', 'mission_daily', 'challenge_weekly'

  @Property(type: PropertyType.date)
  final DateTime createdAt;

  XPTransaction({
    this.id = 0,
    required this.userId,
    required this.amount,
    required this.source,
    required this.createdAt,
  });
}
