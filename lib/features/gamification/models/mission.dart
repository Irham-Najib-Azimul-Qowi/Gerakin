import 'package:objectbox/objectbox.dart';

@Entity()
class Mission {
  @Id()
  int id;

  final String title;
  final String description;
  final int xpReward;
  final bool isCompleted;
  final String type; // 'daily'
  final double targetValue;
  final double currentValue;

  @Property(type: PropertyType.date)
  final DateTime createdAt;

  Mission({
    this.id = 0,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.isCompleted,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.createdAt,
  });

  Mission copyWith({
    int? id,
    String? title,
    String? description,
    int? xpReward,
    bool? isCompleted,
    String? type,
    double? targetValue,
    double? currentValue,
    DateTime? createdAt,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
