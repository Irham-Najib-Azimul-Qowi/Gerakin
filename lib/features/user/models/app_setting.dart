import 'package:objectbox/objectbox.dart';

@Entity()
class AppSetting {
  @Id()
  int id;

  final String languageCode; // 'id', 'en'
  final bool isOfflineMode;

  @Property(type: PropertyType.date)
  final DateTime? lastBackupDate;

  AppSetting({
    this.id = 0,
    required this.languageCode,
    required this.isOfflineMode,
    this.lastBackupDate,
  });

  AppSetting copyWith({
    int? id,
    String? languageCode,
    bool? isOfflineMode,
    DateTime? lastBackupDate,
  }) {
    return AppSetting(
      id: id ?? this.id,
      languageCode: languageCode ?? this.languageCode,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }
}
