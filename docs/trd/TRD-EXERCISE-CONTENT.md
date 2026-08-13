# Technical Requirements Document (TRD)
## Modul: Konten Katalog Latihan & Unifikasi Feedback Real-Time (Suara & Peringatan Visual)

| | |
|---|---|
| **Proyek** | GerakIn — KMIPN VIII 2026 |
| **Branch** | `feature/exercise-content-and-live-feedback` |
| **Status saat ini** | Katalog latihan **hanya berisi 5 entri**, tidak ada gerakan kepala/leher, dua kategori yang dijanjikan di proposal (*Wheelchair Aerobics*, *Core Stability*) tidak punya data sama sekali. Aset ilustrasi **kosong total** (folder `assets/images/` dan `assets/icons/` cuma berisi `.gitkeep`). Sistem suara real-time sudah berfungsi tapi datanya tersebar di 3 sumber teks berbeda yang tidak sinkron. Sistem peringatan visual belum ada. |
| **Folder kerja** | `assets/exercises/**`, `lib/features/exercise_library/**`, `lib/features/workout_session/**`, `lib/features/feedback/**` (audit & konsolidasi, bukan folder baru) |
| **Relasi dengan TRD lain** | Modul ini **berdiri sendiri**, tidak digabung dengan `TRD_MOTION_TRACKING_REFINEMENT.md`, meski sama-sama menyentuh alur real-time. Koordinasikan urutan pengerjaan dengan siapa pun yang menggarap TRD tersebut karena ada singgungan file (lihat Bagian 7). |
| **Ditujukan untuk** | Developer manusia maupun AI coding assistant |

---

## 1. Ringkasan & Tujuan

TRD ini mencakup dua kebutuhan yang saling terkait tapi berbeda sifat:

- **Bagian A & B — Konten**: memperluas katalog latihan (termasuk gerakan kepala/leher yang belum ada sama sekali) dan melengkapi aset ilustrasi yang saat ini kosong total.
- **Bagian C — Sistem Feedback Real-Time**: menyatukan tiga sumber teks feedback yang saat ini terpisah dan tidak sinkron, serta membangun sistem peringatan visual (alert) bertingkat yang belum ada — memanfaatkan `FeedbackRuleEngine` yang sudah dibangun tapi ternyata belum tersambung ke sesi latihan nyata.

## 2. Cakupan

**In-scope:**
1. Menambah entri latihan baru: gerakan kepala/leher, serta melengkapi kategori *Wheelchair Aerobics* dan *Core Stability* yang disebut di proposal tapi belum ada datanya
2. Merestrukturisasi skema data untuk mendukung 3 gambar ilustrasi per latihan (bukan 1 seperti sekarang), plus fallback aman kalau aset belum tersedia
3. Menyatukan 3 sumber teks feedback (bubble UI, voice engine, field `voiceInstruction` yang tidak terpakai) jadi satu sumber kebenaran
4. Membangun sistem peringatan visual bertingkat (info/warning/critical) yang tersambung ke kondisi nyata (confidence rendah, pose keluar frame, postur salah), bukan sekadar narasi generik seperti sekarang
5. Menyambungkan `FeedbackRuleEngine` (yang sudah dibangun tapi idle) ke alur `WorkoutSessionEngine` yang sesungguhnya dipakai

**Out-of-scope:**
- Mengganti mekanisme TTS (`flutter_tts` tetap dipakai)
- Video instruksi (hanya gambar statis, sesuai permintaan awal "3 gambar")
- Modul `assets/exercises/exercise_knowledge_base.json` — file ini belum diaudit di TRD ini, kemungkinan berisi konten RAG/AI terpisah, verifikasi cakupannya sebelum menyentuhnya

---

## 3. Bagian A — Perluasan Katalog Latihan

**File:** `assets/exercises/exercises.json`

**Kondisi saat ini (terverifikasi langsung dari isi file):** hanya 5 entri — 2 Warm Up, 1 Range of Motion, 1 Strength Training, 1 Cool Down. Semua menyasar bahu/siku/pergelangan. **Tidak ada** kategori *Wheelchair Aerobics* atau *Core Stability* meski keduanya disebut eksplisit sebagai program inti di proposal KMIPN.

