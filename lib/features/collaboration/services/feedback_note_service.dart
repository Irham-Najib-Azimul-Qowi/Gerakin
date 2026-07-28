import '../domain/repositories/collaboration_repository.dart';
import '../models/feedback_note.dart';

/// Layanan pencatatan dan pembacaan catatan umpan balik (feedback notes).
class FeedbackNoteService {
  final CollaborationRepository _repository;

  FeedbackNoteService(this._repository);

  /// Menambahkan catatan umpan balik baru tentang performa latihan pasien.
  Future<void> addFeedback({
    required int patientId,
    required int authorId,
    required String authorRole,
    required String note,
  }) async {
    final fn = FeedbackNote(
      patientId: patientId,
      authorId: authorId,
      authorRole: authorRole,
      note: note,
      createdAt: DateTime.now(),
    );
    await _repository.saveFeedbackNote(fn);
  }

  /// Mendapatkan daftar seluruh catatan umpan balik untuk pasien tertentu.
  Future<List<FeedbackNote>> getFeedbackNotes(int patientId) async {
    return _repository.getPatientFeedbackNotes(patientId);
  }
}
