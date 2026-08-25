# Technical Requirements Document (TRD)
## Modul: Konsistensi UI, Flow Pra-Latihan, Streak, Komunitas & Persistensi Progres

| | |
|---|---|
| **Proyek** | GerakIn — KMIPN VIII 2026 |
| **Branch** | `feature/ui-flow-gamification-fixes` (bisa dipecah per Bagian jika dikerjakan >1 orang — lihat Bagian 8) |
| **Status saat ini** | Audit langsung ke kode menemukan 5 temuan konkret, satu per poin yang diajukan. Detail dan bukti di tiap Bagian. |
| **Folder kerja** | `lib/core/theme/**`, `lib/features/workout_session/**`, `lib/features/gamification/**`, `lib/features/community/**` |
| **Ditujukan untuk** | Developer manusia maupun AI coding assistant |

---

## 1. Ringkasan & Tujuan

TRD ini mencakup 5 area perbaikan berbeda sifat — dari polish visual sampai bug fungsional dan modul yang belum tersentuh. Ringkasan status tiap poin sebelum masuk detail:

| # | Poin | Status Terverifikasi |
|---|---|---|
| 1 | UI, palet warna, konsistensi font | 🟡 Design system sudah bagus & lengkap, tapi **tidak dipakai konsisten** — sebagian layar 100% hardcode warna/font berbeda |
| 2 | Flow halaman tutorial | 🔴 Bug nyata ditemukan: **safety checklist bisa dilewati** lewat jalur navigasi alternatif |
| 3 | Modul Streak | 🔴 Logic lengkap & benar, tapi **tidak pernah dipanggil** — streak tidak akan pernah bertambah |
| 4 | Modul Komunitas | 🔴 Masih placeholder total, belum ada yang dikerjakan (TRD terpisah sudah ada) |
| 5 | Progres latihan tersimpan? | 🟡 Sebagian — data ditulis ke ObjectBox, tapi **jalur baca mengabaikannya**, pakai cache memori yang hilang saat restart |

## 2. Cakupan

**In-scope:** kelima poin di atas, sebagaimana dirinci di Bagian 3–7.

**Out-of-scope:**
- Membangun modul Community dari nol (sudah ada TRD terpisah: `TRD_COMMUNITY_MODULE.md` — Bagian 6 di sini hanya menegaskan status & keterkaitannya, bukan spesifikasi ulang)
- Fitur gamifikasi lain di luar Streak (XP, Level, Mission, Challenge) — kemungkinan besar punya masalah keterhubungan serupa (lihat catatan di Bagian 5), tapi verifikasi mendalam untuk itu di luar cakupan TRD ini

---

## 3. Bagian A — Konsistensi UI, Palet Warna, dan Font

**Temuan:** `lib/core/theme/` punya design system yang sudah matang — `AppColors` (skema Material 3 teal-ungu, lengkap dengan varian light/dark, semantic colors), `AppTextStyles` (skala tipografi lengkap pakai Google Fonts *Plus Jakarta Sans*), dan `AppTheme` yang mengikat semuanya ke komponen Material (button, input, dialog, dsb.). **Sistemnya sendiri sudah bagus, tidak perlu dirombak.**

**Masalahnya:** sebagian besar layar di `features/workout_session/presentation/` dan `features/workout_session/widgets/` **sama sekali tidak memakai token ini** — hardcode warna dan style sendiri, dengan palet yang beda total (dark navy + hijau neon) dari design system resmi (teal `#00BFA5` + ungu `#6C63FF`). Contoh konkret, dari 4 file berbeda:
```dart
// exercise_detail_screen.dart, movement_preview_screen.dart, pre_workout_checklist.dart, live_camera_screen.dart
backgroundColor: const Color(0xFF0F172A),          // seharusnya AppColors.surface / surfaceDark
color: const Color(0xFF1E293B),                     // seharusnya AppColors.surfaceContainer
color: const Color(0xFF00E676),                     // seharusnya AppColors.primary / success
style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),  // seharusnya AppTextStyles.titleMedium
```
Akibatnya aplikasi terasa seperti **punya dua identitas visual berbeda** — bagian yang pakai design system (kemungkinan besar halaman `home`, `user`/profil, `analytics`) terasa modern & konsisten Material 3, sementara seluruh alur latihan (justru fitur inti aplikasi!) terasa seperti aplikasi lain.