**Skema data wajib diikuti** (persis field yang sudah ada, jangan ubah nama field lama — lihat `lib/features/exercise_library/models/full_exercise_definition.dart` sebagai sumber kebenaran struktur):
```json
{
  "id": "neck_01_...",
  "name": "...",
  "category": "Neck & Head Mobility",
  "difficulty": 1,
  "description": "...",
  "benefit": "...",
  "targetMuscles": ["..."],
  "requiredEquipment": "None (Wheelchair)",
  "movementPattern": "...",
  "startPose": "...",
  "endPose": "...",
  "targetAngles": { "primaryJoint": "...", "startAngle": 0.0, "targetAngle": 0.0 },
  "tolerance": 0.0,
  "tempo": "...",
  "holdDuration": 0,
  "repetitionTarget": 0,
  "setTarget": 0,
  "restDuration": 0,
  "estimatedCalories": 0.0,
  "voiceInstruction": "...",
  "warning": "...",
  "contraindication": "...",
  "tags": ["..."],
  "thumbnailAsset": "assets/exercises/thumbnails/....png",
  "animationAsset": "assets/exercises/animations/....json",
  "illustrationAssets": ["...png", "...png", "...png"]
}
```
`illustrationAssets` adalah **field baru** (lihat Bagian 4). Tambahkan sebagai field opsional dulu di model Dart supaya tidak breaking terhadap 5 entri lama yang belum punya field ini.

**3.1 Kategori baru: Gerakan Kepala & Leher**

`JointType` di modul `motion` saat ini **tidak mencakup sendi leher/kepala** (hanya elbow, shoulder, knee, hip — lihat `lib/features/motion/models/joint_angle.dart`). Ini prasyarat teknis yang harus diselesaikan lebih dulu:
1. Tambahkan `JointType.neckRotation` dan/atau `JointType.neckFlexion` ke enum yang ada
2. `JointAngleCalculator` perlu logika baru untuk sendi ini — leher tidak punya 3 titik landmark sederhana seperti siku (bahu-siku-pergelangan); pendekatan paling praktis dengan landmark yang tersedia dari ML Kit adalah menghitung sudut antara garis **hidung–tengah-bahu** relatif terhadap sumbu vertikal tubuh, memakai `PoseLandmarkType.nose` dan titik tengah `leftShoulder`/`rightShoulder`. Dokumentasikan asumsi ini dengan jelas di kode karena ML Kit tidak punya landmark leher eksplisit.

**Kehati-hatian keamanan konten (bukan opsional):** gerakan leher punya risiko cedera lebih tinggi dibanding gerakan bahu/lengan untuk sebagian pengguna kursi roda — khususnya pengguna dengan cedera tulang belakang tinggi (cervical spinal cord injury) yang levelnya bisa membuat gerakan leher berisiko atau bahkan sudah dibatasi alat bantu (collar/brace). **Field `contraindication` untuk tiap entri gerakan leher wajib diisi dengan konsultasi fisioterapis sungguhan sebelum dipublikasikan** — jangan isi field ini dengan tebakan atau placeholder generik. Sudut target (`targetAngle`) untuk rotasi/fleksi leher sebaiknya dibuat konservatif (rentang gerak kecil) sebagai default aman, bukan rentang gerak maksimal anatomis.

Contoh entri (kerangka, **sudut & tempo indikatif — wajib divalidasi fisioterapis sebelum dipakai**):
```json
{
  "id": "neck_01_gentle_rotation",
  "name": "Rotasi Leher Perlahan (Gentle Neck Rotation)",
  "category": "Neck & Head Mobility",
  "difficulty": 1,
  "targetMuscles": ["Sternocleidomastoid", "Splenius Capitis"],
  "movementPattern": "Cervical Rotation",
  "targetAngles": { "primaryJoint": "neckRotation", "startAngle": 0.0, "targetAngle": 30.0 },
  "tolerance": 10.0,
  "warning": "Hentikan segera jika terasa pusing, nyeri, atau kesemutan menjalar ke lengan.",
  "contraindication": "PLACEHOLDER — wajib diisi bersama fisioterapis, jangan publish dengan nilai ini."
}
```

**3.2 Kategori yang hilang: Wheelchair Aerobics & Core Stability**

