import 'package:objectbox/objectbox.dart';

@Entity()
class MotivationMessage {
  @Id()
  int id;

  final String message;
  final String category; // e.g., 'rehabilitation', 'milestone', 'daily'

  MotivationMessage({
    this.id = 0,
    required this.message,
    required this.category,
  });
}