**Spesifikasi perbaikan:**
1. **Jangan buat palet baru.** Migrasikan seluruh hardcoded color/style di `workout_session/**` ke token `AppColors`/`AppTextStyles` yang sudah ada.
2. Kalau tim memang **sengaja** ingin nuansa gelap/energik khusus untuk layar latihan (alasan valid: kontras tinggi lebih baik dilihat saat bergerak/berkeringat), maka putuskan itu secara sadar dan formalkan sebagai **varian resmi** di design system — misalnya tambahkan token baru `AppColors.workoutSurfaceDark`, `AppColors.workoutAccent` di `app_colors.dart`, bukan angka hex lepas di tiap file. Ini keputusan tim, bukan keputusan teknis semata — dokumentasikan alasannya di kode.
3. **Cegah regresi:** tambahkan custom lint rule atau script CI sederhana yang mendeteksi literal `Color(0xFF...)` dan `TextStyle(` langsung di luar `lib/core/theme/` dan `lib/shared/widgets/`, supaya masalah ini tidak terulang tanpa disadari developer berikutnya.

```yaml
# contoh custom_lint rule (analysis_options.yaml) — sesuaikan dengan tooling yang tersedia
# atau skrip grep sederhana di CI:
# grep -rn "Color(0xFF" lib/features --include=*.dart | grep -v "core/theme"
```

## 4. Bagian B — Perbaikan Flow Halaman Pra-Latihan ("Tutorial")

**Catatan awal:** tidak ditemukan fitur bernama "tutorial"/"onboarding" di codebase manapun — pencarian `*tutorial*`, `*onboard*`, `*guide*`, `*intro*` semuanya nihil. Yang paling dekat dengan maksud "tutorial" adalah alur 3 layar sebelum latihan dimulai: `ExerciseDetailScreen` → `MovementPreviewScreen` → `LiveCameraScreen`. **Bug ditemukan di alur ini.**

### 4.1 Bug: Safety Checklist Bisa Dilewati

`ExerciseDetailScreen` (Screen 1) punya **dua jalur berbeda** menuju sesi latihan:

| Jalur | Trigger | Melewati checklist? |
|---|---|---|
| A | Tombol "MULAI LATIHAN" di bawah | Tidak — tombol disabled sampai `_isChecklistComplete == true` |
| B | Banner "PRATINJAU GERAKAN" → `MovementPreviewScreen` → tombol "LANJUT KE KALIBRASI KAMERA" | **Ya — langsung `context.push('/workout-session/live', ...)` tanpa cek checklist apa pun** |

```dart
// movement_preview_screen.dart — tombol ini TIDAK mengecek status checklist
onPressed: () {
  context.push('/workout-session/live', extra: widget.exercise);
},
```
Pengguna yang masuk lewat Jalur B tidak pernah diminta konfirmasi "area latihan aman", "pencahayaan cukup", atau "tidak sedang nyeri akut" — tiga hal yang justru krusial untuk pengguna kursi roda sebelum melakukan gerakan fisik.

**Spesifikasi perbaikan:**
```dart
// MovementPreviewScreen perlu menerima status checklist dari layar sebelumnya
class MovementPreviewScreen extends StatefulWidget {
  const MovementPreviewScreen({
    super.key,
    required this.exercise,
    required this.isChecklistComplete,   // BARU — diteruskan dari ExerciseDetailScreen
  });
  final bool isChecklistComplete;
  // ...
}

// Tombol "LANJUT KE KALIBRASI KAMERA":
onPressed: widget.isChecklistComplete
    ? () => context.push('/workout-session/live', extra: widget.exercise)
    : () => _showChecklistRequiredDialog(context),   // BARU — arahkan kembali untuk melengkapi checklist
```
Alternatif yang lebih tegas secara arsitektur: pindahkan `PreWorkoutChecklistWidget` supaya jadi **satu-satunya gerbang** sebelum route `/workout-session/live`, dilewati oleh kedua jalur (mis. jadi bagian dari `LiveCameraScreen` sendiri sebagai step pertama sebelum kalibrasi kamera dimulai), bukan diulang-cek di dua tempat berbeda yang gampang divergen seperti kasus ini.