Tambahkan minimal 3–4 entri per kategori ini mengikuti pola `movementPattern`/`targetMuscles` yang konsisten dengan deskripsi di proposal (gerakan ritmik lengan untuk Wheelchair Aerobics; penguatan otot inti dari posisi duduk untuk Core Stability). Gunakan `primaryJoint` yang sudah didukung (`shoulderFlexion`, `elbowFlexion`) — kategori ini **tidak** butuh perluasan `JointType` baru seperti kategori leher.

## 4. Bagian B — Aset Ilustrasi (3 Gambar per Latihan)

**Kondisi saat ini:** `assets/images/` dan `assets/icons/` kosong (hanya `.gitkeep`). Field `thumbnailAsset`/`animationAsset` di tiap entri JSON menunjuk ke path yang **tidak ada filenya** — ini akan menyebabkan error runtime kalau UI mencoba me-render `Image.asset()` dari path tersebut.

**Spesifikasi struktur baru:**
```dart
// full_exercise_definition.dart — tambahkan field baru, opsional dulu untuk backward-compat
final List<String>? illustrationAssets;  // tepat 3 path: [posisi awal, posisi puncak/tahan, posisi akhir]
```
Pemetaan 3 gambar yang **bermakna secara anatomis** (bukan asal 3 gambar), diambil langsung dari field yang sudah ada di data (`startPose`, sebuah posisi puncak yang berkorespondensi dengan `targetAngle`, dan `endPose`):
```
assets/exercises/illustrations/<exercise_id>/01_start.png   ← sesuai field startPose
assets/exercises/illustrations/<exercise_id>/02_peak.png    ← posisi target/tahan
assets/exercises/illustrations/<exercise_id>/03_end.png     ← sesuai field endPose
```

**Wajib — fallback aman:** karena riwayat proyek ini menunjukkan aset sering direferensikan sebelum benar-benar ada (lihat kondisi saat ini), widget yang me-render `illustrationAssets` harus punya `errorBuilder` (untuk `Image.asset`) yang menampilkan placeholder ikon generik, **bukan** membiarkan aplikasi crash kalau file belum di-upload:
```dart
Image.asset(
  path,
  errorBuilder: (context, error, stackTrace) => const _IllustrationPlaceholder(),
)
```
Terapkan pola ini juga secara retroaktif ke `thumbnailAsset` yang sudah ada — 5 entri lama saat ini juga akan crash dengan pola render `Image.asset` naif tanpa `errorBuilder`.

**pubspec.yaml:** tambahkan folder baru ke daftar aset:
```yaml
assets:
  - assets/icons/
  - assets/images/
  - assets/exercises/
  - assets/exercises/illustrations/
```

## 5. Bagian C — Unifikasi Sistem Feedback Real-Time

### 5.1 Masalah yang terverifikasi

Ada **3 sumber teks feedback berbeda** yang seharusnya satu:

| Sumber | Lokasi | Sifat |
|---|---|---|
| Teks bubble UI | `live_camera_screen.dart` → `_getCoachMessage()` | Hardcode di layer presentation, berdasarkan `movementPhase` saja |
| Teks suara | `workout_session_engine.dart` → `_provideRealtimeCoachFeedback()` | Hardcode di layer engine, kalimat **beda** dari bubble UI meski trigger sama |
| Instruksi per-latihan | `voiceInstruction` di tiap entri `exercises.json` | Sudah ditulis rapi per-latihan, **tidak pernah dipanggil di manapun** |

Selain itu ada **2 wrapper TTS terpisah**: `VoiceCoach` (dipakai nyata oleh `WorkoutSessionEngine`) dan `VoiceFeedbackService` + `FeedbackRuleEngine` (dibangun lengkap dengan sistem prioritas dan `skeletonColor`, tapi **tidak dipanggil dari manapun** di alur sesi latihan yang sesungguhnya — kode ini idle).

### 5.2 Keputusan Desain

**Jangan bangun sistem keempat.** Konsolidasikan ke satu alur, dengan `WorkoutSessionEngine` sebagai satu-satunya orkestrator (karena ini yang sudah benar-benar terhubung ke UI dan penghitungan rep/set):

