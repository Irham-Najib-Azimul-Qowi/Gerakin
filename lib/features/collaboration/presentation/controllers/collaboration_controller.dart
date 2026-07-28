import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/exercise_program.dart';
import '../../models/feedback_note.dart';
import '../../models/program_template.dart';
import '../../services/collaboration_providers.dart';
import '../../../user/presentation/controllers/profile_controller.dart';

/// State untuk kolaborasi fisioterapis, caregiver, dan pasien.
class CollaborationState {
  final String activeRole; // 'patient' | 'physiotherapist' | 'caregiver' | 'admin'
  final List<int> assignedPatientIds;
  final List<ExerciseProgram> activePrograms;
  final List<FeedbackNote> feedbackNotes;
  final List<ProgramTemplate> templates;
  final bool isLoading;

  CollaborationState({
    required this.activeRole,
    required this.assignedPatientIds,
    required this.activePrograms,
    required this.feedbackNotes,
    required this.templates,
    required this.isLoading,
  });

  CollaborationState copyWith({
    String? activeRole,
    List<int>? assignedPatientIds,
    List<ExerciseProgram>? activePrograms,
    List<FeedbackNote>? feedbackNotes,
    List<ProgramTemplate>? templates,
    bool? isLoading,
  }) {
    return CollaborationState(
      activeRole: activeRole ?? this.activeRole,
      assignedPatientIds: assignedPatientIds ?? this.assignedPatientIds,
      activePrograms: activePrograms ?? this.activePrograms,
      feedbackNotes: feedbackNotes ?? this.feedbackNotes,
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Controller (Notifier) untuk sinkronisasi antarmuka kolaborasi terpadu.
class CollaborationController extends Notifier<CollaborationState> {
  @override
  CollaborationState build() {

    ref.listen(profileControllerProvider, (prev, next) {
      if (next.activeProfile != null) {
        loadCollaborationData(next.activeProfile!.id);
      }
    });

    final activeProfile = ref.read(profileControllerProvider).activeProfile;
    if (activeProfile != null) {
      Future.microtask(() => loadCollaborationData(activeProfile.id));
    }

    return CollaborationState(
      activeRole: 'patient',
      assignedPatientIds: const [],
      activePrograms: const [],
      feedbackNotes: const [],
      templates: const [],
      isLoading: true,
    );
  }

  /// Memuat status peran aktif serta jadwal atau daftar tugas kolaborasi.
  Future<void> loadCollaborationData(int userId) async {
    try {
      state = state.copyWith(isLoading: true);

      final role = await ref.read(roleManagerProvider).getUserRole(userId);
      final templates = await ref.read(programTemplateServiceProvider).getTemplates();

      List<int> patientIds = [];
      List<ExerciseProgram> programs = [];
      List<FeedbackNote> notes = [];

      if (role == 'physiotherapist') {
        patientIds = await ref.read(physioDashboardServiceProvider).getAssignedPatientIds(userId);
      } else if (role == 'patient') {
        programs = await ref.read(exercisePrescriptionServiceProvider).getPatientPrograms(userId);
        notes = await ref.read(feedbackNoteServiceProvider).getFeedbackNotes(userId);
      }

      state = CollaborationState(
        activeRole: role,
        assignedPatientIds: patientIds,
        activePrograms: programs,
        feedbackNotes: notes,
        templates: templates,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Beralih peran (switching active role) pada sistem.
  Future<void> switchRole(int userId, String newRole) async {
    state = state.copyWith(isLoading: true);
    await ref.read(roleManagerProvider).setUserRole(userId, newRole);
    await loadCollaborationData(userId);
  }

  /// Meresepkan program latihan gerakan baru dari Fisioterapis ke Pasien.
  Future<void> prescribeNewProgram({
    required int patientId,
    required int physioId,
    required String title,
    required String description,
    required List<String> exerciseIds,
    required String frequency,
  }) async {
    await ref.read(exercisePrescriptionServiceProvider).prescribeProgram(
          patientId: patientId,
          physioId: physioId,
          title: title,
          description: description,
          exerciseIds: exerciseIds,
          frequency: frequency,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 14)),
        );
    await loadCollaborationData(physioId);
  }

  /// Menulis catatan umpan balik fisioterapis/caregiver tentang sesi latihan pasien.
  Future<void> addFeedbackNote({
    required int patientId,
    required int authorId,
    required String authorRole,
    required String note,
  }) async {
    await ref.read(feedbackNoteServiceProvider).addFeedback(
          patientId: patientId,
          authorId: authorId,
          authorRole: authorRole,
          note: note,
        );
    await loadCollaborationData(patientId);
  }
}

/// Provider untuk instansiasi [CollaborationController].
final collaborationControllerProvider =
    NotifierProvider<CollaborationController, CollaborationState>(
  CollaborationController.new,
);
