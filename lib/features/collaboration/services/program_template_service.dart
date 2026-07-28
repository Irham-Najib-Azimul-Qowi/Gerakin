import 'dart:convert';
import '../domain/repositories/collaboration_repository.dart';
import '../models/program_template.dart';

/// Layanan untuk mengelola program latihan berbasis template.
class ProgramTemplateService {
  final CollaborationRepository _repository;

  ProgramTemplateService(this._repository);

  /// Membuat template latihan baru yang siap diresepkan berulang kali.
  Future<void> createTemplate({
    required String title,
    required String description,
    required List<String> exerciseIds,
    required String category,
  }) async {
    final template = ProgramTemplate(
      title: title,
      description: description,
      exerciseIdsJson: jsonEncode(exerciseIds),
      category: category,
    );
    await _repository.saveProgramTemplate(template);
  }

  /// Mendapatkan seluruh daftar template program latihan.
  Future<List<ProgramTemplate>> getTemplates() async {
    return _repository.getProgramTemplates();
  }
}
