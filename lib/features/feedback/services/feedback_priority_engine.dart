import '../models/feedback_message.dart';

/// Engine penyaring dan pengurut pesan feedback berdasarkan hirarki prioritas.
class FeedbackPriorityEngine {
  const FeedbackPriorityEngine();

  /// Mengurutkan daftar pesan dari prioritas tertinggi ke terendah.
  List<FeedbackMessage> sortMessages(List<FeedbackMessage> messages) {
    final sorted = List<FeedbackMessage>.from(messages);
    sorted.sort((a, b) {
      final priorityComp = b.priority.value.compareTo(a.priority.value);
      if (priorityComp != 0) return priorityComp;
      return b.timestamp.compareTo(a.timestamp);
    });
    return sorted;
  }

  /// Mengambil pesan dengan prioritas utama (tertinggi).
  ///
  /// Jika terdapat pesan bermerek `critical` atau `high`, pesan berperingkat `low`
  /// akan otomatis diabaikan agar tidak mengganggu perhatian pengguna.
  FeedbackMessage? selectPrimaryMessage(List<FeedbackMessage> messages) {
    if (messages.isEmpty) return null;

    final sorted = sortMessages(messages);
    final top = sorted.first;

    return top;
  }
}