### 4.2 Bug Sekunder: Data Fallback Tidak Konsisten dengan Skop Aplikasi

`ExerciseDetailScreen._getFallbackExercise()` — dipakai kalau `widget.exercise` null (mis. route diakses langsung tanpa `extra`) — mendefinisikan latihan **"Shoulder Abduction" untuk rehabilitasi pasca-stroke dengan posisi awal "Berdiri tegak"**:
```dart
startPose: 'Berdiri tegak, tangan rileks di samping panggul',
```
Ini bertentangan langsung dengan keputusan skop aplikasi (khusus pengguna kursi roda, tanpa asumsi bisa berdiri) yang sudah ditegaskan berkali-kali di proposal dan TRD lain. Ganti fallback ini dengan salah satu entri nyata dari `exercises.json` (mis. via `ExerciseLibraryRepository`), bukan data hardcoded terpisah yang bisa kadaluarsa/tidak sinkron.

## 5. Bagian C — Modul Streak

**Temuan:** `StreakEngine.recordActivity(userId)` — lengkap dan benar secara logika (mengecek gap hari, reset/lanjut streak, simpan ke `GamificationRepository`, sinkron ke Firestore lewat `SyncRepository`) — **tidak pernah dipanggil dari manapun**. Diverifikasi langsung di `WorkoutSessionController.finishWorkout()`:
```dart
Future<void> finishWorkout() async {
  _engine.finishWorkout();
  _updateUI();

  if (_engine.summaryResult != null) {
    final sessionData = WorkoutSessionData(/* ... */);
    await repository.saveSession(sessionData);   // ← HANYA INI. Tidak ada panggilan StreakEngine/XpEngine/LevelEngine di sini.
  }
}
```
Jawaban langsung untuk pertanyaan "apakah modul Streak sudah berfungsi?": **Belum** — secara teknis "berfungsi" dalam arti logikanya benar kalau dipanggil, tapi dari sudut pandang pengguna, streak tidak akan pernah bertambah karena titik pemanggilannya hilang.

**Spesifikasi perbaikan:**
```dart
Future<void> finishWorkout() async {
  _engine.finishWorkout();
  _updateUI();

  if (_engine.summaryResult != null) {
    final sessionData = WorkoutSessionData(/* ... */);
    await repository.saveSession(sessionData);

    // BARU — panggil gamification engine setelah sesi berhasil disimpan
    final userId = /* ambil dari currentAuthUserProvider / profil aktif */;
    await ref.read(streakEngineProvider).recordActivity(userId);
    // Sekalian evaluasi apakah XpEngine/LevelEngine juga terlewat sama (lihat catatan di bawah)
  }
}
```
**Catatan penting:** `WorkoutSessionController` saat ini adalah `StateNotifier` biasa, bukan yang punya akses `ref.read()` langsung di dalam method (`ref` biasanya diakses dari provider constructor, bukan dari dalam class). Sesuaikan pola: passing `StreakEngine` sebagai dependency ke constructor `WorkoutSessionController` (mengikuti pola `repository` yang sudah ada), diambil dari provider saat controller dibuat.

**Verifikasi tambahan yang direkomendasikan (di luar cakupan wajib, tapi high-value):** cek apakah `XpEngine`, `LevelEngine`, `GoalTrackingService`, dan `MissionEngine` di modul `gamification` punya masalah yang sama (dibangun lengkap tapi tidak terpanggil). Pola "dibangun-tapi-tidak-disambung" sudah terbukti berulang di proyek ini (lihat TRD sebelumnya soal `FeedbackRuleEngine` dan koneksi kamera) — kemungkinan besar seluruh keluarga *engine* di `gamification/services/` bernasib sama dan butuh disambungkan sekaligus di titik yang sama (`finishWorkout()`).

