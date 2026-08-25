import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/workout_session.dart';
import '../../models/recovery_progress.dart';
import '../../services/analytics_engine.dart';
import '../../services/export_service.dart';
import '../controller/analytics_dashboard_controller.dart';
import '../controller/analytics_dashboard_state.dart';
import '../widgets/custom_sparkline_chart.dart';

/// Halaman Dashboard Analitik & Perkembangan Pengguna GERAKIN (Sesuai DESIGN.md).
///
/// Personality: Bright, Friendly, Inclusive, Cheerful, Modern, Premium.
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Progres & Analitik',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
            onPressed: () => ref.read(analyticsDashboardControllerProvider.notifier).refresh(),
          ),
          _buildExportMenu(state.sessions),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.errorMessage != null
              ? Center(child: Text(state.errorMessage!, style: AppTextStyles.bodyMedium))
              : _buildDashboardContent(context, state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogRecoveryDialog(context),
        icon: const Icon(Icons.healing_rounded, color: Colors.white),
        label: Text(
          'Catat Pemulihan',
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXxl,
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, AnalyticsDashboardState state) {
    final now = DateTime.now();
    final todaySessions = state.sessions.where((s) =>
        s.startTime.year == now.year &&
        s.startTime.month == now.month &&
        s.startTime.day == now.day).toList();

    double todayDuration = todaySessions.fold(0, (sum, s) => sum + s.durationInSeconds) / 60.0;
    double todayCalories = todaySessions.fold(0.0, (sum, s) => sum + s.caloriesBurned);
    int todayReps = todaySessions.fold(0, (sum, s) => sum + s.completedReps);

    final weeklySummary = _analyticsEngine.generateWeeklySummary(state.sessions, now);
    final monthlySummary = _analyticsEngine.generateMonthlySummary(state.sessions, now.year, now.month);

    final romTrend = _analyticsEngine.getRomTrend(state.sessions);
    final accuracyTrend = _analyticsEngine.getAccuracyTrend(state.sessions);
    final recoveryTrend = _analyticsEngine.getRecoveryScoreTrend(state.recoveryRecords);

    return RefreshIndicator(
      color: AppColors.primary,
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
                    AppColors.skyBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Kalori',
                    '${todayCalories.toStringAsFixed(0)} kkal',
                    Icons.local_fire_department_outlined,
                    const Color(0xFFF97316),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Repetisi',
                    '$todayReps kali',
                    Icons.fitness_center_outlined,
                    AppColors.primary,
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
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPeriodCard(
                    context,
                    'Bulanan (Jan-Des)',
                    'Sesi: ${monthlySummary.totalSessions}\nKalori: ${monthlySummary.totalCalories.toStringAsFixed(0)} kkal\nRerata ROM: ${monthlySummary.averageRom.toStringAsFixed(0)}°',
                    AppColors.skyBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── VISUAL TRENDS (ROM & ACCURACY) ───────────────────────
            _buildSectionHeader('Tren Akurasi & Fleksibilitas'),
            const SizedBox(height: 12),
            CustomSparklineChart(
              data: accuracyTrend,
              title: 'Tren Akurasi Latihan (%)',
              lineColor: AppColors.primary,
              unit: '%',
            ),
            const SizedBox(height: 12),
            CustomSparklineChart(
              data: romTrend,
              title: 'Tren Rentang Gerak / ROM (Derajat)',
              lineColor: AppColors.skyBlue,
              unit: '°',
            ),
            const SizedBox(height: 24),

            // ── RECOVERY TREND ─────────────────────────────────────
            _buildSectionHeader('Tren Pemulihan Fisik'),
            const SizedBox(height: 12),
            CustomSparklineChart(
              data: recoveryTrend,
              title: 'Skor Kesiapan & Pemulihan (1-100)',
              lineColor: AppColors.mint,
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
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
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
    return Container(
      padding: AppSpacing.paddingAllMd,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusXxl,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(BuildContext context, String title, String details, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusXxl,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            details,
            style: AppTextStyles.captionMedium.copyWith(
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid(List<dynamic> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final a = achievements[index];
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderRadiusXxl,
            border: Border.all(
              color: a.isUnlocked ? const Color(0xFFFACC15) : AppColors.border,
              width: a.isUnlocked ? 1.5 : 1,
            ),
            boxShadow: AppShadows.softCard,
          ),
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
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    a.isUnlocked ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
                    color: a.isUnlocked ? const Color(0xFFF59E0B) : AppColors.neutral400,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                a.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: a.progress,
                  backgroundColor: AppColors.neutral200,
                  color: a.isUnlocked ? const Color(0xFFF59E0B) : AppColors.primary,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutHistoryList(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusXxl,
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: AppShadows.softCard,
        ),
        child: Center(
          child: Text(
            'Belum ada riwayat sesi latihan.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderRadiusXxl,
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: AppShadows.softCard,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderRadiusXxl,
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                s.workoutName,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                formattedDate,
                style: AppTextStyles.captionSmall.copyWith(color: AppColors.textSecondary),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (s.isCompleted ? AppColors.success : AppColors.neutral400).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  s.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: s.isCompleted ? AppColors.success : AppColors.neutral400,
                  size: 20,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: AppColors.border),
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
          Text(label, style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.captionMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildExportMenu(List<WorkoutSession> sessions) {
    return PopupMenuButton<String>(
      onSelected: (val) => _handleExport(val, sessions),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.success, size: 20),
              SizedBox(width: 8),
              Text('Ekspor ke CSV'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined, color: AppColors.error, size: 20),
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
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            )
          : const Icon(Icons.download_rounded, color: AppColors.textPrimary),
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
          textColor: AppColors.secondary,
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
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
              backgroundColor: AppColors.surface,
              title: Text('Catat Pemulihan Hari Ini', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
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
                        decoration: InputDecoration(
                          labelText: 'Heart Rate Variability (HRV ms)',
                          border: OutlineInputBorder(borderRadius: AppRadius.borderRadiusXxl),
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
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
                  ),
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
            Text(label, style: AppTextStyles.captionMedium),
            Text(value.toStringAsFixed(0), style: AppTextStyles.captionMedium.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
