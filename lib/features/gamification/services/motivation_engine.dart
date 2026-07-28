import 'dart:math';
import '../domain/repositories/gamification_repository.dart';
import '../models/motivation_message.dart';

/// Engine untuk menyajikan pesan motivasi dan dorongan semangat bagi pengguna.
class MotivationEngine {
  final GamificationRepository _repository;

  MotivationEngine(this._repository);

  /// Menginisialisasi pesan motivasi default jika database masih kosong.
  Future<void> initializeDefaultMessages() async {
    final list = await _repository.getMotivationMessages();
    if (list.isNotEmpty) return;

    final messages = [
      MotivationMessage(
        message: 'Setiap gerakan kecil hari ini membawa Anda lebih dekat ke kemandirian esok hari!',
        category: 'daily',
      ),
      MotivationMessage(
        message: 'Konsistensi adalah kunci pemulihan. Lanjutkan perjuangan luar biasa Anda!',
        category: 'daily',
      ),
      MotivationMessage(
        message: 'Fokus pada apa yang bisa Anda lakukan hari ini, bukan apa yang tidak bisa dilakukan.',
        category: 'daily',
      ),
      MotivationMessage(
        message: 'Luar biasa! Anda telah menyelesaikan pencapaian penting dalam perjalanan rehabilitasi!',
        category: 'milestone',
      ),
      MotivationMessage(
        message: 'Level baru, kekuatan baru. Tubuh Anda berterima kasih atas latihan hari ini!',
        category: 'milestone',
      ),
    ];

    for (var m in messages) {
      await _repository.addMotivationMessage(m);
    }
  }

  /// Mendapatkan pesan motivasi secara acak berdasarkan kategori.
  Future<String> getRandomMessage(String category) async {
    await initializeDefaultMessages();
    final list = await _repository.getMotivationMessages();
    final filtered = list.where((x) => x.category == category).toList();
    if (filtered.isEmpty) {
      return 'Luar biasa! Lanjutkan perjuangan latihan fisik Anda!';
    }
    final idx = Random().nextInt(filtered.length);
    return filtered[idx].message;
  }
}
