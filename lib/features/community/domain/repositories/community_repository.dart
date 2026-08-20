import '../../models/community_post.dart';
import '../../models/community_comment.dart';

/// Kontrak repositori untuk mengelola data komunitas GERAKIN.
abstract class CommunityRepository {
  /// Mengambil daftar postingan dari feed lokal (ObjectBox).
  Future<List<CommunityPost>> getFeed({String? searchQuery, int limit = 20, int offset = 0});

  /// Membuat postingan baru di ObjectBox & memasukkan ke antrean sync.
  Future<int> createPost({
    required String authorUid,
    required String authorDisplayName,
    required String content,
    String? imagePath,
    String? hashtags,
  });

  /// Menyukai / batal menyukai postingan.
  Future<void> toggleLike(int postId, String userUid);

  /// Mengambil komentar dari sebuah postingan.
  Future<List<CommunityComment>> getComments(int postId);

  /// Menambahkan komentar baru di ObjectBox & memasukkan ke antrean sync.
  Future<int> addComment({
    required int postId,
    required String authorUid,
    required String authorDisplayName,
    required String content,
  });

  /// Laporkan konten (post / komentar) yang melanggar.
  Future<void> reportContent({
    required String targetType,
    required int targetId,
    required String reporterUid,
    required String reason,
  });
}
