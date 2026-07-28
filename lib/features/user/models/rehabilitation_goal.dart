import 'package:objectbox/objectbox.dart';

@Entity()
class RehabilitationGoal {
  @Id()
  int id;

  final int userId;
  final String goalType; // 'strength', 'mobility', 'endurance', 'rom'
  final double targetValue;
  final double currentValue;

  @Property(type: PropertyType.date)
  final DateTime deadline;

  RehabilitationGoal({
    this.id = 0,
    required this.userId,
    required this.goalType,
    required this.targetValue,
    required this.currentValue,
    required this.deadline,
  });

  RehabilitationGoal copyWith({
    int? id,
    int? userId,
    String? goalType,
    double? targetValue,
    double? currentValue,
    DateTime? deadline,
  }) {
    return RehabilitationGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalType: goalType ?? this.goalType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      deadline: deadline ?? this.deadline,
    );
  }
}
