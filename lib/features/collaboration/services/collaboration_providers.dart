import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/collaboration_repository_impl.dart';
import 'rbac_manager.dart';
import 'patient_assignment_service.dart';
import 'exercise_prescription_service.dart';
import 'feedback_note_service.dart';
import 'program_template_service.dart';
import 'secure_sharing_service.dart';
import 'notification_service.dart';
import 'collaboration_dashboards_service.dart';

/// Provider untuk instansiasi [RoleManager].
final roleManagerProvider = Provider<RoleManager>((ref) {
  final repo = ref.watch(collaborationRepositoryProvider);
  return RoleManager(repo);
});

/// Provider untuk instansiasi [PermissionManager].
final permissionManagerProvider = Provider<PermissionManager>((ref) {
  return PermissionManager();
});

/// Provider untuk instansiasi [PatientAssignmentService].
final patientAssignmentServiceProvider = Provider<PatientAssignmentService>((ref) {
  final repo = ref.watch(collaborationRepositoryProvider);
  return PatientAssignmentService(repo);
});

/// Provider untuk instansiasi [ExercisePrescriptionService].
final exercisePrescriptionServiceProvider = Provider<ExercisePrescriptionService>((ref) {
  final repo = ref.watch(collaborationRepositoryProvider);
  return ExercisePrescriptionService(repo);
});

/// Provider untuk instansiasi [FeedbackNoteService].
final feedbackNoteServiceProvider = Provider<FeedbackNoteService>((ref) {
  final repo = ref.watch(collaborationRepositoryProvider);
  return FeedbackNoteService(repo);
});

/// Provider untuk instansiasi [ProgramTemplateService].
final programTemplateServiceProvider = Provider<ProgramTemplateService>((ref) {
  final repo = ref.watch(collaborationRepositoryProvider);
  return ProgramTemplateService(repo);
});

/// Provider untuk instansiasi [SecureSharingService].
final secureSharingServiceProvider = Provider<SecureSharingService>((ref) {
  final repo = ref.watch(collaborationRepositoryProvider);
  return SecureSharingService(repo);
});

/// Provider untuk instansiasi [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider untuk instansiasi [PhysiotherapistDashboardService].
final physioDashboardServiceProvider = Provider<PhysiotherapistDashboardService>((ref) {
  final repo = ref.watch(collaborationRepositoryProvider);
  return PhysiotherapistDashboardService(repo);
});

/// Provider untuk instansiasi [CaregiverDashboardService].
final caregiverDashboardServiceProvider = Provider<CaregiverDashboardService>((ref) {
  final repo = ref.watch(collaborationRepositoryProvider);
  final sharing = ref.watch(secureSharingServiceProvider);
  return CaregiverDashboardService(repo, sharing);
});
