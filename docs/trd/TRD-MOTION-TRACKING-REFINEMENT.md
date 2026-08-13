# Technical Requirements Document (TRD)
## Penyempurnaan Modul: Real-Time Joint Tracking & Motion Feedback

| | |
|---|---|
| **Proyek** | GerakIn — KMIPN VIII 2026 |
| **Branch** | `feature/motion-tracking-refinement` |
| **Status saat ini** | **Fungsional**, bukan placeholder — pipeline capture → kalkulasi sudut → smoothing → validasi → kalibrasi sudah berjalan end-to-end. TRD ini bukan untuk membangun dari nol, melainkan memperbaiki 4 defect/gap konkret yang ditemukan lewat audit kode. |
| **Folder kerja** | `lib/features/camera/**`, `lib/features/motion/**`, `lib/features/validation/**`, `lib/features/feedback/**` (lintas 4 modul — lihat Bagian 7 soal koordinasi) |
| **Ditujukan untuk** | Developer manusia maupun AI coding assistant |

---

## 1. Ringkasan & Tujuan

Modul pelacakan sendi real-time (kamera → ML Kit → sudut sendi → validasi → kalibrasi → feedback) sudah diimplementasikan dengan arsitektur yang solid: rumus vektor untuk sudut sendi, EMA smoothing untuk jitter, rule-based feedback engine, dan alur kalibrasi pra-latihan. Namun audit kode menemukan **6 gap konkret** yang harus diperbaiki: empat menyangkut kebenaran fungsional (konsistensi konteks kursi roda, threshold, personalisasi), dan dua menyangkut kualitas visual skeleton yang ditampilkan ke pengguna (delay rendering dan estetika).

Ini bukan pekerjaan "modul baru" — ini pekerjaan **hardening & correctness fix** pada kode yang sudah ada. Jangan menulis ulang arsitektur yang sudah berjalan baik (`MotionProcessor`, `FeedbackRuleEngine`, `CoordinateMapper` semuanya sudah baik dan tidak perlu disentuh strukturnya).

## 2. Cakupan

**In-scope (6 perbaikan wajib):**
1. Perbaikan teks kalibrasi yang mengasumsikan posisi berdiri
2. Unifikasi threshold confidence yang tidak konsisten (0.4 vs 0.5)
3. Verifikasi & keputusan atas perhitungan sendi kaki (leftKnee/rightKnee/leftHip/rightHip)
4. Personalisasi threshold postur berbasis baseline kalibrasi per pengguna
5. Reduksi delay visual pada garis skeleton yang tampil di layar
6. Modernisasi tampilan visual skeleton line (estetika)

**Out-of-scope:**
- Mengganti model pose detection (Google ML Kit tetap dipakai, jangan migrasi ke MediaPipe/model lain)
- Mengubah rumus dasar perhitungan sudut vektor di `JointAngleCalculator` (sudah benar secara matematis)
- Membangun UI baru — perbaikan ini murni logika, UI kalibrasi yang sudah ada (`validation` presentation, jika ada) cukup disesuaikan teksnya

## 3. Perbaikan #1 — Teks Kalibrasi Mengasumsikan Berdiri

**File:** `lib/features/validation/services/calibration_service.dart`

**Kondisi saat ini:**
```dart
_currentStatus = const CalibrationStatus(
  step: CalibrationStep.checkingBaseline,
  progressPercentage: 75.0,
  statusMessage: 'Berdirilah tegak lurus menghadap kamera untuk mengambil sampel baseline.',
);
```

**Root cause:** Teks ini kemungkinan sisa dari template/riset awal berbasis aplikasi fitness umum sebelum skop dipersempit ke pengguna kursi roda, dan belum diperbarui.

**Spesifikasi perbaikan:**
```dart
statusMessage: 'Posisikan tubuh Anda tegak lurus menghadap kamera dari kursi roda untuk mengambil sampel baseline.',
```
Periksa juga `baseline_pose_service.dart` dan seluruh string di `validation/models/calibration_status.dart` (jika ada teks status lain) untuk memastikan tidak ada istilah "berdiri", "posisi kaki", "jarak langkah", atau asumsi mobilitas berdiri lainnya yang tersisa. Lakukan pencarian teks `berdiri` di seluruh folder `lib/features/validation/` dan `lib/features/camera/` sebelum menutup task ini.

