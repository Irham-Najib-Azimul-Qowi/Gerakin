# Technical Requirements Document (TRD)
## Modul: Community (`features/community`)

| | |
|---|---|
| **Proyek** | GerakIn — KMIPN VIII 2026 |
| **Branch** | `feature/community-module` |
| **Status saat ini** | Placeholder total — `community_page.dart` hanya ikon + teks statis. Tidak ada model, repository, atau service sama sekali. |
| **Folder kerja** | `lib/features/community/**` (buat baru) |
| **Dependensi modul lain** | Butuh `currentAuthUserProvider` dari modul Auth untuk atribusi post (lihat Bagian 6 — bisa dikerjakan paralel dengan mock) |
| **Ditujukan untuk** | Developer manusia maupun AI coding assistant yang mengerjakan modul ini |

---

## 1. Ringkasan & Tujuan

Modul Community mengimplementasikan forum komunitas yang disebutkan di proposal GerakIn (bagian 2.3.5 "Gamifikasi dan Fitur Komunitas") — tempat sesama pengguna kursi roda berbagi pengalaman, capaian latihan, dan saling memberi dukungan. Ini murni fitur baru; tidak ada kode lama yang perlu diadaptasi, tapi **wajib mengikuti pola arsitektur** yang sudah dipakai konsisten di modul lain (lihat modul `gamification` atau `analytics` sebagai referensi paling dekat: keduanya juga punya `data/repositories`, `domain/repositories`, `models`, `presentation`, `services`).

## 2. Cakupan

**In-scope (versi pertama / MVP untuk babak KMIPN):**
- Membuat post teks (opsional dengan 1 gambar)
- Melihat feed post (urut terbaru)
- Like/unlike post
- Komentar pada post
- Moderasi dasar: filter kata kasar sederhana + tombol "Laporkan" (report) pada post/komentar
- Sinkronisasi offline-first ke Firestore lewat `SyncEngine` **yang sudah ada** (jangan buat sync engine baru)

**Out-of-scope (jangan dikerjakan di versi ini):**
- Direct message / chat pribadi antar pengguna
- Grup/komunitas terpisah (mis. per kota) — cukup satu feed global dulu
- Upload video
- Sistem moderator manusia dengan dashboard admin — cukup laporan otomatis tersimpan, tinjau manual lewat Firestore console untuk versi kompetisi

## 3. Referensi Pola dari Modul yang Sudah Ada

Community akan **meniru struktur modul `gamification`**, khususnya karena sama-sama butuh sinkronisasi cloud. Baca dulu file-file ini sebagai contoh sebelum menulis kode:

```
lib/features/gamification/data/repositories/gamification_repository_impl.dart
lib/features/gamification/domain/repositories/gamification_repository.dart
lib/features/gamification/presentation/controllers/gamification_controller.dart
lib/features/gamification/services/gamification_providers.dart
```

Untuk sinkronisasi offline → cloud, **wajib** memakai `SyncRepository` yang sudah ada, bukan menulis langsung ke Firestore dari modul Community:

```dart
// lib/features/sync/domain/repositories/sync_repository.dart — SUDAH ADA, PAKAI INI:
abstract class SyncRepository {
  Future<void> queueChange({
    required String collection,   // isi dengan 'community_posts' atau 'community_comments'
    required String documentId,
    required String operation,    // 'create' | 'update' | 'delete'
    required Map<String, dynamic> data,
  });
  // ...
}
```
Alur: Community menulis dulu ke ObjectBox lokal (instan) → panggil `SyncRepository.queueChange()` → `SyncEngine` yang sudah berjalan di background akan mengirim ke Firestore otomatis (dengan retry & conflict resolution yang sudah dibangun). **Jangan** import `cloud_firestore` langsung di dalam `features/community/`.

## 4. Struktur Folder yang Harus Dibuat

```
lib/features/community/
├── models/
│   ├── community_post.dart
│   ├── community_comment.dart
│   └── content_report.dart
├── domain/
│   └── repositories/
│       └── community_repository.dart
├── data/
│   ├── datasources/
│   │   └── local_community_data_source.dart
│   └── repositories/
│       └── community_repository_impl.dart
├── services/
│   ├── content_moderation_service.dart
│   └── community_providers.dart
└── presentation/
    ├── controllers/
    │   └── community_feed_controller.dart
    ├── pages/
    │   ├── community_feed_page.dart        # ganti community_page.dart
    │   ├── create_post_page.dart
    │   └── post_detail_page.dart
    └── widgets/
        ├── post_card.dart
        ├── comment_tile.dart
        └── report_dialog.dart
```

