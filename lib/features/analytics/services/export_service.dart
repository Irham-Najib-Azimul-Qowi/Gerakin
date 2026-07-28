import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/workout_session.dart';

/// Layanan ekspor data aktivitas ke dalam format CSV dan PDF.
class ExportService {
  /// Ekspor riwayat latihan ke format string CSV.
  String exportSessionsToCsv(List<WorkoutSession> sessions) {
    final List<List<dynamic>> rows = [
      // CSV Header
      [
        'ID Sesi',
        'ID Gerakan',
        'Nama Gerakan',
        'Tanggal & Waktu Mulai',
        'Durasi (Detik)',
        'Kalori Terbakar (kkal)',
        'Repetisi Berhasil',
        'Target Repetisi',
        'Akurasi (%)',
        'Rata-rata ROM (Derajat)',
        'Selesai Penuh',
        'Skor Pemulihan (1-100)'
      ]
    ];

    for (final s in sessions) {
      rows.add([
        s.id,
        s.workoutId,
        s.workoutName,
        s.startTime.toIso8601String(),
        s.durationInSeconds,
        s.caloriesBurned,
        s.completedReps,
        s.targetReps,
        s.accuracy,
        s.averageRom,
        s.isCompleted ? 'Ya' : 'Tidak',
        s.recoveryScore
      ]);
    }

    return Csv().encode(rows);
  }

  /// Ekspor riwayat latihan ke format dokumen PDF (Uint8List bytes).
  Future<Uint8List> exportSessionsToPdf(List<WorkoutSession> sessions) async {
    final pdf = pw.Document();

    // Hitung total ringkasan
    final totalSessions = sessions.length;
    final totalCalories = sessions.fold(0.0, (sum, s) => sum + s.caloriesBurned);
    final totalDuration = sessions.fold(0, (sum, s) => sum + s.durationInSeconds) / 60.0;
    final avgAccuracy = totalSessions > 0
        ? sessions.fold(0.0, (sum, s) => sum + s.accuracy) / totalSessions
        : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Title Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'LAPORAN PERKEMBANGAN GERAKIN',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal,
                    ),
                  ),
                  pw.Text(
                    DateTime.now().toString().split(' ')[0],
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Ringkasan Agregat
            pw.Text(
              'Ringkasan Performa:',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildPdfSummaryStat('Total Sesi', '$totalSessions kali'),
                _buildPdfSummaryStat('Total Durasi', '${totalDuration.toStringAsFixed(1)} menit'),
                _buildPdfSummaryStat('Kalori Terbakar', '${totalCalories.toStringAsFixed(1)} kkal'),
                _buildPdfSummaryStat('Rata-rata Akurasi', '${avgAccuracy.toStringAsFixed(1)}%'),
              ],
            ),
            pw.SizedBox(height: 24),

            // Judul Tabel Riwayat
            pw.Text(
              'Daftar Riwayat Latihan:',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            // Tabel Sesi Latihan
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
              headers: ['Tanggal', 'Nama Latihan', 'Durasi', 'Kalori', 'Akurasi', 'ROM'],
              data: sessions.map((s) {
                final dateStr = '${s.startTime.day}/${s.startTime.month}/${s.startTime.year}';
                final durStr = '${(s.durationInSeconds / 60).toStringAsFixed(1)}m';
                final calStr = '${s.caloriesBurned.toStringAsFixed(0)} kkal';
                final accStr = '${s.accuracy.toStringAsFixed(1)}%';
                final romStr = '${s.averageRom.toStringAsFixed(0)}°';
                return [dateStr, s.workoutName, durStr, calStr, accStr, romStr];
              }).toList(),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfSummaryStat(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
