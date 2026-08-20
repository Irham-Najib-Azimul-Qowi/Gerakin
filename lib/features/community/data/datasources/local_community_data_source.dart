import '../../../../objectbox.g.dart';
import '../../models/community_comment.dart';
import '../../models/community_post.dart';
import '../../models/content_report.dart';

/// Kontrak data source lokal untuk operasi CRUD database pada fitur Community.
abstract class LocalCommunityDataSource {
  /// Mengambil daftar postingan dari database lokal.
  List<CommunityPost> getPosts({String? searchQuery, int limit = 20, int offset = 0});

  /// Menyeleksi post berdasarkan ID.
  CommunityPost? getPostById(int id);

  /// Menyimpan atau memperbarui postingan.
  int savePost(CommunityPost post);

  /// Menghapus postingan.
  bool deletePost(int id);

  /// Mengambil daftar komentar untuk suatu post ID.
  List<CommunityComment> getComments(int postId);

  /// Menyimpan komentar baru.
  int saveComment(CommunityComment comment);

  /// Menyimpan laporan konten.
  int saveReport(ContentReport report);
}

/// Implementasi ObjectBox untuk [LocalCommunityDataSource].
class LocalCommunityDataSourceImpl implements LocalCommunityDataSource {
  final Box<CommunityPost> postBox;
  final Box<CommunityComment> commentBox;
  final Box<ContentReport> reportBox;

  LocalCommunityDataSourceImpl(Store store)
      : postBox = store.box<CommunityPost>(),
        commentBox = store.box<CommunityComment>(),
        reportBox = store.box<ContentReport>();

  @override
  List<CommunityPost> getPosts({String? searchQuery, int limit = 20, int offset = 0}) {
    final query = postBox.query()
      ..order(CommunityPost_.createdAt, flags: Order.descending);
    final buildQuery = query.build();
    List<CommunityPost> posts = buildQuery.find();
    buildQuery.close();

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      posts = posts.where((p) {
        final matchesContent = p.content.toLowerCase().contains(q);
        final matchesAuthor = p.authorDisplayName.toLowerCase().contains(q);
        final matchesHashtag = p.hashtags != null && p.hashtags!.toLowerCase().contains(q);
        return matchesContent || matchesAuthor || matchesHashtag;
      }).toList();
    }

    if (limit > 0 && offset < posts.length) {
      final end = (offset + limit) < posts.length ? (offset + limit) : posts.length;
      return posts.sublist(offset, end);
    }
    return posts;
  }

  @override
  CommunityPost? getPostById(int id) {
    return postBox.get(id);
  }

  @override
  int savePost(CommunityPost post) {
    return postBox.put(post);
  }

  @override
  bool deletePost(int id) {
    return postBox.remove(id);
  }

  @override
  List<CommunityComment> getComments(int postId) {
    final query = commentBox.query(CommunityComment_.postId.equals(postId))
      ..order(CommunityComment_.createdAt);
    final buildQuery = query.build();
    final comments = buildQuery.find();
    buildQuery.close();
    return comments;
  }

  @override
  int saveComment(CommunityComment comment) {
    return commentBox.put(comment);
  }

  @override
  int saveReport(ContentReport report) {
    return reportBox.put(report);
  }
}

