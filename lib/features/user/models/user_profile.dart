import 'package:objectbox/objectbox.dart';

@Entity()
class UserProfile {
  @Id()
  int id;

  final String displayName;
  final String? email;
  final String? photoUrl;
  final String gender;

  @Property(type: PropertyType.date)
  final DateTime birthDate;

  final double height;
  final double weight;
  final String wheelchairType;
  final String mobilityLevel;
  final String dominantHand;
  final String rehabilitationGoal;
  final String medicalNotes;

  @Property(type: PropertyType.date)
  final DateTime createdAt;

  @Property(type: PropertyType.date)
  final DateTime updatedAt;

  @Property(type: PropertyType.date)
  final DateTime? lastSync;

  final String syncStatus;
  final bool isGuest;
  final bool isActive;

  UserProfile({
    this.id = 0,
    required this.displayName,
    this.email,
    this.photoUrl,
    required this.gender,
    required this.birthDate,
    required this.height,
    required this.weight,
    required this.wheelchairType,
    required this.mobilityLevel,
    required this.dominantHand,
    required this.rehabilitationGoal,
    required this.medicalNotes,
    required this.createdAt,
    required this.updatedAt,
    this.lastSync,
    required this.syncStatus,
    required this.isGuest,
    required this.isActive,
  });

  UserProfile copyWith({
    int? id,
    String? displayName,
    String? email,
    String? photoUrl,
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? wheelchairType,
    String? mobilityLevel,
    String? dominantHand,
    String? rehabilitationGoal,
    String? medicalNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSync,
    String? syncStatus,
    bool? isGuest,
    bool? isActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      wheelchairType: wheelchairType ?? this.wheelchairType,
      mobilityLevel: mobilityLevel ?? this.mobilityLevel,
      dominantHand: dominantHand ?? this.dominantHand,
      rehabilitationGoal: rehabilitationGoal ?? this.rehabilitationGoal,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSync: lastSync ?? this.lastSync,
      syncStatus: syncStatus ?? this.syncStatus,
      isGuest: isGuest ?? this.isGuest,
      isActive: isActive ?? this.isActive,
    );
  }
}