## 4. Perbaikan #2 — Inkonsistensi Threshold Confidence

**File terdampak:**
- `lib/features/motion/domain/motion_processor.dart` (memakai `0.4` saat memanggil `pose.getLandmark(type, 0.4)`)
- `lib/features/motion/services/movement_validator.dart` (memakai `minConfidence = 0.5` sebagai default parameter)

**Root cause:** Dua angka ambang berbeda di-hardcode terpisah, alih-alih merujuk satu sumber kebenaran. Efeknya: sebuah sendi bisa lolos dihitung sudutnya di ambang 0,4 tapi kemudian frame yang sama dinyatakan `outOfRange` oleh validator karena dihitung ulang dengan ambang 0,5 — potensi *false-negative* validasi (pengguna sudah bergerak benar tapi sistem bilang "di luar jangkauan").

**Spesifikasi perbaikan:**
Buat satu konstanta bersama di `lib/features/motion/models/joint_angle.dart` atau file constants baru:
```dart
/// Ambang confidence minimum landmark yang dipakai KONSISTEN
/// di seluruh pipeline: kalkulasi sudut, smoothing, dan validasi.
/// JANGAN hardcode angka berbeda di file lain — rujuk konstanta ini.
class MotionTrackingConstants {
  static const double kMinLandmarkConfidence = 0.5;
}
```
Ganti seluruh angka hardcoded (`0.4`, `0.5`) di `motion_processor.dart`, `movement_validator.dart`, `joint_angle_calculator.dart` (parameter default `minConfidence`), dan `pose_landmark_model.dart` (`isValid([double threshold = 0.5])`) agar merujuk `MotionTrackingConstants.kMinLandmarkConfidence`.

## 5. Perbaikan #3 — Verifikasi Perhitungan Sendi Kaki

**File:** `lib/features/motion/domain/motion_processor.dart`, method `_calculateAllJointAngles()`

**Temuan:** Method ini menghitung 8 sudut sendi termasuk `leftKnee`, `rightKnee`, `leftHip`, `rightHip` — padahal seluruh 4 program latihan di proposal (`Seated Strength Training`, `Wheelchair Aerobics`, `Range of Motion`, `Core Stability`) berfokus pada tubuh bagian atas untuk pengguna kursi roda.

**Yang harus dilakukan (langkah wajib sebelum memutuskan hapus/pertahankan):**
1. Cek isi data exercise aktual — cari file JSON/data definisi latihan (kemungkinan di `assets/` atau di-generate lewat `exercise_library`) dan pastikan tidak ada satupun `ExerciseTargetAngles.primaryJoint` yang bernilai `leftKnee`, `rightKnee`, `leftHip`, atau `rightHip`.
2. **Jika benar tidak dipakai** → hapus 4 blok kalkulasi kaki dari `_calculateAllJointAngles()` untuk mengurangi beban komputasi per frame (setiap sendi yang dihitung berarti 3 pengecekan landmark + 1 kalkulasi trigonometri tambahan per frame, dikali ~33 FPS).
3. **Jika ternyata dipakai** (misalnya untuk mendeteksi kemiringan panggul saat bermanuver kursi roda, bukan untuk gerakan kaki) → beri komentar eksplisit di kode yang menjelaskan alasan pemakaiannya, supaya developer berikutnya tidak salah paham ini kode mati.

Jangan menghapus tanpa verifikasi langkah 1 — ini keputusan berbasis data, bukan asumsi.

## 6. Perbaikan #4 — Personalisasi Threshold Postur dari Baseline

**File:** `lib/features/motion/services/body_analyzer.dart`, `lib/features/validation/services/baseline_pose_service.dart`

**Kondisi saat ini:** `BaselinePoseService` sudah menangkap `BodyPosture` awal pengguna saat kalibrasi (`_capturedBaseline`), tapi `BodyAnalyzer.analyzePosture()` di setiap frame latihan **tidak menerima atau memakai baseline itu** — semua threshold (toleransi simetri bahu 8°, tilt torso 12°, dst.) adalah angka tetap yang sama untuk semua pengguna.

