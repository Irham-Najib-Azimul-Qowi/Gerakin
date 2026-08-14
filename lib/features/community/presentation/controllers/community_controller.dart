import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/repositories/community_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../user/presentation/controllers/profile_controller.dart';

class CommunityState {
  final List<CommunityPost> posts;
  final bool isLoading;
  final String? errorMessage;
  final String selectedCategory;
  final String searchQuery;

  const CommunityState({
    this.posts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory = 'Semua',
    this.searchQuery = '',
  });

  CommunityState copyWith({
    List<CommunityPost>? posts,
    bool? isLoading,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
    bool clearError = false,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CommunityController extends Notifier<CommunityState> {
  late final CommunityRepository _repository;

  @override
  CommunityState build() {
    _repository = ref.watch(communityRepositoryProvider);
    // Load initial posts
    Future.microtask(() => fetchPosts());
    return const CommunityState(isLoading: true);
  }

  Future<void> fetchPosts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final posts = await _repository.getPosts(
        category: state.selectedCategory,
        searchQuery: state.searchQuery,
      );
      state = state.copyWith(isLoading: false, posts: posts);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat feed komunitas. Silakan coba lagi.',
      );
    }
  }

  void setCategory(String category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);
    fetchPosts();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchPosts();
  }

  Future<void> toggleLike(String postId) async {
    final authState = ref.read(authControllerProvider);
    final userId = authState.currentUser?.uid ?? 'guest';

    // Optimistic UI update
    final updatedPosts = state.posts.map((post) {
      if (post.id == postId) {
        final newIsLiked = !post.isLikedByMe;
        final newCount = newIsLiked ? post.likesCount + 1 : post.likesCount - 1;
        return post.copyWith(
          isLikedByMe: newIsLiked,
          likesCount: newCount < 0 ? 0 : newCount,
        );
      }
      return post;
    }).toList();

    state = state.copyWith(posts: updatedPosts);

    try {
      await _repository.toggleLikePost(postId, userId);
    } catch (_) {
      // Revert if error
      fetchPosts();
    }
  }

  Future<bool> createPost({
    required String caption,
    required List<String> mediaUrls,
    CommunityMediaType mediaType = CommunityMediaType.image,
    String? workoutTag,
    List<String> tags = const [],
  }) async {
    final authState = ref.read(authControllerProvider);
    final profileState = ref.read(profileControllerProvider);

    final currentUser = authState.currentUser;
    final authorId = currentUser?.uid ?? 'guest_user';
    final authorName = profileState.activeProfile?.displayName ?? currentUser?.displayName ?? 'Pejuang GERAKIN';
    final authorAvatarUrl = profileState.activeProfile?.photoUrl;

    try {
      final newPost = await _repository.createPost(
        authorId: authorId,
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        authorBadge: 'Pejuang Sehat',
        caption: caption,
        mediaUrls: mediaUrls,
        mediaType: mediaType,
        workoutTag: workoutTag,
        tags: tags,
      );

      state = state.copyWith(posts: [newPost, ...state.posts]);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal mempublikasikan postingan.');
      return false;
    }
  }

  Future<List<CommunityComment>> getComments(String postId) async {
    return await _repository.getComments(postId);
  }

  Future<bool> addComment(
    String postId,
    String text, {
    String? parentId,
    String? replyToAuthorName,
  }) async {
    final authState = ref.read(authControllerProvider);
    final profileState = ref.read(profileControllerProvider);

    final currentUser = authState.currentUser;
    final authorId = currentUser?.uid ?? 'guest_user';
    final authorName = profileState.activeProfile?.displayName ?? currentUser?.displayName ?? 'Pejuang GERAKIN';
    final authorAvatarUrl = profileState.activeProfile?.photoUrl;

    try {
      await _repository.addComment(
        postId: postId,
        parentId: parentId,
        replyToAuthorName: replyToAuthorName,
        authorId: authorId,
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        text: text,
      );

      // Increment comment count locally
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(commentsCount: post.commentsCount + 1);
        }
        return post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> sharePost(String postId) async {
    await _repository.incrementShare(postId);
    final updatedPosts = state.posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(sharesCount: post.sharesCount + 1);
      }
      return post;
    }).toList();

    state = state.copyWith(posts: updatedPosts);
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);
      final updatedPosts = state.posts.where((post) => post.id != postId).toList();
      state = state.copyWith(posts: updatedPosts);
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Gagal menghapus postingan.');
      return false;
    }
  }
}

final communityControllerProvider = NotifierProvider<CommunityController, CommunityState>(
  CommunityController.new,
);
