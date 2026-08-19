# Technical Requirements Document (TRD)
## Modul: Penyambungan Kamera ke Sesi Latihan (`LiveCameraScreen` ↔ Motion Engine)

| | |
|---|---|
| **Proyek** | GerakIn — KMIPN VIII 2026 |
| **Branch** | `feature/wire-camera-to-live-session` |
| **Status saat ini** | **Blocker kritis.** Seluruh pipeline motion tracking (kamera → ML Kit → sudut sendi → rep counter → feedback → alert) sudah lengkap dan berfungsi baik secara terisolasi, tapi **tidak tersambung** ke layar sesi latihan sungguhan (`/workout-session/live`). Layar itu saat ini hanya menampilkan ikon dekoratif statis, bukan kamera nyata. |
| **Folder kerja** | `lib/features/workout_session/presentation/live_camera_screen.dart`, `lib/features/workout_session/controllers/workout_session_controller.dart` (pemakaian, bukan perubahan besar), referensi pola dari `lib/features/camera/presentation/workout_camera_page.dart` |
| **Ditujukan untuk** | Developer manusia maupun AI coding assistant |

---

## 1. Ringkasan & Tujuan

Ini adalah **prioritas tertinggi** di antara seluruh TRD yang ada — tanpa perbaikan ini, aplikasi tidak bisa melacak gerakan pengguna sama sekali di alur pemakaian nyata, terlepas dari seberapa baik komponen lain (skeleton rendering, rep counter, voice coach, alert system) sudah dibangun.

**Kabar baik:** solusinya bukan membangun sesuatu yang baru. Ada implementasi kamera+ML Kit yang **sudah terbukti bekerja** di `lib/features/camera/presentation/workout_camera_page.dart` (halaman terpisah, kemungkinan awalnya dibuat untuk keperluan testing/demo kamera). TRD ini pada dasarnya adalah pekerjaan **mengadaptasi pola yang sudah terbukti itu**, bukan riset dari nol.

## 2. Cakupan

**In-scope:**
1. Mengintegrasikan `CameraService` + `PoseDetectorService` + `FrameProcessor` ke `LiveCameraScreen`
2. Mengganti tampilan kamera dekoratif dengan `CameraPreviewWidget` + `SkeletonOverlay` yang nyata
3. Memanggil `WorkoutSessionController.processFrame()` di setiap frame kamera yang berhasil diproses
4. Menyambungkan warna skeleton dinamis ke `activeAlert.severity` yang sudah ada (bukan bikin logika warna baru)
5. Menangani lifecycle kamera (pause/resume saat app di background, dispose saat keluar layar) dan error state (kamera gagal dibuka/izin ditolak)
6. **Konsolidasi**: menghindari duplikasi logika kamera antara `WorkoutCameraPage` dan `LiveCameraScreen` yang kalau dibiarkan copy-paste akan menyebabkan dua implementasi kamera yang bisa saling divergen (persis seperti yang menyebabkan gap ini tidak terdeteksi lebih awal)

**Out-of-scope:**
- Mengubah `WorkoutSessionEngine`/`WorkoutSessionController` — kontrak `processFrame(List<PoseLandmarkModel>)` sudah benar, tidak perlu diubah
- Mengganti model ML Kit atau resolusi kamera (sudah optimal, lihat `TRD_MOTION_TRACKING_REFINEMENT.md`)
- Menghapus `WorkoutCameraPage` — biarkan tetap ada sebagai halaman testing/debug terpisah (route `/camera` di luar shell), tapi lihat Bagian 5 soal konsolidasi logika-nya

## 3. Referensi Implementasi yang Sudah Terbukti

**File acuan:** `lib/features/camera/presentation/workout_camera_page.dart` — baca ini dulu secara utuh sebelum menulis kode apa pun. Pola intinya:

```dart
_cameraService = CameraService();
_poseDetectorService = PoseDetectorService();
_frameProcessor = FrameProcessor(minIntervalMs: 33);

await _cameraService.initialize();
await _cameraService.startImageStream((CameraImage image) async {
  final camera = _cameraService.currentCamera;
  if (camera == null) return;

  final detectedPose = await _frameProcessor.processFrame<DetectedPose>(
    cameraImage: image,
    cameraDescription: camera,
    onProcess: (inputImage) async {
      return await _poseDetectorService.processImage(
        inputImage: inputImage,
        isFrontCamera: _cameraService.isFrontCamera,
      );
    },
  );

  if (detectedPose != null && mounted) {
    // → di sinilah titik sambung ke WorkoutSessionController (Bagian 4)
  }
});
```