1. **Pindahkan konsep dari `FeedbackRuleEngine`** (rule berbasis kondisi + prioritas + `skeletonColor`) **ke dalam** `WorkoutSessionEngine`/`VoiceCoach`, bukan sebaliknya. `FeedbackPriority`/`CoachPriority` yang sudah ada di `VoiceCoach` (low/medium/high/emergency) sudah cukup mirip — satukan enum-nya jadi satu definisi, jangan dua.
2. **Setelah migrasi selesai, hapus (atau deprecate dengan jelas) `VoiceFeedbackService` dan `FeedbackRuleEngine`** di `features/feedback/` supaya tidak ada dua implementasi TTS yang membingungkan developer berikutnya. Jangan biarkan kode idle ini terus ada "untuk jaga-jaga" — itu yang menyebabkan kebingungan yang saya temukan saat audit.
3. **`_getCoachMessage()` di UI dihapus total** — bubble UI seharusnya hanya menampilkan ulang teks yang sama dengan yang diucapkan `VoiceCoach`, bukan menghasilkan teksnya sendiri. Ubah `VoiceCoach.speak()` agar juga mengekspos teks yang sedang/baru diucapkan lewat state (`ValueNotifier<String>` atau tambahan field di `WorkoutSessionUIState`), lalu `RealtimeCoachBubble` membaca dari situ.
4. **Panggil `exercise.voiceInstruction` di titik yang tepat** — instruksi ini seharusnya diucapkan **sekali di awal set/repetisi pertama** (bukan tiap frame), sebagai pelengkap sapaan "Mulai latihan!" yang sudah ada di `startWorkoutAfterCountdown()`:
```dart
void startWorkoutAfterCountdown() {
  _state = WorkoutState.workout;
  // ...
  _voiceCoach.speak('Mulai latihan! ${exercise.voiceInstruction}', priority: CoachPriority.high, force: true);
}
```

### 5.3 Sistem Peringatan Visual Bertingkat (BARU)

**Kondisi saat ini:** `RealtimeCoachBubble` selalu bergaya sama (hijau, netral) — tidak membedakan kondisi normal dari kondisi bermasalah. Kondisi bermasalah yang sudah **terdeteksi oleh sistem** (confidence rendah, landmark tidak lengkap dari `MovementValidator`, dsb.) **tidak pernah ditampilkan** sebagai peringatan ke pengguna.

**Spesifikasi:**

```dart
enum AlertSeverity { info, warning, critical }

class LiveAlert {
  final String message;
  final AlertSeverity severity;
  final IconData icon;
  const LiveAlert({required this.message, required this.severity, required this.icon});
}
```

Pemicu alert berdasarkan kondisi yang **sudah ada** di sistem, tinggal disambungkan:
| Kondisi (sudah terdeteksi sistem) | Severity | Contoh pesan |
|---|---|---|
| `poseConfidence < 0.5` (dari `MovementValidator`) | `warning` | "Deteksi kurang jelas, pastikan pencahayaan cukup" |
| Landmark tubuh atas tidak lengkap / keluar frame | `critical` | "Tubuh tidak terlihat penuh, mundur sedikit dari kamera" |
| `accuracyScore` repetisi terakhir < 60% (dari `RepCounter`) | `warning` | "Repetisi tercatat, tapi rentang gerak kurang optimal" |
| Repetisi/set selesai normal | `info` | (opsional, bisa cukup lewat suara saja tanpa alert visual) |

**Widget baru** `LiveAlertBanner` — menggantikan/melengkapi `RealtimeCoachBubble` dengan varian warna sesuai `AlertSeverity` (mis. kuning untuk warning, merah untuk critical, style hijau lama dipakai untuk `info`/netral). Tampilkan sebagai banner sementara (auto-dismiss 4–5 detik untuk `warning`, tetap tampil selama kondisi `critical` berlangsung), bukan menggantikan bubble koreksi gerakan yang sudah bagus — keduanya bisa hidup berdampingan di posisi berbeda di layar.

**Sinkronisasi dengan suara:** alert `warning`/`critical` **harus** dibunyikan lewat `VoiceCoach.speak()` dengan prioritas `high`/`emergency` bersamaan dengan banner muncul — jangan buat alert-nya senyap sementara suaranya sendiri (mengulang masalah 3-sumber-teks di Bagian 5.1).

## 6. Struktur Perubahan File (Ringkasan)