## 6. Bagian D — Modul Komunitas

**Status:** tidak berubah dari audit-audit sebelumnya — `community_page.dart` masih placeholder identik, belum ada satu baris pun logika forum/post/komentar. TRD lengkap untuk modul ini **sudah ada**: `TRD_COMMUNITY_MODULE.md` (dibuat sebelumnya di sesi ini), mencakup skema data, integrasi `SyncRepository`, moderasi konten, dan kontrak dengan modul Auth.

**Tindakan untuk TRD ini:** tidak perlu spesifikasi ulang — pastikan `TRD_COMMUNITY_MODULE.md` masuk antrean pengerjaan tim, karena sampai saat ini progresnya nol dari seluruh TRD yang sudah diserahkan.

## 7. Bagian E — Persistensi Progres Latihan

**Temuan:** `ObjectBoxWorkoutSessionRepository.saveSession()` menulis dengan benar ke ObjectBox (`box.put(entity)`). **Tapi** kedua method baca-nya —
```dart
Future<WorkoutSessionData?> getSessionById(String id) async {
  return _memoryFallbackStore[id];        // ← hanya baca dari Map di memori
}
Future<List<WorkoutSessionData>> getAllSessions() async {
  return _memoryFallbackStore.values.toList();  // ← sama
}
```
— **hanya membaca dari `_memoryFallbackStore`, sebuah `Map` Dart biasa yang hidup selama proses aplikasi berjalan**, bukan dari ObjectBox. Efeknya: data teknisnya "tersimpan" (ada di database lokal), tapi **tidak pernah bisa diambil kembali lewat repository ini setelah aplikasi di-restart** — dari sudut pandang pengguna, riwayat latihan akan terasa hilang.

Jawaban langsung untuk "apakah progres latihan sudah tersimpan?": **Sebagian** — tersimpan secara teknis di ObjectBox, tapi jalur baca yang salah membuatnya seolah tidak tersimpan.

**Spesifikasi perbaikan:**
```dart
@override
Future<WorkoutSessionData?> getSessionById(String id) async {
  if (_store == null) return _memoryFallbackStore[id];
  final box = _store.box<obx.WorkoutSession>();
  final entity = box.query(obx.WorkoutSession_.workoutId.equals(id)).build().findFirst();
  return entity != null ? _mapToSessionData(entity) : _memoryFallbackStore[id];
}

@override
Future<List<WorkoutSessionData>> getAllSessions() async {
  if (_store == null) return _memoryFallbackStore.values.toList();
  final box = _store.box<obx.WorkoutSession>();
  return box.getAll().map(_mapToSessionData).toList();
}

WorkoutSessionData _mapToSessionData(obx.WorkoutSession entity) {
  // perlu method mapping baru — perhatikan entity ObjectBox saat ini TIDAK menyimpan
  // seluruh field WorkoutSessionData (mis. `sets`, `recordedFrames` hilang saat mapping
  // ke obx.WorkoutSession di saveSession()) — putuskan apakah field itu memang tidak perlu
  // disimpan permanen (boleh dibuang setelah summary dihitung) atau perlu ditambahkan ke skema entity.
}
```
**Catatan penting soal desain:** saat menulis ke ObjectBox, `saveSession()` **membuang** beberapa data dari `WorkoutSessionData` (mis. `sets`, `recordedFrames` per-rep) — hanya menyimpan ringkasan (`completedReps`, `accuracy`, `averageRom`, dst.). Ini mungkin memang keputusan yang tepat (menghemat storage — rekaman detail per-frame tidak perlu disimpan permanen), tapi harus jadi **keputusan sadar**, bukan efek samping. Dokumentasikan di kode kalau ini memang disengaja.

**Terhubung dengan Bagian 5:** perbaikan `getAllSessions()` di sini juga jadi prasyarat kalau modul `analytics` (riwayat latihan mingguan/bulanan) ternyata bergantung pada repository ini alih-alih membaca ObjectBox secara langsung — verifikasi keterkaitan ini saat mengerjakan.

