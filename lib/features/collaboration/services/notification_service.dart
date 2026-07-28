/// Layanan pengiriman notifikasi/alert untuk interaksi fisioterapis, caregiver, dan pasien.
class NotificationService {
  final List<String> notificationsList = [];

  /// Mengirimkan notifikasi baru ke pengguna.
  Future<void> sendNotification({
    required int recipientId,
    required String title,
    required String message,
  }) async {
    final alert = 'Recipient: $recipientId | Title: $title | Message: $message';
    notificationsList.add(alert);
  }

  /// Evaluasi otomatis performa pasien untuk mengirimkan notifikasi peringatan (alert) ke fisioterapis.
  Future<void> evaluatePerformanceAlerts({
    required int patientId,
    required int physioId,
    required double accuracy,
    required double recoveryTrend,
  }) async {
    if (accuracy < 0.6) {
      await sendNotification(
        recipientId: physioId,
        title: 'Peringatan Akurasi Pasien',
        message: 'Perhatian: Akurasi pasien ID $patientId berada di bawah batas minimal 60%.',
      );
    }
    if (recoveryTrend < 3.0) {
      await sendNotification(
        recipientId: physioId,
        title: 'Peringatan Pemulihan Pasien',
        message: 'Perhatian: Indeks pemulihan pasien ID $patientId menunjukkan penurunan.',
      );
    }
  }
}