**Kenapa ini masalah nyata (bukan sekadar "nice to have"):** Postur "netral" pengguna kursi roda sangat bervariasi tergantung jenis kursi (manual vs elektrik), sudut sandaran (reclining), dan kondisi fisik individu (skoliosis ringan akibat waktu duduk lama, dsb.). Threshold tetap berisiko salah menandai postur yang sebenarnya normal-bagi-pengguna-tersebut sebagai "tidak simetris".

**Spesifikasi perbaikan:**
```dart
// body_analyzer.dart — ubah signature agar menerima baseline opsional
BodyPosture analyzePosture({
  required DetectedPose pose,
  required Map<JointType, JointAngle> jointAngles,
  BodyPosture? baseline,   // BARU — dari BaselinePoseService.capturedBaseline
}) {
  // Jika baseline tersedia, hitung deviasi RELATIF terhadap baseline,
  // bukan terhadap asumsi "tegak sempurna" universal.
  // Contoh: toleransi simetri bahu = 8° + baseline.shoulderSymmetryDiff
  // (baseline dianggap sebagai "titik nol" personal pengguna).
}
```
`MotionProcessor` perlu menerima `BodyPosture? baseline` dari luar (dari `CalibrationService` yang sudah menjalankan kalibrasi di awal sesi) dan meneruskannya ke `BodyAnalyzer` di setiap frame. Ini perubahan additive (parameter opsional dengan default `null` → perilaku lama tetap jadi fallback jika kalibrasi belum pernah dijalankan), jadi **tidak breaking** untuk kode yang sudah memanggil `analyzePosture()` tanpa baseline.

## 7. Perbaikan #5 — Reduksi Delay Visual pada Garis Skeleton

**Konteks:** Garis skeleton yang tampil di layar (`SkeletonPainter`) **tidak** menggambar posisi mentah landmark ML Kit — ia melewati filter EMA tersendiri di `PoseRenderer` yang independen dari `MovementSmoother` (dipakai untuk analisis sudut di modul `motion`). Kedua smoother ini **terpisah total** dan tidak saling memengaruhi — penting untuk didokumentasikan supaya developer berikutnya tidak bingung mengira ada satu smoother global.

**File:** `lib/features/camera/pose_overlay/pose_renderer.dart`

**Kondisi saat ini:**
```dart
class PoseRenderer {
  PoseRenderer({this.alpha = 0.25});   // filter EMA cukup berat → delay visual terasa
```

**Spesifikasi perbaikan:**
```dart
class PoseRenderer {
  PoseRenderer({this.alpha = 0.45});   // lebih responsif; trade-off: jitter sedikit lebih terlihat
```
Nilai pasti (`0.4`–`0.5`) perlu diuji langsung di device fisik — beri opsi `alpha` dapat dikonfigurasi dari `showDebugHUD`/pengaturan developer supaya QA bisa membandingkan beberapa nilai tanpa rebuild.

**File kedua:** `lib/features/camera/presentation/workout_camera_page.dart`
```dart
_frameProcessor = FrameProcessor(minIntervalMs: 33); // ~30 FPS throttle
```
Ini adalah plafon atas, bukan jaminan FPS — `FrameProcessor` tetap membuang frame jika inferensi ML Kit native lebih lambat dari nilai ini (busy-lock). Menurunkan angka ini **hanya efektif di device kelas menengah-atas**. Sebelum diubah, verifikasi lebih dulu dengan `showDebugHUD` (menampilkan FPS aktual via `DebugOverlay`) apakah bottleneck sungguh ada di throttle atau di kecepatan inferensi device.

**Rekomendasi lanjutan (opsional, prioritas lebih rendah):** hubungkan `lib/features/validation/services/performance_monitor.dart` (sudah ada, saat ini tampaknya belum terpakai untuk mengatur throttle) ke `FrameProcessor` agar `minIntervalMs` menyesuaikan diri secara adaptif berdasarkan performa device real-time, alih-alih angka statis `33` yang sama untuk semua device.

**Jangan diubah:** `PoseDetectionModel.base` di `pose_detector_service.dart` (model ML Kit sudah pilihan tercepat, jangan ganti ke `.accurate`) dan `ResolutionPreset.medium` di `camera_service.dart` (sudah sweet-spot performa vs akurasi).

## 8. Perbaikan #6 — Modernisasi Visual Skeleton Line

