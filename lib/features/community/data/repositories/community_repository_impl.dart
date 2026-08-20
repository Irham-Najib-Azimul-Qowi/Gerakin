import '../../../sync/domain/repositories/sync_repository.dart';
import '../../data/datasources/local_community_data_source.dart';
import '../../domain/repositories/community_repository.dart';
import '../../models/community_comment.dart';
import '../../models/community_post.dart';
import '../../models/content_report.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final LocalCommunityDataSource localDataSource;
  final SyncRepository syncRepository;

  CommunityRepositoryImpl({
    required this.localDataSource,
    required this.syncRepository,
  });

  @override
  Future<List<CommunityPost>> getFeed({String? searchQuery, int limit = 20, int offset = 0}) async {
    return localDataSource.getPosts(searchQuery: searchQuery, limit: limit, offset: offset);
  }

  @override
  Future<int> createPost({
    required String authorUid,
    required String authorDisplayName,
    required String content,
    String? imagePath,
    String? hashtags,
  }) async {
    final now = DateTime.now();
    final newPost = CommunityPost(
      id: 0,
      authorUid: authorUid,
      authorDisplayName: authorDisplayName,
      content: content,
      imagePath: imagePath,
      hashtags: hashtags,
      likeCount: 0,
      commentCount: 0,
      isReported: false,
      createdAt: now,
      syncStatus: 'pending_sync',
    );

    // 1. Simpan ke ObjectBox lokal instan (0ms)
    final savedId = localDataSource.savePost(newPost);
    final savedPost = newPost.copyWith(id: savedId);

    // 2. Masukkan ke antrean SyncRepository (tanpa import cloud_firestore langsung)
    await syncRepository.queueChange(
      collection: 'community_posts',
      documentId: savedId.toString(),
      operation: 'create',
      data: savedPost.toSyncData(),
    );

    return savedId;
  }

  @override
  Future<void> toggleLike(int postId, String userUid) async {
    final post = localDataSource.getPostById(postId);
    if (post == null) return;

    // Toggle like count
    final newLikeCount = post.likeCount + 1;
    final updatedPost = post.copyWith(
      likeCount: newLikeCount,
      syncStatus: 'pending_sync',
    );

    localDataSource.savePost(updatedPost);

    await syncRepository.queueChange(
      collection: 'community_posts',
      documentId: postId.toString(),
      operation: 'update',
      data: updatedPost.toSyncData(),
    );
  }

  @override
  Future<List<CommunityComment>> getComments(int postId) async {
    return localDataSource.getComments(postId);
  }

  @override
  Future<int> addComment({
    required int postId,
    required String authorUid,
    required String authorDisplayName,
    required String content,
  }) async {
    final now = DateTime.now();
    final newComment = CommunityComment(
      id: 0,
      postId: postId,
      authorUid: authorUid,
      authorDisplayName: authorDisplayName,
      content: content,
      createdAt: now,
      syncStatus: 'pending_sync',
    );

    // 1. Simpan komentar di ObjectBox
    final commentId = localDataSource.saveComment(newComment);
    final savedComment = newComment.copyWith(id: commentId);

    // Update commentCount di post induk
    final post = localDataSource.getPostById(postId);
    if (post != null) {
      final updatedPost = post.copyWith(commentCount: post.commentCount + 1);
      localDataSource.savePost(updatedPost);
    }

    // 2. Antrekan sinkronisasi ke cloud
    await syncRepository.queueChange(
      collection: 'community_comments',
      documentId: commentId.toString(),
      operation: 'create',
      data: savedComment.toSyncData(),
    );

    return commentId;
  }

  @override
  Future<void> reportContent({
    required String targetType,
    required int targetId,
    required String reporterUid,
    required String reason,
  }) async {
    final now = DateTime.now();
    final report = ContentReport(
      id: 0,
      targetType: targetType,
      targetId: targetId,
      reporterUid: reporterUid,
      reason: reason,
      createdAt: now,
    );

    // 1. Simpan laporan ke ObjectBox
    final reportId = localDataSource.saveReport(report);

    // Tandai post sebagai reported di lokal jika target adalah post
    if (targetType == 'post') {
      final post = localDataSource.getPostById(targetId);
      if (post != null) {
        localDataSource.savePost(post.copyWith(isReported: true));
      }
    }

    // 2. Antrekan sinkronisasi laporan ke cloud
    await syncRepository.queueChange(
      collection: 'content_reports',
      documentId: reportId.toString(),
      operation: 'create',
      data: report.copyWith(id: reportId).toSyncData(),
    );
  }
}
