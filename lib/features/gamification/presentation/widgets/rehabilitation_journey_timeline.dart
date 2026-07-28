import 'package:flutter/material.dart';

/// Item data untuk representasi node pada timeline perjalanan rehabilitasi.
class JourneyStage {
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;

  JourneyStage({
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.isActive,
  });
}

/// Widget timeline interaktif berbasis simpul (node) untuk memantau tahapan pemulihan fisik.
class RehabilitationJourneyTimeline extends StatelessWidget {
  final String mobilityLevel;
  final String rehabilitationGoal;

  const RehabilitationJourneyTimeline({
    super.key,
    required this.mobilityLevel,
    required this.rehabilitationGoal,
  });

  @override
  Widget build(BuildContext context) {
    // Menentukan tahapan aktif berdasarkan data profil pengguna
    final stages = _computeStages();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perjalanan Rehabilitasi (Journey)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stages.length,
          itemBuilder: (context, index) {
            final stage = stages[index];
            final isLast = index == stages.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sisi kiri: Node bulatan & Garis penghubung
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: stage.isActive
                              ? Theme.of(context).colorScheme.primary
                              : stage.isCompleted
                                  ? Colors.green.shade600
                                  : Colors.grey.shade300,
                          boxShadow: stage.isActive
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(
                          stage.icon,
                          size: 16,
                          color: stage.isActive || stage.isCompleted ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: stage.isCompleted ? Colors.green.shade600 : Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Sisi kanan: Konten teks detail tahapan
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stage.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: stage.isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : stage.isCompleted
                                      ? Colors.green.shade700
                                      : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stage.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  List<JourneyStage> _computeStages() {
    final isIntermediate = mobilityLevel == 'intermediate';
    final isAdvanced = mobilityLevel == 'advanced';

    return [
      JourneyStage(
        title: 'Tahap 1: Kalibrasi & Uji Fisik',
        description: 'Melakukan uji fisik awal untuk mengetahui range of motion dan stamina dasar.',
        icon: Icons.assignment_turned_in_rounded,
        isCompleted: true,
        isActive: false,
      ),
      JourneyStage(
        title: 'Tahap 2: Latihan Kekuatan Seated',
        description: 'Fokus melatih otot dada, lengan, dan bahu menggunakan sensor visual adaptif.',
        icon: Icons.fitness_center_rounded,
        isCompleted: isIntermediate || isAdvanced,
        isActive: !isIntermediate && !isAdvanced,
      ),
      JourneyStage(
        title: 'Tahap 3: Pelatihan Rentang Gerak (ROM)',
        description: 'Meningkatkan kelenturan sendi bahu kanan dan kiri agar terhindar dari kaku otot.',
        icon: Icons.accessibility_new_rounded,
        isCompleted: isAdvanced,
        isActive: isIntermediate,
      ),
      JourneyStage(
        title: 'Tahap 4: Ketahanan & Kemandirian Fisik',
        description: 'Menjaga kebugaran jangka panjang untuk mendukung aktivitas mandiri sehari-hari.',
        icon: Icons.emoji_events_rounded,
        isCompleted: false,
        isActive: isAdvanced,
      ),
    ];
  }
}
