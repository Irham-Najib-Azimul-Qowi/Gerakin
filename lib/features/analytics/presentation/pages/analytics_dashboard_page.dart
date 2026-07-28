import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/workout_session.dart';
import '../../models/recovery_progress.dart';
import '../../services/analytics_engine.dart';
import '../../services/export_service.dart';
import '../controller/analytics_dashboard_controller.dart';
import '../controller/analytics_dashboard_state.dart';
import '../widgets/custom_sparkline_chart.dart';

/// Halaman Dashboard Analitik & Perkembangan Pengguna GERAKIN.
class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends ConsumerState<AnalyticsDashboardPage> {
  final AnalyticsEngine _analyticsEngine = AnalyticsEngine();
  final ExportService _exportService = ExportService();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsDashboardControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analitik & Perkembangan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(analyticsDashboardControllerProvider.notifier).refresh(),
          ),
          _buildExportMenu(state.sessions),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(child: Text(state.errorMessage!))
              : _buildDashboardContent(context, state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogRecoveryDialog(context),
        icon: const Icon(Icons.healing_rounded),
        label: const Text('Catat Pemulihan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, AnalyticsDashboardState state) {
    // Hitung metrik hari ini
    final now = DateTime.now();
    final todaySessions = state.sessions.where((s) =>
        s.startTime.year == now.year &&
        s.startTime.month == now.month &&
        s.startTime.day == now.day).toList();

    double todayDuration = todaySessions.fold(0, (sum, s) => sum + s.durationInSeconds) / 60.0;
    double todayCalories = todaySessions.fold(0.0, (sum, s) => sum + s.caloriesBurned);
    int todayReps = todaySessions.fold(0, (sum, s) => sum + s.completedReps);

    // Hitung ringkasan mingguan/bulanan
    final weeklySummary = _analyticsEngine.generateWeeklySummary(state.sessions, now);
    final monthlySummary = _analyticsEngine.generateMonthlySummary(state.sessions, now.year, now.month);

    // Hitung tren
    final romTrend = _analyticsEngine.getRomTrend(state.sessions);
    final accuracyTrend = _analyticsEngine.getAccuracyTrend(state.sessions);
    final recoveryTrend = _analyticsEngine.getRecoveryScoreTrend(state.recoveryRecords);

    return RefreshIndicator(
      onRefresh: () => ref.read(analyticsDashboardControllerProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TODAY'S ACTIVITY ───────────────────────────────────
            _buildSectionHeader('Aktivitas Hari Ini'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Menit Aktif',
                    '${todayDuration.toStringAsFixed(1)} m',
                    Icons.timer_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Kalori',
                    '${todayCalories.toStringAsFixed(0)} kkal',
                    Icons.local_fire_department_outlined,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Repetisi',
                    '$todayReps kali',
                    Icons.fitness_center_outlined,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── WEEKLY & MONTHLY PROGRESS ───────────────────────────
            _buildSectionHeader('Ringkasan Periode'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPeriodCard(
                    context,
                    'Mingguan (Sen-Min)',
                    'Sesi: ${weeklySummary.totalSessions}\nKalori: ${weeklySummary.totalCalories.toStringAsFixed(0)} kkal\nRerata ROM: ${weeklySummary.averageRom.toStringAsFixed(0)}°',
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPeriodCard(
                    context,
                    'Bulanan (Jan-Des)',
                    'Sesi: ${monthlySummary.totalSessions}\nKalori: ${monthlySummary.totalCalories.toStringAsFixed(0)} kkal\nRerata ROM: ${monthlySummary.averageRom.toStringAsFixed(0)}°',
                    Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── VISUAL TRENDS (ROM & ACCURACY) ───────────────────────
            _buildSectionHeader('Tren Latihan'),
            const SizedBox(height: 12),
            CustomSparklineChart(
              data: accuracyTrend,
              title: 'Tren Akurasi Latihan (%)',
              lineColor: Colors.teal,
              unit: '%',
            ),
            const SizedBox(height: 12),
            CustomSparklineChart(
              data: romTrend,
              title: 'Tren Rentang Gerak / ROM (Derajat)',
              lineColor: Colors.indigo,
              unit: '°',
            ),
            const SizedBox(height: 24),

            // ── RECOVERY TREND ─────────────────────────────────────
            _buildSectionHeader('Tren Pemulihan'),
            const SizedBox(height: 12),
            CustomSparklineChart(
              data: recoveryTrend,
              title: 'Skor Pemulihan Fisik (1-100)',
              lineColor: Colors.pink,
              unit: '',
            ),
            const SizedBox(height: 24),

            // ── ACHIEVEMENTS ───────────────────────────────────────
            _buildSectionHeader('Pencapaian Medali'),
            const SizedBox(height: 12),
            _buildAchievementsGrid(state.achievements),
            const SizedBox(height: 24),

            // ── WORKOUT HISTORY ────────────────────────────────────
            _buildSectionHeader('Riwayat Latihan'),
            const SizedBox(height: 12),
            _buildWorkoutHistoryList(state.sessions),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodCard(BuildContext context, String title, String details, Color accentColor) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              details,
              style: TextStyle(
                fontSize: 11,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsGrid(List<dynamic> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final a = achievements[index];
        return Card(
          elevation: 0,
          color: a.isUnlocked
              ? Colors.amber.withValues(alpha: 0.06)
              : Theme.of(context).colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: a.isUnlocked ? Colors.amber.withValues(alpha: 0.4) : Theme.of(context).colorScheme.outlineVariant,
              width: 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        a.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      a.isUnlocked ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
                      color: a.isUnlocked ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  a.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: a.progress,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    color: a.isUnlocked ? Colors.amber : Colors.teal,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutHistoryList(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Belum ada riwayat latihan fisik.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final s = sessions[index];
        final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(s.startTime);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
          ),
          child: ExpansionTile(
            title: Text(
              s.workoutName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              formattedDate,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            leading: Icon(
              s.isCompleted ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_rounded,
              color: s.isCompleted ? Colors.green : Colors.grey,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildHistoryDetailRow('Akurasi Rerata', '${s.accuracy.toStringAsFixed(1)}%'),
                    _buildHistoryDetailRow('Rata-rata ROM', '${s.averageRom.toStringAsFixed(0)}°'),
                    _buildHistoryDetailRow('Durasi Latihan', '${(s.durationInSeconds / 60).toStringAsFixed(1)} menit'),
                    _buildHistoryDetailRow('Kalori Terbakar', '${s.caloriesBurned.toStringAsFixed(1)} kkal'),
                    _buildHistoryDetailRow('Repetisi', '${s.completedReps} / ${s.targetReps}'),
                    _buildHistoryDetailRow('Skor Pemulihan', '${s.recoveryScore} / 100'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExportMenu(List<WorkoutSession> sessions) {
    return PopupMenuButton<String>(
      onSelected: (val) => _handleExport(val, sessions),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.description_outlined, color: Colors.green),
              SizedBox(width: 8),
              Text('Ekspor ke CSV'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
              SizedBox(width: 8),
              Text('Ekspor ke PDF'),
            ],
          ),
        ),
      ],
      icon: _isExporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download_rounded),
    );
  }

  Future<void> _handleExport(String type, List<WorkoutSession> sessions) async {
    if (sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data latihan untuk diekspor.')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      
      if (type == 'csv') {
        final csvContent = _exportService.exportSessionsToCsv(sessions);
        final file = File('${directory.path}/gerakin_riwayat_$dateStr.csv');
        await file.writeAsString(csvContent);
        _showExportSuccess(file.path);
      } else if (type == 'pdf') {
        final pdfBytes = await _exportService.exportSessionsToPdf(sessions);
        final file = File('${directory.path}/gerakin_laporan_$dateStr.pdf');
        await file.writeAsBytes(pdfBytes);
        _showExportSuccess(file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor laporan: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showExportSuccess(String path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ekspor Berhasil!\nDisimpan di: $path'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.tealAccent,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showLogRecoveryDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    int pain = 1;
    int fatigue = 1;
    int soreness = 1;
    int sleep = 70;
    double hrv = 50.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Catat Pemulihan Hari Ini'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSliderRow(
                        'Pain (Rasa Sakit: 1-10)',
                        pain.toDouble(),
                        1,
                        10,
                        (val) => setDialogState(() => pain = val.round()),
                      ),
                      _buildSliderRow(
                        'Fatigue (Kelelahan: 1-10)',
                        fatigue.toDouble(),
                        1,
                        10,
                        (val) => setDialogState(() => fatigue = val.round()),
                      ),
                      _buildSliderRow(
                        'Soreness (Nyeri Otot: 1-10)',
                        soreness.toDouble(),
                        1,
                        10,
                        (val) => setDialogState(() => soreness = val.round()),
                      ),
                      _buildSliderRow(
                        'Kualitas Tidur (1-100)',
                        sleep.toDouble(),
                        1,
                        100,
                        (val) => setDialogState(() => sleep = val.round()),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: hrv.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Heart Rate Variability (HRV ms)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || double.tryParse(val) == null) {
                            return 'Masukkan angka HRV valid';
                          }
                          return null;
                        },
                        onSaved: (val) => hrv = double.parse(val!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      
                      // Hitung skor pemulihan agregat sederhana
                      // 100 - (pain*4) - (fatigue*3) - (soreness*3) + (sleep * 0.2)
                      final overall = (100 - (pain * 4) - (fatigue * 3) - (soreness * 3) + (sleep * 0.2)).clamp(1.0, 100.0).round();

                      final record = RecoveryProgress(
                        date: DateTime.now(),
                        perceivedPainLevel: pain,
                        fatigueLevel: fatigue,
                        sleepQualityScore: sleep,
                        heartRateVariability: hrv,
                        muscleSorenessScore: soreness,
                        overallRecoveryScore: overall,
                      );

                      await ref.read(analyticsDashboardControllerProvider.notifier).addRecoveryProgress(record);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: Colors.teal,
        ),
      ],
    );
  }
}
