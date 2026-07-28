import 'package:objectbox/objectbox.dart';

@Entity()
class Achievement {
  @Id()
  int id;

  @Unique()
  final String achievementId;

  final String title;
  final String description;
  final String iconPath;

  @Property(type: PropertyType.date)
  final DateTime? unlockedAt;

  final bool isUnlocked;
  final double progress; // 0.0 to 1.0
  final double targetValue;
  final double currentValue;

  Achievement({
    this.id = 0,
    required this.achievementId,
    required this.title,
    required this.description,
    required this.iconPath,
    this.unlockedAt,
    required this.isUnlocked,
    required this.progress,
    required this.targetValue,
    required this.currentValue,
  });

  Achievement copyWith({
    int? id,
    String? achievementId,
    String? title,
    String? description,
    String? iconPath,
    DateTime? unlockedAt,
    bool? isUnlocked,
    double? progress,
    double? targetValue,
    double? currentValue,
  }) {
    return Achievement(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}
