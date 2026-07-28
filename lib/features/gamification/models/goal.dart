import 'package:objectbox/objectbox.dart';

@Entity()
class Goal {
  @Id()
  int id;

  final int userId;
  final String title;
  final String targetType; // e.g., 'workout_count', 'active_minutes', 'calories'
  final double targetValue;
  final double currentValue;

  @Property(type: PropertyType.date)
  final DateTime deadline;

  Goal({
    this.id = 0,
    required this.userId,
    required this.title,
    required this.targetType,
    required this.targetValue,
    required this.currentValue,
    required this.deadline,
  });

  Goal copyWith({
    int? id,
    int? userId,
    String? title,
    String? targetType,
    double? targetValue,
    double? currentValue,
    DateTime? deadline,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      deadline: deadline ?? this.deadline,
    );
  }
}