**File:** `lib/features/camera/pose_overlay/skeleton_painter.dart`

**Kondisi saat ini:** Garis putih polos + outline hitam statis, ketebalan garis seragam untuk semua tulang, titik sendi berupa lingkaran polos. Fungsional, tapi terasa generik/flat dibanding tampilan AR fitness modern (mis. Nike Training Club, Apple Fitness+).

**Rekomendasi perbaikan (bisa dikerjakan bertahap, urut dari dampak visual tertinggi vs biaya performa terendah):**

**a. Warna dinamis terhubung ke status feedback real-time**
`FeedbackEngine` sudah menghasilkan `FeedbackResult.skeletonColor` (berubah sesuai `AppColors.warning`/`.error`/`.success` tergantung kondisi gerakan — lihat `feedback_rule_engine.dart`), tapi **perlu diverifikasi apakah `SkeletonPainter` benar-benar menerima dan memakai warna ini** — dari kode yang diaudit, `SkeletonPainter` masih hardcode `Colors.white`. Jika belum terhubung, ini prioritas utama: skeleton yang berubah hijau saat gerakan benar dan merah/kuning saat perlu koreksi jauh lebih informatif sekaligus modern dibanding warna putih statis.
```dart
SkeletonPainter({
  required this.pose,
  required this.metrics,
  required this.renderer,
  this.minConfidence = 0.20,
  Color skeletonColor = Colors.white,   // BARU — terima dari FeedbackResult
});
```

**b. Efek glow/neon dengan `MaskFilter`**
```dart
final Paint _boneGlowPaint = Paint()
  ..color = Colors.cyanAccent.withValues(alpha: 0.5)
  ..strokeWidth = 10.0
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
```
Gambar layer glow ini **di bawah** garis utama (sebelum `_bonePaint`) untuk efek cahaya lembut ala AR modern. Uji dampak performa di device kelas bawah — `MaskFilter.blur` tidak gratis; jika FPS turun signifikan, batasi glow hanya pada sendi utama yang sedang jadi fokus latihan, bukan seluruh skeleton.

**c. Opacity/warna berbasis confidence per landmark**
Landmark dengan `likelihood` rendah (mendekati `minConfidence`) digambar makin transisi/pudar, bukan solid penuh — memberi sinyal visual jujur soal keyakinan deteksi, sekaligus terasa lebih "hidup":
```dart
final opacity = (landmark.likelihood.clamp(0.0, 1.0) - minConfidence) / (1.0 - minConfidence);
_jointPaint.color = Colors.white.withValues(alpha: opacity.clamp(0.3, 1.0));
```

**d. Ketebalan garis anatomis (proksimal tebal, distal tipis)**
Tulang besar (bahu–panggul, bahu–siku) digambar lebih tebal dari tulang kecil (siku–pergelangan) — pola ini dipakai aplikasi AR fitness kelas atas dan membuat skeleton terlihat lebih presisi secara visual, bukan seragam kaku.

**e. Animasi pulsasi sendi saat fase hold/rep selesai (opsional, prioritas rendah)**
Saat `FeedbackType.liveCoaching` bertipe `hold_phase` atau `workout_completed` aktif (lihat rule di `feedback_rule_engine.dart`), radius lingkaran sendi utama bisa berdenyut halus (`AnimationController` terpisah dari `CustomPainter` repaint pose, supaya tidak menambah beban ke pipeline real-time). Ini murni polish, kerjakan paling akhir setelah (a)–(d) selesai dan stabil.

**Batasan wajib:** setiap penambahan visual **tidak boleh mengorbankan FPS** yang sudah dioptimalkan di Perbaikan #5. Uji tiap perubahan (a)–(e) satu per satu di device fisik kelas menengah-bawah (bukan hanya emulator/flagship), dengan `showDebugHUD` aktif untuk memantau FPS sebelum dan sesudah.

## 9. Koordinasi & Dampak Lintas Modul

