import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/repositories/community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepositoryImpl(firestore: FirebaseFirestore.instance);
});

class CommunityRepositoryImpl implements CommunityRepository {
  final FirebaseFirestore firestore;

  // Cache lokal in-memory untuk pengalaman UI yang instan & fallback offline
  final List<CommunityPost> _localPosts = [];
  final Map<String, List<CommunityComment>> _localComments = {};

  CommunityRepositoryImpl({required this.firestore});

  @override
  Future<List<CommunityPost>> getPosts({String? category, String? searchQuery}) async {
    try {
      final snap = await firestore
          .collection('community_posts')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final remotePosts = snap.docs
          .map((doc) => CommunityPost.fromFirestore(doc.data(), doc.id))
          .toList();

      _localPosts.clear();
      _localPosts.addAll(remotePosts);
      return _applyFilter(remotePosts, category, searchQuery);
    } catch (_) {
      // Fallback offline
    }

    return _applyFilter(_localPosts, category, searchQuery);
  }

  List<CommunityPost> _applyFilter(List<CommunityPost> posts, String? category, String? searchQuery) {
    var result = List<CommunityPost>.from(posts);

    if (category != null && category != 'Semua') {
      if (category == 'Aktivitas') {
        result = result.where((p) => p.workoutTag != null).toList();
      } else if (category == 'Pencapaian') {
        result = result.where((p) => p.tags.contains('PencapaianHariIni') || p.caption.toLowerCase().contains('berhasil')).toList();
      } else if (category == 'Diskusi') {
        result = result.where((p) => p.authorBadge == 'Fisioterapis' || p.caption.contains('?')).toList();
      }
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim().replaceAll('#', '');
      result = result.where((p) =>
        p.caption.toLowerCase().contains(q) ||
        p.authorName.toLowerCase().contains(q) ||
        (p.workoutTag != null && p.workoutTag!.toLowerCase().contains(q)) ||
        p.tags.any((t) => t.toLowerCase().contains(q))
      ).toList();
    }

    return result;
  }

  @override
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
  }) async {
    final newId = 'post_${DateTime.now().millisecondsSinceEpoch}';
    final newPost = CommunityPost(
      id: newId,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      authorBadge: authorBadge ?? 'Member GERAKIN',
      caption: caption,
      mediaUrls: const [], // Text-only posts
      mediaType: CommunityMediaType.image,
      workoutTag: workoutTag,
      likesCount: 0,
      commentsCount: 0,
      sharesCount: 0,
      isLikedByMe: false,
      createdAt: DateTime.now(),
      tags: tags,
    );

    _localPosts.insert(0, newPost);

    try {
      await firestore.collection('community_posts').doc(newId).set(newPost.toFirestore());
    } catch (_) {}

    return newPost;
  }

  @override
  Future<CommunityPost> toggleLikePost(String postId, String userId) async {
    final index = _localPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _localPosts[index];
      final newLikedState = !post.isLikedByMe;
      final newLikesCount = newLikedState ? post.likesCount + 1 : post.likesCount - 1;

      final updated = post.copyWith(
        isLikedByMe: newLikedState,
        likesCount: newLikesCount < 0 ? 0 : newLikesCount,
      );
      _localPosts[index] = updated;

      try {
        final docRef = firestore.collection('community_posts').doc(postId);
        if (newLikedState) {
          await docRef.update({
            'likesCount': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([userId]),
          });
        } else {
          await docRef.update({
            'likesCount': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([userId]),
          });
        }
      } catch (_) {}

      return updated;
    }

    throw Exception('Post not found');
  }

  @override
  Future<List<CommunityComment>> getComments(String postId) async {
    try {
      final snap = await firestore
          .collection('community_posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => CommunityComment.fromFirestore(doc.data(), doc.id)).toList();
      }
    } catch (_) {}

    return _localComments[postId] ?? [];
  }

  @override
  Future<CommunityComment> addComment({
    required String postId,
    String? parentId,
    String? replyToAuthorName,
    required String authorId,
    required String authorName,
    String? authorAvatarUrl,
    required String text,
  }) async {
    final commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';
    final comment = CommunityComment(
      id: commentId,
      postId: postId,
      parentId: parentId,
      replyToAuthorName: replyToAuthorName,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      text: text,
      createdAt: DateTime.now(),
    );

    if (_localComments[postId] == null) {
      _localComments[postId] = [];
    }
    _localComments[postId]!.add(comment);

    // Update komentar count di post
    final postIndex = _localPosts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      _localPosts[postIndex] = _localPosts[postIndex].copyWith(
        commentsCount: _localPosts[postIndex].commentsCount + 1,
      );
    }

    try {
      final docRef = firestore.collection('community_posts').doc(postId);
      await docRef.collection('comments').doc(commentId).set(comment.toFirestore());
      await docRef.update({'commentsCount': FieldValue.increment(1)});
    } catch (_) {}

    return comment;
  }

  @override
  Future<void> incrementShare(String postId) async {
    final index = _localPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _localPosts[index] = _localPosts[index].copyWith(
        sharesCount: _localPosts[index].sharesCount + 1,
      );
    }

    try {
      await firestore.collection('community_posts').doc(postId).update({
        'sharesCount': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  @override
  Future<void> deletePost(String postId) async {
    _localPosts.removeWhere((p) => p.id == postId);
    _localComments.remove(postId);

    try {
      await firestore.collection('community_posts').doc(postId).delete();
    } catch (_) {}
  }
}