## 5. Data Model (ObjectBox Entity)

Ikuti persis pola `SyncItem` (lihat `lib/features/sync/models/sync_item.dart`) dan `UserProfile` untuk gaya penulisan entity:

```dart
// lib/features/community/models/community_post.dart
import 'package:objectbox/objectbox.dart';

@Entity()
class CommunityPost {
  @Id()
  int id;

  final String authorUid;          // dari AuthUser.uid (modul Auth)
  final String authorDisplayName;  // denormalisasi untuk render cepat tanpa join
  final String content;
  final String? imagePath;         // path lokal atau URL Cloud Storage setelah sync
  final int likeCount;
  final int commentCount;
  final bool isReported;

  @Property(type: PropertyType.date)
  final DateTime createdAt;

  final String syncStatus;         // 'local_only' | 'pending_sync' | 'synced' — SAMAKAN pola dengan UserProfile

  CommunityPost({
    this.id = 0,
    required this.authorUid,
    required this.authorDisplayName,
    required this.content,
    this.imagePath,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isReported = false,
    required this.createdAt,
    required this.syncStatus,
  });

  CommunityPost copyWith({ /* ...ikuti pola copyWith di UserProfile... */ }) { ... }
}
```

```dart
// lib/features/community/models/community_comment.dart
@Entity()
class CommunityComment {
  @Id()
  int id;
  final int postId;               // relasi manual ke CommunityPost.id (ObjectBox tidak pakai foreign key SQL)
  final String authorUid;
  final String authorDisplayName;
  final String content;
  @Property(type: PropertyType.date)
  final DateTime createdAt;
  final String syncStatus;
  // constructor + copyWith mengikuti pola yang sama
}
```

```dart
// lib/features/community/models/content_report.dart
@Entity()
class ContentReport {
  @Id()
  int id;
  final String targetType;   // 'post' | 'comment'
  final int targetId;
  final String reporterUid;
  final String reason;
  @Property(type: PropertyType.date)
  final DateTime createdAt;
  // constructor + copyWith
}
```

> Setelah menambah entity baru, **wajib** jalankan:
> ```
> dart run build_runner build --delete-conflicting-outputs
> ```
> agar `objectbox.g.dart` dan `objectbox-model.json` di root `lib/` ter-generate ulang. **File ini akan konflik jika Developer Auth juga menjalankan build_runner di waktu bersamaan** — koordinasikan siapa yang generate lebih dulu, lalu yang kedua `git pull` sebelum generate ulang (lihat Bagian 8).

## 6. Kontrak Repository & Integrasi dengan Modul Auth

```dart
// lib/features/community/domain/repositories/community_repository.dart
abstract class CommunityRepository {
  Future<List<CommunityPost>> getFeed({int limit = 20, int offset = 0});
  Future<int> createPost({required String authorUid, required String authorDisplayName, required String content, String? imagePath});
  Future<void> toggleLike(int postId, String userUid);
  Future<List<CommunityComment>> getComments(int postId);
  Future<int> addComment({required int postId, required String authorUid, required String authorDisplayName, required String content});
  Future<void> reportContent({required String targetType, required int targetId, required String reporterUid, required String reason});
}
```

**Cara mendapatkan user yang sedang login** (untuk `authorUid`/`authorDisplayName` saat membuat post):

```dart
// Di community_feed_controller.dart:
final authUser = ref.read(currentAuthUserProvider).value;
if (authUser == null) {
  // arahkan ke halaman login (RoutePaths.login dari modul Auth), jangan izinkan post sebagai Guest.
  return;
}
```

`currentAuthUserProvider` didefinisikan di `lib/features/auth/data/repositories/auth_repository_impl.dart` — **provider ini adalah kontrak yang disepakati lintas modul, namanya tidak boleh diasumsikan berbeda.** Selama modul Auth belum selesai, kamu bisa mengembangkan Community dengan mem-*override* provider ini di test/dev menggunakan `ProviderScope(overrides: [...])` dengan data dummy, supaya tidak terblokir menunggu Auth.

## 7. Moderasi Konten (`ContentModerationService`)