Perbaikan #4 mengubah signature `BodyAnalyzer.analyzePosture()` dan `MotionProcessor.processPose()` — keduanya dipanggil dari **workout session** (kemungkinan `workout_session/controllers/` atau sejenisnya) dan **feedback engine** (`FeedbackRuleEngine.evaluate()` menerima `MotionAnalysis` yang dihasilkan `MotionProcessor`). Sebelum mengubah signature:
1. Cari semua pemanggil `MotionProcessor.processPose(` di seluruh codebase.
2. Pastikan parameter baru (`baseline`) diberi nilai default `null` di semua titik panggil yang belum siap mengirim baseline, supaya build tidak pecah.
3. Jalankan `flutter analyze` setelah perubahan untuk menangkap seluruh titik panggil yang perlu disesuaikan compiler akan otomatis menandainya kalau parameter dibuat required tanpa default.

## 10. Definition of Done

- [ ] Tidak ada lagi teks yang mengasumsikan pengguna bisa berdiri di `validation/**` dan `camera/**`
- [ ] Seluruh threshold confidence merujuk satu konstanta (`MotionTrackingConstants.kMinLandmarkConfidence`), tidak ada angka hardcoded ganda
- [ ] Keputusan soal sendi kaki (hapus atau dipertahankan dengan alasan terdokumentasi) sudah dieksekusi dan dikomentari
- [ ] `BodyAnalyzer` menerima baseline opsional dan memakainya untuk menghitung deviasi personal, dengan fallback ke perilaku lama jika baseline `null`
- [ ] `PoseRenderer.alpha` diuji ulang di device fisik (bukan hanya emulator) dan nilai final terdokumentasi alasannya (bukan sekadar tebak angka)
- [ ] `SkeletonPainter` terhubung ke `FeedbackResult.skeletonColor` (atau terkonfirmasi sudah terhubung, dengan referensi baris kode) — bukan lagi warna putih statis
- [ ] Minimal 2 dari 5 rekomendasi modernisasi visual (Bagian 8, poin a–e) diimplementasikan, diprioritaskan (a) warna dinamis dan (d) ketebalan anatomis karena dampak visual tinggi dengan biaya performa rendah
- [ ] FPS terukur (via `DebugOverlay`) tidak turun signifikan (>10%) di device kelas menengah-bawah dibanding sebelum perubahan visual
- [ ] `flutter analyze` bersih, tidak ada breaking change pada pemanggil existing
- [ ] Unit test baru: `body_analyzer_test.dart` — kasus dengan baseline vs tanpa baseline harus menghasilkan hasil klasifikasi postur yang berbeda untuk input sudut yang sama
- [ ] Regresi manual: jalankan sesi latihan nyata di device sebelum dan sesudah perubahan, pastikan feedback suara/visual tidak berubah perilaku secara tidak sengaja untuk kasus tanpa baseline

## 11. Catatan untuk AI Coding Assistant

1. **Baca dulu** `lib/features/motion/domain/motion_processor.dart` secara utuh — ini orkestrator pusat, memahami urutan pipeline-nya (angle → smooth → posture → direction → validate) wajib sebelum mengubah bagian mana pun.
2. Perbaikan #1–#3 berisiko rendah (isolated fix). Perbaikan #4 berisiko lebih tinggi karena mengubah signature fungsi lintas file — kerjakan paling akhir dari kelompok #1–#4, dan setelah #1–#3 selesai serta di-commit terpisah, supaya kalau #4 perlu di-revert, #1–#3 tidak ikut hilang.
3. Perbaikan #5 dan #6 (delay visual & modernisasi skeleton) **terisolasi di folder `camera/pose_overlay/` dan `camera/services/`** — risiko konflik dengan #1–#4 (folder `motion/` dan `validation/`) rendah, keduanya bisa dikerjakan paralel atau di commit terpisah tanpa saling menunggu.
4. Untuk Perbaikan #6, kerjakan poin (a)–(e) **satu per satu dengan commit terpisah**, bukan sekaligus — supaya kalau satu efek visual ternyata menjatuhkan FPS di device tertentu, developer bisa revert poin itu saja tanpa kehilangan poin lain yang sudah bekerja baik.
5. Jangan mengubah `JointAngleCalculator.calculateAngle2D()` — rumus vektornya sudah benar secara matematis, potensi bug ada di *pemakaian* hasilnya (threshold, konteks), bukan di rumus itu sendiri.
6. Jangan menyentuh `lib/features/auth/**` atau `lib/features/community/**` — di luar cakupan task ini.