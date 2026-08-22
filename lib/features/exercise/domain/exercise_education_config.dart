import 'exercise_type.dart';

/// Config Data Konten Edukasi & Tutorial Latihan (ExerciseEducationConfig).
///
/// Menyediakan instruksi langkah-demi-langkah, posisi awal, hal yang perlu diperhatikan,
/// serta sekuens animasi 3-frame untuk [ExerciseEducationScreen].
class ExerciseEducationConfig {
  const ExerciseEducationConfig({
    required this.exerciseType,
    required this.startingPositionTitle,
    required this.startingPositionBullets,
    required this.stepByStepInstructions,
    required this.importantReminders,
    required this.userPostureTips,
    required this.phaseLabels,
    required this.animationSequence,
  });

  final ExerciseType exerciseType;
  final String startingPositionTitle;
  final List<String> startingPositionBullets;
  final List<String> stepByStepInstructions;
  final List<String> importantReminders;
  final List<String> userPostureTips;
  final List<String> phaseLabels;
  final List<int> animationSequence;

  factory ExerciseEducationConfig.forType(ExerciseType type) {
    switch (type) {
      case ExerciseType.sideArmRaise:
        return const ExerciseEducationConfig(
          exerciseType: ExerciseType.sideArmRaise,
          startingPositionTitle: 'Duduk Tegak di Kursi Roda',
          startingPositionBullets: [
            'Duduk tegak dan rileks dengan punggung tersangga baik.',
            'Letakkan kedua tangan mengujung santai di samping tubuh.',
            'Hadapkan tubuh dan pandangan lurus ke depan kamera.',
          ],
          stepByStepInstructions: [
            'Mulai dengan kedua lengan mengantung lurus di samping tubuh.',
            'Angkat kedua tangan perlahan ke arah samping.',
            'Berhenti saat lengan sejajar dengan tinggi bahu (sudut ~90°).',
            'Tahan posisi sejenak, lalu turunkan lengan perlahan ke posisi awal.',
            'Ulangi gerakan secara konstan dan seimbang kiri & kanan.',
          ],
          importantReminders: [
            '✓ Jaga tubuh dan bahu tetap tegak, hindari membungkuk.',
            '✓ Gerakkan kedua lengan secara perlahan dan terkontrol.',
            '! Jangan menghentakkan lengan atau mengangkat bahu berlebihan.',
          ],
          userPostureTips: [
            'Duduk tegak menghadap kamera.',
            'Letakkan ponsel di posisi stabil setinggi dada/wajah.',
            'Pastikan bahu, lengan, dan dada terlihat jelas di bingkai kamera.',
          ],
          phaseLabels: [
            'Posisi Awal: Tangan di samping tubuh',
            'Angkat Perlahan: Gerakkan kedua tangan ke samping',
            'Posisi Target: Lengan terangkat sejajar bahu',
          ],
          animationSequence: [0, 1, 2, 1, 0], // Start -> Middle -> Target -> Middle -> Start
        );

      case ExerciseType.bicepCurl:
        return const ExerciseEducationConfig(
          exerciseType: ExerciseType.bicepCurl,
          startingPositionTitle: 'Posisi Lengan Mengantung',
          startingPositionBullets: [
            'Duduk tegak dan nyaman di kursi roda.',
            'Luruskan kedua lengan mengarah ke bawah di samping tubuh.',
            'Pertahankan siku dekat dan stabil di samping pinggang.',
          ],
          stepByStepInstructions: [
            'Mulai dengan lengan meng lurus ke bawah di samping tubuh.',
            'Tekuk kedua siku perlahan untuk mengimbau tangan ke atas.',
            'Gerakkan kedua pergelangan tangan mendekati arah bahu.',
            'Pertahankan lengan atas tetap stabil menempel di samping tubuh.',
            'Turunkan kembali tangan ke posisi lurus awal secara terkontrol.',
          ],
          importantReminders: [
            '✓ Pertahankan siku tetap dekat di samping tubuh.',
            '✓ Rasakan kontraksi otot bicep di lengan depan.',
            '! Hindari mengayunkan tubuh ke depan atau belakang.',
          ],
          userPostureTips: [
            'Duduk menghadap depan kamera.',
            'Posisikan kamera agar siku dan pergelangan tangan terlihat.',
            'Jaga jarak aman sekitar 1 - 1.5 meter dari perangkat.',
          ],
          phaseLabels: [
            'Posisi Awal: Luruskan lengan ke bawah',
            'Tekuk Siku: Angkat kedua tangan perlahan',
            'Posisi Target: Dekatkan tangan ke arah bahu',
          ],
          animationSequence: [0, 1, 2, 1, 0], // Start -> Middle -> Target -> Middle -> Start
        );

      case ExerciseType.neckRotation:
        return const ExerciseEducationConfig(
          exerciseType: ExerciseType.neckRotation,
          startingPositionTitle: 'Duduk Rileks & Pandangan Lurus',
          startingPositionBullets: [
            'Duduk tegak dan santai, rilekskan kedua bahu.',
            'Hadapkan kepala lurus ke depan sejajar dengan kamera.',
            'Jaga kedua bahu tetap diam menghadap depan.',
          ],
          stepByStepInstructions: [
            'Mulai dengan kepala menghadap lurus ke depan.',
            'Putar kepala secara lembut dan perlahan ke arah kanan.',
            'Kembali putar kepala ke posisi tengah menghadap kamera.',
            'Putar kepala secara lembut dan perlahan ke arah kiri.',
            'Kembali ke posisi tengah untuk menyelesaikan 1 repetisi.',
          ],
          importantReminders: [
            '✓ Lakukan rotasi leher secara sangat lembut dan konstan.',
            '✓ Jaga bahu dan dada tetap diam menghadap depan.',
            '! Jangan memiringkan leher ke samping bahu.',
          ],
          userPostureTips: [
            'Duduk tepat di tengah bingkai kamera.',
            'Pastikan area wajah dan leher mendapatkan pencahayaan yang cukup.',
            'Pertahankan pandangan mata sejajar dengan lensa kamera.',
          ],
          phaseLabels: [
            'Posisi Awal: Hadapkan kepala lurus ke depan',
            'Putar Kanan: Gerakkan kepala ke kanan perlahan',
            'Putar Kiri: Gerakkan kepala ke kiri perlahan',
          ],
          animationSequence: [0, 1, 0, 2, 0], // Center -> Right -> Center -> Left -> Center
        );
    }
  }
}
