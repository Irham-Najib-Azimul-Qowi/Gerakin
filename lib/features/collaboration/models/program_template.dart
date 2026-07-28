import 'package:objectbox/objectbox.dart';

@Entity()
class ProgramTemplate {
  @Id()
  int id;

  final String title;
  final String description;
  final String exerciseIdsJson;
  final String category; // e.g., 'stroke_rehab', 'shoulder_injury', 'general_cardio'

  ProgramTemplate({
    this.id = 0,
    required this.title,
    required this.description,
    required this.exerciseIdsJson,
    required this.category,
  });
}
