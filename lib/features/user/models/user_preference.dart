import 'package:objectbox/objectbox.dart';

@Entity()
class UserPreference {
  @Id()
  int id;

  final int userId;
  final String themeMode; // 'light', 'dark', 'system'
  final bool enableAudioCues;
  final bool enableTts;
  final String dailyReminderTime; // e.g., "08:00"

  UserPreference({
    this.id = 0,
    required this.userId,
    required this.themeMode,
    required this.enableAudioCues,
    required this.enableTts,
    required this.dailyReminderTime,
  });

  UserPreference copyWith({
    int? id,
    int? userId,
    String? themeMode,
    bool? enableAudioCues,
    bool? enableTts,
    String? dailyReminderTime,
  }) {
    return UserPreference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      enableAudioCues: enableAudioCues ?? this.enableAudioCues,
      enableTts: enableTts ?? this.enableTts,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }
}