```dart
// lib/features/community/services/content_moderation_service.dart
class ContentModerationService {
  /// Cek daftar kata terlarang sederhana (case-insensitive, bisa hardcode list awal
  /// di dalam file ini atau assets/moderation/blocked_words.json).
  /// Return true jika konten mengandung kata terlarang.
  bool containsProhibitedContent(String text);
}
```
Panggil ini di `CommunityFeedController.createPost()` dan `.addComment()` **sebelum** disimpan — jika terdeteksi, tolak dengan pesan error, jangan simpan sama sekali (bukan disimpan lalu disembunyikan).

## 8. Routing

Edit `lib/core/router/route_names.dart` — tambahkan di bagian terpisah dengan komentar jelas:
```dart
// ── Community Routes ──
static const String createPost = 'createPost';
static const String postDetail = 'postDetail';
static const String createPostPath = '/community/create';
static const String postDetailPath = '/community/post-detail';
```
Route `community` utama **sudah ada** di `app_router.dart` (tab bottom nav) dan sudah menunjuk ke `CommunityPage` — cukup ganti isi halaman itu jadi `CommunityFeedPage`, jangan ubah struktur `StatefulShellBranch`-nya. Tambahkan 2 `GoRoute` baru (create, detail) di luar shell, ikuti pola route `exerciseDetail` yang sudah ada (pakai `state.extra` untuk passing object, bukan query param, sesuai konvensi proyek).

## 9. Dependency Baru (`pubspec.yaml`)

Kemungkinan besar **tidak perlu dependency baru** — `camera`/image picker untuk lampiran foto post sebaiknya pakai `image_picker` jika belum ada:
```yaml
dependencies:
  image_picker: ^1.1.2   # HANYA jika fitur lampiran foto dikerjakan di versi ini; jika tidak, skip dulu
```
Cek dulu `pubspec.yaml` terkini sebelum menambah — jika Developer Auth sudah menambah baris untuk `firebase_auth` di waktu yang berdekatan, tambahkan baris kamu di bawahnya, lalu `git pull --rebase` sebelum push.

## 10. Definition of Done

- [ ] Feed menampilkan post terbaru, like/unlike berfungsi optimistik (update UI instan sebelum sync selesai)
- [ ] Buat post & komentar tersimpan ke ObjectBox lokal instan, lalu masuk antrean `SyncRepository.queueChange()`
- [ ] Post dari Guest (belum login) ditolak dengan redirect ke halaman login
- [ ] `ContentModerationService` menolak konten dengan kata terlarang sebelum tersimpan
- [ ] Tombol "Laporkan" berfungsi, tersimpan sebagai `ContentReport`
- [ ] Tidak ada import `cloud_firestore` di dalam `lib/features/community/**` (semua sync lewat `SyncRepository`)
- [ ] Unit test untuk `ContentModerationService` dan `CommunityRepository` (mock data source, ikuti pola testing di `ARCHITECTURE.md`)
- [ ] `flutter analyze` bersih

## 11. Catatan Khusus untuk AI Coding Assistant

Jika kamu (AI) mengerjakan modul ini secara otomatis:
1. **Jangan** membuat sync engine, retry logic, atau koneksi Firestore baru — semua itu **sudah ada** di `lib/features/sync/`. Modul ini hanya *memanggil* `SyncRepository`, tidak mengimplementasikan ulang.
2. Baca `lib/features/gamification/**` secara menyeluruh dulu sebagai referensi pola sebelum menulis kode — strukturnya paling mirip dengan yang dibutuhkan modul ini.
3. Jangan berasumsi bentuk `AuthUser` atau `currentAuthUserProvider` — jika modul Auth belum selesai saat kamu mengerjakan ini, buat interface/provider sesuai kontrak di Bagian 6, dan tandai dengan komentar `// TODO(auth-integration): verify against real AuthUser once feature/auth-module merged`.
4. Jangan menyentuh file di `lib/features/auth/**`, `lib/features/user/**`, `lib/features/sync/**` (kecuali memanggil `SyncRepository` sebagai *consumer*, bukan mengedit isinya) — di luar cakupan modul ini.
5. Ikuti gaya penamaan file **snake_case**, class **PascalCase**, gunakan `Notifier`/`NotifierProvider` dari Riverpod (`flutter_riverpod: ^3.3.2`), bukan `StateNotifier`/`ChangeNotifier`.