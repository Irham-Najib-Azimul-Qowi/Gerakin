import 'package:objectbox/objectbox.dart';

@Entity()
class WheelchairProfile {
  @Id()
  int id;

  final int userId;
  final String wheelchairType; // 'manual', 'power', 'none'
  final String axlePosition; // 'standard', 'active', 'stable'
  final bool hasAntiTippers;

  WheelchairProfile({
    this.id = 0,
    required this.userId,
    required this.wheelchairType,
    required this.axlePosition,
    required this.hasAntiTippers,
  });

  WheelchairProfile copyWith({
    int? id,
    int? userId,
    String? wheelchairType,
    String? axlePosition,
    bool? hasAntiTippers,
  }) {
    return WheelchairProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      wheelchairType: wheelchairType ?? this.wheelchairType,
      axlePosition: axlePosition ?? this.axlePosition,
      hasAntiTippers: hasAntiTippers ?? this.hasAntiTippers,
    );
  }
}
