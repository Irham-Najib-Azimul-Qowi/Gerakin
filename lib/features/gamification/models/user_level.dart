import 'package:objectbox/objectbox.dart';

@Entity()
class UserLevel {
  @Id()
  int id;

  final int userId;
  final int currentLevel;
  final int currentXP;
  final int nextLevelXP;

  UserLevel({
    this.id = 0,
    required this.userId,
    required this.currentLevel,
    required this.currentXP,
    required this.nextLevelXP,
  });

  UserLevel copyWith({
    int? id,
    int? userId,
    int? currentLevel,
    int? currentXP,
    int? nextLevelXP,
  }) {
    return UserLevel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentLevel: currentLevel ?? this.currentLevel,
      currentXP: currentXP ?? this.currentXP,
      nextLevelXP: nextLevelXP ?? this.nextLevelXP,
    );
  }
}