Lifecycle handling (wajib disalin polanya, jangan dilewatkan):
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  final controller = _cameraService.controller;
  if (controller == null || !controller.value.isInitialized) return;

  if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
    _cameraService.stopImageStream();
  } else if (state == AppLifecycleState.resumed) {
    _startStream();
  }
}

@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  _cameraService.dispose();
  _poseDetectorService.close();
  super.dispose();
}
```

## 4. Titik Sambung ke `WorkoutSessionController`

**Ini bagian intinya — cuma satu baris penting yang hilang.** `WorkoutSessionController` sudah punya method siap pakai:
```dart
void processFrame(List<PoseLandmarkModel> landmarks) {
  if (landmarks.isEmpty) return;
  final jointType = state.exercise.targetAngles.primaryJoint;
  final calculatedAngle = _calculatePrimaryAngle(landmarks, jointType);
  _engine.processCameraFrame(landmarks, calculatedAngle);
  _updateUI(landmarks: landmarks);
}
```
`DetectedPose` (hasil `PoseDetectorService`) menyimpan landmark sebagai `Map<PoseLandmarkType, PoseLandmarkModel>` — konversinya sepele:
```dart
if (detectedPose != null && mounted) {
  ref.read(workoutSessionControllerProvider(widget.exercise).notifier)
     .processFrame(detectedPose.landmarks.values.toList());
}
```
Itu saja. Tidak perlu logika kalkulasi sudut tambahan di `LiveCameraScreen` — semua sudah ditangani `WorkoutSessionController._calculatePrimaryAngle()` dan `WorkoutSessionEngine.processCameraFrame()`, termasuk kalibrasi, rep counting, voice coach, dan alert (`_evaluateLiveAlerts`).

## 5. Konsolidasi: Hindari Duplikasi Setup Kamera

**Masalah desain yang perlu dicegah:** kalau `LiveCameraScreen` menyalin-tempel seluruh `_initializeCamera()`/`_startStream()` dari `WorkoutCameraPage` apa adanya, proyek ini akan punya **dua implementasi setup kamera yang terpisah** — persis pola yang menyebabkan gap modul ini tidak ketahuan sejak awal (bandingkan dengan kasus `VoiceCoach` vs `VoiceFeedbackService` yang sempat duplikat, sudah dibereskan di TRD lain).

**Spesifikasi wajib:** ekstrak logika setup kamera ke satu class/mixin yang dipakai bersama:
```dart
// lib/features/camera/services/camera_pose_stream_controller.dart — BARU
/// Mengelola siklus hidup CameraService + PoseDetectorService + FrameProcessor
/// sebagai satu unit yang bisa dipakai ulang oleh halaman manapun yang butuh
/// stream pose real-time (WorkoutCameraPage, LiveCameraScreen, dan halaman masa depan).
class CameraPoseStreamController {
  final CameraService cameraService;
  final PoseDetectorService poseDetectorService;
  final FrameProcessor frameProcessor;

  CameraPoseStreamController({int minIntervalMs = 33})
      : cameraService = CameraService(),
        poseDetectorService = PoseDetectorService(),
        frameProcessor = FrameProcessor(minIntervalMs: minIntervalMs);

  Future<void> initialize() async => cameraService.initialize();

  Future<void> startStream(void Function(DetectedPose pose) onPoseDetected) async {
    await cameraService.startImageStream((CameraImage image) async {
      final camera = cameraService.currentCamera;
      if (camera == null) return;

      final detectedPose = await frameProcessor.processFrame<DetectedPose>(
        cameraImage: image,
        cameraDescription: camera,
        onProcess: (inputImage) => poseDetectorService.processImage(
          inputImage: inputImage,
          isFrontCamera: cameraService.isFrontCamera,
        ),
      );

      if (detectedPose != null) onPoseDetected(detectedPose);
    });
  }

