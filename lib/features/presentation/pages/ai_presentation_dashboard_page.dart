import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../demo/demo_mode_service.dart';
import '../../benchmark/services/benchmark_report_generator.dart';

/// Halaman Dashboard AI & Presentasi Khusus Kompetisi KMIPN.
class AiPresentationDashboardPage extends ConsumerWidget {
  const AiPresentationDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoState = ref.watch(demoModeServiceProvider);
    final report = BenchmarkReportGenerator.generateCurrentReport();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KMIPN AI Presentation Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              demoState.isDemoActive ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
              color: demoState.isDemoActive ? Colors.red : Colors.green,
            ),
            onPressed: () {
              ref.read(demoModeServiceProvider.notifier).toggleDemoMode();
            },
            tooltip: demoState.isDemoActive ? 'Hentikan Demo Live' : 'Mulai Demo Live Sensor',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── DEMO BANNER ─────────────────────────────────────────
            _buildDemoBanner(context, ref, demoState),
            const SizedBox(height: 20),

            // ── LIVE METRICS GRID ────────────────────────────────────
            _buildSectionHeader('Live Performance & Benchmark Metrics'),
            const SizedBox(height: 10),
            _buildMetricsGrid(context, demoState, report),
            const SizedBox(height: 24),

            // ── SIMULATION ANGLE ARC INDICATOR ───────────────────────
            if (demoState.isDemoActive) ...[
              _buildSectionHeader('Simulasi Visual Sensor Landmark Pose'),
              const SizedBox(height: 10),
              _buildSimulationAngleCard(context, demoState),
              const SizedBox(height: 24),
            ],

            // ── ARCHITECTURAL ADVANTAGES ──────────────────────────────
            _buildSectionHeader('Keunggulan Arsitektur Enterprise GERAKIN'),
            const SizedBox(height: 10),
            _buildArchitectureBadges(context),
            const SizedBox(height: 24),

            // ── EXPORT BENCHMARK REPORT ──────────────────────────────
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  final md = report.toMarkdown();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Laporan Benchmark Sistem'),
                      content: SingleChildScrollView(
                        child: Text(md, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.assessment_rounded),
                label: const Text('Tampilkan Laporan Benchmark Lengkap'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoBanner(BuildContext context, WidgetRef ref, DemoModeState demoState) {
    return Card(
      elevation: 0,
      color: demoState.isDemoActive
          ? Colors.green.withValues(alpha: 0.1)
          : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: demoState.isDemoActive ? Colors.green : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              demoState.isDemoActive ? Icons.sensors_rounded : Icons.slideshow_rounded,
              color: demoState.isDemoActive ? Colors.green : Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    demoState.isDemoActive ? 'Mode Demo Live Aktif' : 'Ready for KMIPN Presentation',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    demoState.isDemoActive
                        ? 'Simulasi data sensor sudut sendi real-time sedang berjalan.'
                        : 'Klik tombol di kanan atas untuk menyimulasikan data kamera tanpa fisik.',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, DemoModeState demoState, BenchmarkReport report) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          context,
          'Frame Rate (FPS)',
          '${demoState.isDemoActive ? demoState.simulatedFps.toStringAsFixed(0) : report.averageFps.toStringAsFixed(0)} FPS',
          Icons.speed_rounded,
          Colors.blue,
        ),
        _buildMetricCard(
          context,
          'Inference Latency',
          '${report.averageLatencyMs.toStringAsFixed(1)} ms',
          Icons.bolt_rounded,
          Colors.orange,
        ),
        _buildMetricCard(
          context,
          'Confidence Rate',
          '${(demoState.isDemoActive ? demoState.simulatedConfidence * 100 : report.poseConfidencePercent).toStringAsFixed(1)}%',
          Icons.verified_user_rounded,
          Colors.green,
        ),
        _buildMetricCard(
          context,
          'Memory Usage',
          '${report.memoryUsageMb.toStringAsFixed(1)} MB',
          Icons.memory_rounded,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationAngleCard(BuildContext context, DemoModeState demoState) {
    final angle = demoState.simulatedAngle;
    final progress = (angle / 180.0).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sudut Flexion Bahu (Real-time)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('${angle.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(angle > 140 ? Colors.green : Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchitectureBadges(BuildContext context) {
    final badges = [
      {'title': '100% Offline-First Design', 'desc': 'Data tersimpan otomatis di ObjectBox lokal', 'icon': Icons.offline_pin_rounded},
      {'title': 'Cloud Sync Engine (LWW)', 'desc': 'Sinkronisasi antrean otomatis saat online', 'icon': Icons.sync_rounded},
      {'title': 'Pluggable Rule Engine', 'desc': 'Logika gamifikasi & skor terisolasi dan mudah diperluas', 'icon': Icons.rule_folder_rounded},
      {'title': 'Zero-Latency Motion Filter', 'desc': 'Filter EMA meredam jitter gerakan sensor visual', 'icon': Icons.filter_alt_rounded},
    ];

    return Column(
      children: badges.map((b) {
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
          ),
          child: ListTile(
            leading: Icon(b['icon'] as IconData, color: Theme.of(context).colorScheme.primary),
            title: Text(b['title'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            subtitle: Text(b['desc'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }
}
