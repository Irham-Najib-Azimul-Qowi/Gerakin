import '../models/community_post.dart';
import '../models/community_comment.dart';

abstract class CommunityRepository {
  /// Mengambil daftar postingan dari komunitas.
  Future<List<CommunityPost>> getPosts({String? category, String? searchQuery});

  /// Mengirim postingan baru ke komunitas.
  Future<CommunityPost> createPost({
    required String authorId,
    required String authorName,
    String? authorAvatarUrl,
    String? authorBadge,
    required String caption,
    required List<String> mediaUrls,
    CommunityMediaType mediaType = CommunityMediaType.image,
    String? workoutTag,
    List<String> tags = const [],
  });

  /// Menyukai / batal menyukai postingan.
  Future<CommunityPost> toggleLikePost(String postId, String userId);

  /// Mengambil komentar dari sebuah postingan.
  Future<List<CommunityComment>> getComments(String postId);

  /// Menambahkan komentar atau balasan komentar baru.
  Future<CommunityComment> addComment({
    required String postId,
    String? parentId,
    String? replyToAuthorName,
    required String authorId,
    required String authorName,
    String? authorAvatarUrl,
    required String text,
  });

  /// Menambah jumlah share postingan.
  Future<void> incrementShare(String postId);

  /// Menghapus postingan milik pengguna dari Firebase Firestore.
  Future<void> deletePost(String postId);
}
