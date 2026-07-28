import 'package:objectbox/objectbox.dart';

@Entity()
class FeedbackNote {
  @Id()
  int id;

  final int patientId;
  final int authorId;
  final String authorRole; // 'physiotherapist' | 'caregiver'
  final String note;

  @Property(type: PropertyType.date)
  final DateTime createdAt;

  FeedbackNote({
    this.id = 0,
    required this.patientId,
    required this.authorId,
    required this.authorRole,
    required this.note,
    required this.createdAt,
  });
}