```
assets/exercises/
├── exercises.json                    # + entri baru (leher, aerobics, core stability), + field illustrationAssets
└── illustrations/<exercise_id>/      # BARU — 3 gambar per latihan

lib/features/exercise_library/models/
└── full_exercise_definition.dart     # + field illustrationAssets (opsional)

lib/features/motion/models/
└── joint_angle.dart                  # + JointType.neckRotation / neckFlexion

lib/features/motion/services/
└── joint_angle_calculator.dart       # + logika sudut leher (nose–bahu vs sumbu vertikal)

lib/features/workout_session/
├── services/voice_coach.dart         # + expose teks yang sedang diucapkan (state)
├── services/workout_session_engine.dart  # + panggil voiceInstruction, + trigger LiveAlert
├── controllers/workout_session_controller.dart  # + state alert aktif
├── widgets/realtime_coach_bubble.dart    # baca teks dari VoiceCoach, bukan generate sendiri
├── widgets/live_alert_banner.dart    # BARU
└── presentation/live_camera_screen.dart  # hapus _getCoachMessage(), pasang LiveAlertBanner

lib/features/feedback/                # DIHAPUS atau deprecated setelah migrasi (Bagian 5.2)
```

## 7. Koordinasi dengan TRD Motion Tracking Refinement

Kedua TRD sama-sama menyentuh `lib/features/workout_session/**` dan `lib/features/motion/**`:
- TRD Motion Tracking Refinement mengubah `MotionProcessor`/`BodyAnalyzer` (threshold, baseline personalisasi)
- TRD ini mengubah `JointType` enum (tambah leher) dan `WorkoutSessionEngine` (feedback/alert)

**Kerjakan penambahan `JointType.neckRotation` di TRD ini lebih dulu** sebelum TRD Motion Tracking Refinement menyentuh `body_analyzer.dart`, supaya tidak ada dua orang mengubah enum yang sama di waktu bersamaan. Kalau kedua TRD dikerjakan paralel oleh developer berbeda, sepakati siapa yang pegang `joint_angle.dart` lebih dulu dan siapa yang rebase.

## 8. Definition of Done

- [ ] Minimal 3 latihan gerakan leher/kepala ditambahkan, dengan `contraindication` yang sudah divalidasi fisioterapis (bukan placeholder)
- [ ] Kategori *Wheelchair Aerobics* dan *Core Stability* masing-masing punya minimal 3 entri
- [ ] Setiap latihan (lama & baru) punya 3 file ilustrasi yang benar-benar ada di disk, atau fallback placeholder tampil rapi kalau belum ada — tidak ada crash `Image.asset`
- [ ] `_getCoachMessage()` di UI dihapus, bubble membaca teks dari satu sumber (`VoiceCoach`)
- [ ] `exercise.voiceInstruction` terdengar diucapkan saat latihan dimulai
- [ ] `features/feedback/` (VoiceFeedbackService, FeedbackRuleEngine) sudah dihapus atau ditandai deprecated dengan jelas, tidak ada lagi dua wrapper TTS aktif
- [ ] `LiveAlertBanner` tampil dengan warna berbeda untuk kondisi warning vs critical, tersambung ke kondisi confidence/landmark nyata (bukan simulasi)
- [ ] Setiap alert visual dibarengi suara dengan prioritas sesuai
- [ ] `flutter analyze` bersih

## 9. Catatan untuk AI Coding Assistant

1. **Jangan** menambah sumber teks feedback keempat — tujuan utama Bagian C adalah **mengurangi** duplikasi, bukan menambah lapisan baru.
2. Sebelum mengisi field `contraindication` untuk latihan leher, tulis placeholder eksplisit seperti contoh di Bagian 3.1 — **jangan mengarang kontraindikasi medis**, itu bukan keputusan yang boleh diambil AI atau developer non-klinis sendirian.
3. Baca `lib/features/workout_session/services/workout_session_engine.dart` dan `voice_coach.dart` secara utuh dulu sebelum mengubah alur feedback — pahami urutan pemanggilan `_voiceCoach.speak()` yang sudah ada supaya migrasi tidak merusak fungsi rep/set counting yang sudah bekerja baik.
4. Verifikasi isi `assets/exercises/exercise_knowledge_base.json` sebelum berasumsi soal cakupannya — file ini di luar scope TRD ini tapi mungkin relevan untuk konteks tambahan.