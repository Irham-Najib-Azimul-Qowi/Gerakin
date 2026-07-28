import 'package:objectbox/objectbox.dart';

@Entity()
class UserRole {
  @Id()
  int id;

  final int userId;
  final String role; // 'patient' | 'physiotherapist' | 'caregiver' | 'admin'

  UserRole({
    this.id = 0,
    required this.userId,
    required this.role,
  });
}
