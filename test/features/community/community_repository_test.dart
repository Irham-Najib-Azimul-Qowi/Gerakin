import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/community/data/datasources/local_community_data_source.dart';
import 'package:gerakin/features/community/data/repositories/community_repository_impl.dart';
import 'package:gerakin/features/community/models/community_comment.dart';
import 'package:gerakin/features/community/models/community_post.dart';
import 'package:gerakin/features/community/models/content_report.dart';
import 'package:gerakin/features/sync/domain/repositories/sync_repository.dart';
import 'package:gerakin/features/sync/models/sync_item.dart';
import 'package:gerakin/features/sync/models/sync_result.dart';
import 'package:gerakin/features/sync/models/sync_status.dart';

class FakeSyncRepository implements SyncRepository {
  final List<Map<String, dynamic>> queuedChanges = [];

  @override
  Future<void> queueChange({
    required String collection,
    required String documentId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    queuedChanges.add({
      'collection': collection,
      'documentId': documentId,
      'operation': operation,
      'data': data,
    });
  }

  @override
  Future<void> deleteItem(int id) async {}

  @override
  Future<List<SyncItem>> getPendingItems() async => [];

  @override
  Future<SyncStatus> getSyncStatus() async => SyncStatus(status: 'idle', lastSyncTime: DateTime.now());

  @override
  Future<void> saveSyncStatus(SyncStatus status) async {}

  @override
  Future<SyncResult> syncItemToRemote(SyncItem item) async => SyncResult(isSuccess: true);

  @override
  Future<void> updateItem(SyncItem item) async {}
}

class FakeLocalCommunityDataSource implements LocalCommunityDataSource {
  final List<CommunityPost> posts = [];
  final List<CommunityComment> comments = [];
  final List<ContentReport> reports = [];
  int _nextId = 1;

  @override
  List<CommunityPost> getPosts({String? searchQuery, int limit = 20, int offset = 0}) {
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      return posts.where((p) {
        final matchesContent = p.content.toLowerCase().contains(q);
        final matchesAuthor = p.authorDisplayName.toLowerCase().contains(q);
        final matchesHashtag = p.hashtags != null && p.hashtags!.toLowerCase().contains(q);
        return matchesContent || matchesAuthor || matchesHashtag;
      }).toList();
    }
    return List.from(posts);
  }

  @override
  CommunityPost? getPostById(int id) {
    try {
      return posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  int savePost(CommunityPost post) {
    if (post.id == 0) {
      final newPost = post.copyWith(id: _nextId++);
      posts.add(newPost);
      return newPost.id;
    } else {
      final idx = posts.indexWhere((p) => p.id == post.id);
      if (idx != -1) {
        posts[idx] = post;
      } else {
        posts.add(post);
      }
      return post.id;
    }
  }

  @override
  bool deletePost(int id) {
    posts.removeWhere((p) => p.id == id);
    return true;
  }

  @override
  List<CommunityComment> getComments(int postId) {
    return comments.where((c) => c.postId == postId).toList();
  }

  @override
  int saveComment(CommunityComment comment) {
    if (comment.id == 0) {
      final newComment = comment.copyWith(id: _nextId++);
      comments.add(newComment);
      return newComment.id;
    } else {
      final idx = comments.indexWhere((c) => c.id == comment.id);
      if (idx != -1) {
        comments[idx] = comment;
      } else {
        comments.add(comment);
      }
      return comment.id;
    }
  }

  @override
  int saveReport(ContentReport report) {
    if (report.id == 0) {
      final newReport = report.copyWith(id: _nextId++);
      reports.add(newReport);
      return newReport.id;
    } else {
      final idx = reports.indexWhere((r) => r.id == report.id);
      if (idx != -1) {
        reports[idx] = report;
      } else {
        reports.add(report);
      }
      return report.id;
    }
  }
}

void main() {
  group('CommunityRepositoryImpl Tests', () {
    late FakeLocalCommunityDataSource localDataSource;
    late FakeSyncRepository syncRepository;
    late CommunityRepositoryImpl repository;

    setUp(() {
      localDataSource = FakeLocalCommunityDataSource();
      syncRepository = FakeSyncRepository();
      repository = CommunityRepositoryImpl(
        localDataSource: localDataSource,
        syncRepository: syncRepository,
      );
    });

    test('createPost harus menyimpan ke ObjectBox dan mengantrekan perubahan ke SyncRepository', () async {
      final id = await repository.createPost(
        authorUid: 'user_123',
        authorDisplayName: 'Budi',
        content: 'Halo teman-teman GERAKIN!',
      );

      expect(id, greaterThan(0));
      expect(localDataSource.posts.length, 1);
      expect(localDataSource.posts.first.content, 'Halo teman-teman GERAKIN!');
      expect(syncRepository.queuedChanges.length, 1);
      expect(syncRepository.queuedChanges.first['collection'], 'community_posts');
      expect(syncRepository.queuedChanges.first['operation'], 'create');
    });

    test('addComment harus menambah komentar dan meng-update commentCount di post induk', () async {
      final postId = await repository.createPost(
        authorUid: 'user_123',
        authorDisplayName: 'Budi',
        content: 'Post pertama',
      );

      final commentId = await repository.addComment(
        postId: postId,
        authorUid: 'user_456',
        authorDisplayName: 'Siti',
        content: 'Semangat terus!',
      );

      expect(commentId, greaterThan(0));
      expect(localDataSource.comments.length, 1);
      expect(localDataSource.getPostById(postId)?.commentCount, 1);
      expect(syncRepository.queuedChanges.where((c) => c['collection'] == 'community_comments').length, 1);
    });

    test('reportContent harus menyimpan laporan dan mengantrekan sinkronisasi content_reports', () async {
      final postId = await repository.createPost(
        authorUid: 'user_123',
        authorDisplayName: 'Budi',
        content: 'Konten berisiko',
      );

      await repository.reportContent(
        targetType: 'post',
        targetId: postId,
        reporterUid: 'user_999',
        reason: 'Ujaran kebencian',
      );

      expect(localDataSource.reports.length, 1);
      expect(localDataSource.reports.first.reason, 'Ujaran kebencian');
      expect(localDataSource.getPostById(postId)?.isReported, true);
      expect(syncRepository.queuedChanges.last['collection'], 'content_reports');
    });

    test('createPost dan getFeed harus mendukung pencarian dan filter hashtag', () async {
      await repository.createPost(
        authorUid: 'user_1',
        authorDisplayName: 'Budi',
        content: 'Latihan hari ini berjalan lancar #Fisioterapi',
        hashtags: '#Fisioterapi',
      );

      await repository.createPost(
        authorUid: 'user_2',
        authorDisplayName: 'Siti',
        content: 'Tips aksesibilitas pengguna kursi roda #KursiRoda',
        hashtags: '#KursiRoda',
      );

      final searchResults = await repository.getFeed(searchQuery: '#Fisioterapi');
      expect(searchResults.length, 1);
      expect(searchResults.first.authorDisplayName, 'Budi');
    });
  });
}
