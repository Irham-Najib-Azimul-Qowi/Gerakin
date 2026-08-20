import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/repositories/community_repository.dart';
import '../../models/community_comment.dart';
import '../../models/community_post.dart';
import '../../services/community_providers.dart';
import '../../services/content_moderation_service.dart';

class CommunityFeedState {
  final List<CommunityPost> posts;
  final bool isLoading;
  final String? errorMessage;
  final String? moderationError;
  final String searchQuery;

  const CommunityFeedState({
    this.posts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.moderationError,
    this.searchQuery = '',
  });

  CommunityFeedState copyWith({
    List<CommunityPost>? posts,
    bool? isLoading,
    String? errorMessage,
    String? moderationError,
    String? searchQuery,
    bool clearErrors = false,
  }) {
    return CommunityFeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      moderationError: clearErrors ? null : (moderationError ?? this.moderationError),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CommunityFeedController extends Notifier<CommunityFeedState> {
  late final CommunityRepository _repository;
  late final ContentModerationService _moderationService;

  @override
  CommunityFeedState build() {
    _repository = ref.watch(communityRepositoryProvider);
    _moderationService = ref.watch(contentModerationServiceProvider);

    Future.microtask(() => fetchFeed());
    return const CommunityFeedState(isLoading: true);
  }

  Future<void> fetchFeed() async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      final posts = await _repository.getFeed(
        searchQuery: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      state = state.copyWith(isLoading: false, posts: posts);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat feed komunitas lokal.',
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchFeed();
  }

  /// Membuat post baru. Mengembalikan false jika tidak diizinkan atau melanggar moderasi.
  Future<bool> createPost({
    required String content,
    String? imagePath,
    String? hashtags,
  }) async {
    state = state.copyWith(clearErrors: true);

    // 1. Verifikasi User Authenticated (Guest tidak diizinkan di TRD)
    final authState = ref.read(authControllerProvider);
    final user = authState.currentUser;
    if (user == null) {
      state = state.copyWith(errorMessage: 'GUEST_NOT_ALLOWED');
      return false;
    }

    // 2. Moderasi Konten (ContentModerationService)
    if (_moderationService.containsProhibitedContent(content)) {
      state = state.copyWith(
        moderationError: 'Postingan Anda mengandung kata terlarang dan ditolak oleh sistem moderasi.',
      );
      return false;
    }

    // Extrak hashtag otomatis dari teks jika hashtags belum diset
    String? extractedHashtags = hashtags;
    if (extractedHashtags == null || extractedHashtags.isEmpty) {
      final exp = RegExp(r'#[a-zA-Z0-9_]+');
      final matches = exp.allMatches(content).map((m) => m.group(0)).whereType<String>().toList();
      if (matches.isNotEmpty) {
        extractedHashtags = matches.join(' ');
      }
    }

    try {
      await _repository.createPost(
        authorUid: user.uid,
        authorDisplayName: user.displayName ?? 'Pengguna GERAKIN',
        content: content,
        imagePath: imagePath,
        hashtags: extractedHashtags,
      );

      await fetchFeed();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal mempublikasikan postingan.');
      return false;
    }
  }

  Future<void> toggleLike(int postId) async {
    final authState = ref.read(authControllerProvider);
    final user = authState.currentUser;
    if (user == null) return;

    try {
      await _repository.toggleLike(postId, user.uid);
      await fetchFeed();
    } catch (_) {}
  }

  Future<List<CommunityComment>> getComments(int postId) {
    return _repository.getComments(postId);
  }

  Future<bool> addComment({
    required int postId,
    required String content,
  }) async {
    state = state.copyWith(clearErrors: true);

    // 1. Verifikasi Auth
    final authState = ref.read(authControllerProvider);
    final user = authState.currentUser;
    if (user == null) {
      state = state.copyWith(errorMessage: 'GUEST_NOT_ALLOWED');
      return false;
    }

    // 2. Moderasi Konten
    if (_moderationService.containsProhibitedContent(content)) {
      state = state.copyWith(
        moderationError: 'Komentar Anda mengandung kata terlarang dan ditolak.',
      );
      return false;
    }

    try {
      await _repository.addComment(
        postId: postId,
        authorUid: user.uid,
        authorDisplayName: user.displayName ?? 'Pejuang GERAKIN',
        content: content,
      );

      await fetchFeed();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> reportContent({
    required String targetType,
    required int targetId,
    required String reason,
  }) async {
    final authState = ref.read(authControllerProvider);
    final user = authState.currentUser;
    final reporterUid = user?.uid ?? 'anonymous_reporter';

    await _repository.reportContent(
      targetType: targetType,
      targetId: targetId,
      reporterUid: reporterUid,
      reason: reason,
    );

    await fetchFeed();
  }
}

final communityFeedControllerProvider =
    NotifierProvider<CommunityFeedController, CommunityFeedState>(
  CommunityFeedController.new,
);