  void dispose() {
    cameraService.dispose();
    poseDetectorService.close();
  }
}
```
Setelah class ini dibuat, **refactor `WorkoutCameraPage` juga untuk memakainya** (bukan cuma `LiveCameraScreen`) — supaya tidak ada dua salinan logika yang bisa divergen lagi di masa depan. Ini pekerjaan tambahan kecil tapi penting untuk mencegah masalah yang sama terulang.

## 6. Perubahan UI di `LiveCameraScreen`

**Ganti** blok dekoratif ini:
```dart
Container(
  color: const Color(0xFF020617),
  child: Center(child: Column(children: [Icon(Icons.videocam_rounded), ...])),
)
```
**Menjadi:**
```dart
Positioned.fill(
  child: CameraPreviewWidget(
    controller: _cameraStreamController.cameraService.controller!,
    pose: _currentPose,
    showSkeleton: true,
    showDebugHUD: uiState.isDevModeEnabled,
    skeletonColor: _alertToSkeletonColor(uiState.activeAlert),
  ),
),
```
**Pemetaan warna skeleton dari alert yang sudah ada** (jangan bikin logika baru — manfaatkan `LiveAlert` yang sudah dibangun di TRD sebelumnya):
```dart
Color _alertToSkeletonColor(LiveAlert? alert) {
  if (alert == null) return AppColors.success;       // tidak ada masalah → hijau
  return alert.severity == AlertSeverity.critical
      ? AppColors.error
      : AppColors.warning;                            // warning → kuning, critical → merah
}
```

**Wajib ditambahkan — state loading & error** (saat ini `LiveCameraScreen` tidak punya penanganan untuk kamera gagal dibuka/izin ditolak, padahal `WorkoutCameraPage` sudah punya pola `_isLoading`/`_errorMessage`/`ErrorState` yang baik — salin pola yang sama). Ini krusial untuk demo kompetisi: kalau kamera gagal diakses di device juri dan tidak ada pesan error yang jelas, akan terlihat seperti aplikasi *hang*/rusak.

## 7. Definition of Done

- [ ] `CameraPoseStreamController` dibuat dan dipakai oleh **kedua** `WorkoutCameraPage` dan `LiveCameraScreen` (tidak ada duplikasi setup kamera)
- [ ] `LiveCameraScreen` menampilkan feed kamera nyata + skeleton overlay, bukan ikon statis
- [ ] `WorkoutSessionController.processFrame()` terpanggil di setiap frame yang berhasil diproses, terverifikasi lewat `DevDebugOverlay` (FPS dan landmark count harus menunjukkan angka nyata, bukan 0)
- [ ] Warna skeleton berubah sesuai `activeAlert` (hijau normal → kuning warning → merah critical), teruji dengan menutup sebagian tubuh dari kamera untuk memicu alert
- [ ] Kalibrasi pra-latihan (`WorkoutState.calibrating`) benar-benar menerima data pose nyata dan bisa selesai secara alami (bukan macet karena tidak ada input)
- [ ] Lifecycle kamera ditangani: app di-*background*-kan saat latihan berlangsung tidak menyebabkan crash, kamera resume dengan benar saat app dibuka kembali
- [ ] State error ada untuk kasus kamera gagal dibuka/izin ditolak, dengan opsi "Coba Lagi"
- [ ] Uji end-to-end nyata: buka `/workout-session/live`, kalibrasi berhasil, lakukan gerakan latihan sungguhan di depan kamera, rep counter bertambah, suara terdengar, alert muncul saat sengaja keluar dari frame
- [ ] `flutter analyze` bersih

## 8. Catatan untuk AI Coding Assistant

1. **Baca `workout_camera_page.dart` secara utuh sebelum menulis kode apa pun** — ini bukan saran, ini prasyarat. Jangan menciptakan pola integrasi kamera baru dari nol; risiko tinggi salah menangani lifecycle/error kalau tidak mengikuti pola yang sudah terbukti bekerja.
2. Setelah `CameraPoseStreamController` dibuat, **jangan lupa refactor `WorkoutCameraPage`** untuk memakainya juga (Bagian 5) — kalau di-skip, tujuan konsolidasi gagal dan proyek kembali punya dua implementasi paralel.
3. Jangan mengubah signature `WorkoutSessionController.processFrame()` atau `WorkoutSessionEngine.processCameraFrame()` — keduanya sudah benar, titik sambungnya ada di sisi `LiveCameraScreen`, bukan di controller/engine.
4. Uji di device fisik, bukan cuma emulator — kamera dan performa real-time tidak representatif di emulator.