---

## 8. Prioritas & Urutan Pengerjaan

| Prioritas | Bagian | Alasan |
|---|---|---|
| 1 | **E — Persistensi progres** | Data pengguna yang hilang adalah masalah kepercayaan paling mendasar; juga prasyarat bagi Bagian C (streak butuh riwayat yang bisa dibaca ulang) |
| 2 | **C — Streak** | Titik sambung kecil (mirip kasus kamera), dampak besar untuk kesan "aplikasi hidup" saat demo |
| 3 | **B — Bug checklist** | Isu keselamatan pengguna, perbaikannya kecil (satu parameter + satu pengecekan) |
| 4 | **A — Konsistensi UI** | Dampak besar ke kesan visual saat presentasi juri, tapi tidak fungsional-kritis — kerjakan setelah bug fungsional beres |
| 5 | **D — Komunitas** | Scope besar, kerjakan terpisah sesuai `TRD_COMMUNITY_MODULE.md`, tidak perlu memblokir 4 bagian lain |

## 9. Koordinasi dengan TRD Lain

Bagian C dan E sama-sama menyentuh `WorkoutSessionController.finishWorkout()` — kalau dikerjakan dua orang berbeda, gabungkan jadi satu urutan pemanggilan yang jelas (simpan sesi → baru catat streak), jangan dua orang mengedit method yang sama secara paralel tanpa koordinasi. Bagian ini juga beririsan dengan `TRD_CAMERA_LIVE_SESSION_WIRING.md` — **selesaikan penyambungan kamera lebih dulu**, karena tanpa itu `finishWorkout()` tidak akan pernah terpanggil secara alami saat pengujian end-to-end (rep counter tidak pernah jalan tanpa data kamera nyata).

## 10. Definition of Done

- [ ] Seluruh warna/font hardcode di `workout_session/**` bermigrasi ke `AppColors`/`AppTextStyles`, atau token baru ditambahkan secara sadar ke design system
- [ ] Lint/CI check ditambahkan untuk mencegah literal warna baru di luar `core/theme/`
- [ ] Tombol "LANJUT KE KALIBRASI KAMERA" di `MovementPreviewScreen` tidak bisa lagi melewati safety checklist
- [ ] Fallback exercise data konsisten dengan skop kursi roda (tidak ada lagi "berdiri tegak")
- [ ] `StreakEngine.recordActivity()` terpanggil setiap `finishWorkout()` sukses, teruji dengan menyelesaikan 2 sesi latihan di hari berbeda dan melihat `currentStreak` bertambah
- [ ] `getSessionById()`/`getAllSessions()` membaca dari ObjectBox, teruji dengan restart aplikasi setelah menyelesaikan sesi dan riwayat tetap muncul
- [ ] Keputusan soal field yang dibuang saat mapping ke ObjectBox didokumentasikan eksplisit di kode
- [ ] `flutter analyze` bersih

## 11. Catatan untuk AI Coding Assistant

1. Bagian C dan E **saling bergantung secara data** (streak butuh riwayat sesi yang valid) tapi **independen secara kode** (file berbeda) — bisa dikerjakan berurutan oleh satu orang atau paralel oleh dua orang asal `finishWorkout()` diedit hati-hati (lihat Bagian 9).
2. Untuk Bagian A, jangan migrasi seluruh file sekaligus dalam satu commit besar — pecah per file (`exercise_detail_screen.dart`, `movement_preview_screen.dart`, `pre_workout_checklist.dart`, `live_camera_screen.dart`, dst.), supaya kalau ada regresi visual di satu layar, mudah di-revert tanpa kehilangan progres di layar lain.
3. Sebelum menulis kode Bagian E, baca `lib/features/analytics/**` untuk memastikan tidak menduplikasi logika query ObjectBox yang mungkin sudah ada di sana.
4. Jangan mengerjakan Bagian D (Komunitas) di TRD ini — rujuk ke `TRD_COMMUNITY_MODULE.md` yang sudah ada, supaya tidak ada dua spesifikasi berbeda untuk modul yang sama.