import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerakin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gerakin/features/auth/models/auth_user.dart';
import 'package:gerakin/features/auth/presentation/controllers/auth_controller.dart';
import 'package:gerakin/features/auth/domain/repositories/auth_repository.dart';
import 'package:gerakin/features/community/domain/repositories/community_repository.dart';
import 'package:gerakin/features/community/models/community_post.dart';
import 'package:gerakin/features/community/models/community_comment.dart';
import 'package:gerakin/features/community/presentation/controllers/community_feed_controller.dart';
import 'package:gerakin/features/community/services/community_providers.dart';
import 'package:gerakin/features/community/services/content_moderation_service.dart';
import 'package:gerakin/features/user/domain/repositories/user_repository.dart';
import 'package:gerakin/features/user/models/user_profile.dart';
import 'package:gerakin/features/user/models/user_preference.dart';
import 'package:gerakin/features/user/models/assessment_profile.dart';
import 'package:gerakin/features/user/models/wheelchair_profile.dart';
import 'package:gerakin/features/user/models/rehabilitation_goal.dart';
import 'package:gerakin/features/user/models/app_setting.dart';
import 'package:gerakin/features/user/data/repositories/user_repository_impl.dart';

class MockAuthRepository implements AuthRepository {
  AuthUser? _currentUser;

  void setCurrentUser(AuthUser? user) {
    _currentUser = user;
  }

  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(_currentUser);

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    final u = AuthUser(uid: 'u1', email: email, displayName: 'Test User', emailVerified: true);
    _currentUser = u;
    return u;
  }

  @override
  Future<AuthUser> signUp({required String email, required String password, required String displayName}) async {
    final u = AuthUser(uid: 'u1', email: email, displayName: displayName, emailVerified: true);
    _currentUser = u;
    return u;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}

class MockCommunityRepository implements CommunityRepository {
  final List<CommunityPost> _posts = [];
  final List<CommunityComment> _comments = [];

  @override
  Future<List<CommunityPost>> getFeed({String? searchQuery, int limit = 20, int offset = 0}) async {
    return List.from(_posts);
  }

  @override
  Future<int> createPost({
    required String authorUid,
    required String authorDisplayName,
    required String content,
    String? imagePath,
    String? hashtags,
  }) async {
    final id = _posts.length + 1;
    final post = CommunityPost(
      id: id,
      authorUid: authorUid,
      authorDisplayName: authorDisplayName,
      content: content,
      imagePath: imagePath,
      hashtags: hashtags,
      createdAt: DateTime.now(),
      likeCount: 0,
      commentCount: 0,
      syncStatus: 'synced',
    );
    _posts.add(post);
    return id;
  }

  @override
  Future<void> toggleLike(int postId, String userId) async {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final p = _posts[idx];
      _posts[idx] = p.copyWith(likeCount: p.likeCount + 1);
    }
  }

  @override
  Future<List<CommunityComment>> getComments(int postId) async {
    return _comments.where((c) => c.postId == postId).toList();
  }

  @override
  Future<int> addComment({
    required int postId,
    required String authorUid,
    required String authorDisplayName,
    required String content,
  }) async {
    final id = _comments.length + 1;
    final comment = CommunityComment(
      id: id,
      postId: postId,
      authorUid: authorUid,
      authorDisplayName: authorDisplayName,
      content: content,
      createdAt: DateTime.now(),
      syncStatus: 'synced',
    );
    _comments.add(comment);
    return id;
  }

  @override
  Future<void> reportContent({
    required String targetType,
    required int targetId,
    required String reporterUid,
    required String reason,
  }) async {}
}

class MockUserRepository implements UserRepository {
  UserProfile? _activeProfile;
  final List<UserProfile> _profiles = [];

  @override
  Future<UserProfile?> getActiveProfile() async => _activeProfile;

  @override
  Future<int> saveProfile(UserProfile profile) async {
    _profiles.add(profile);
    _activeProfile = profile;
    return profile.id;
  }

  @override
  Future<UserProfile?> getProfileById(int id) async => null;

  @override
  Future<List<UserProfile>> getAllProfiles() async => _profiles;

  @override
  Future<void> deleteProfile(int id) async {}

  @override
  Future<void> switchProfile(int id) async {}

  @override
  Future<UserPreference> getPreferences(int userId) async => UserPreference(
        userId: userId,
        themeMode: 'light',
        enableAudioCues: true,
        enableTts: false,
        dailyReminderTime: '08:00',
      );

  @override
  Future<void> savePreferences(UserPreference preference) async {}

  @override
  Future<List<AssessmentProfile>> getAssessments(int userId) async => [];

  @override
  Future<void> saveAssessment(AssessmentProfile assessment) async {}

  @override
  Future<WheelchairProfile?> getWheelchairProfile(int userId) async => null;

  @override
  Future<void> saveWheelchairProfile(WheelchairProfile wheelchair) async {}

  @override
  Future<List<RehabilitationGoal>> getGoals(int userId) async => [];

  @override
  Future<void> saveGoal(RehabilitationGoal goal) async {}

  @override
  Future<AppSetting> getAppSettings() async => AppSetting(
        languageCode: 'id',
        isOfflineMode: false,
      );

  @override
  Future<void> saveAppSettings(AppSetting setting) async {}
}

void main() {
  group('Community Guest Restriction & Permission Tests', () {
    late ProviderContainer container;
    late MockAuthRepository mockAuthRepo;
    late MockCommunityRepository mockCommunityRepo;
    late MockUserRepository mockUserRepo;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      mockCommunityRepo = MockCommunityRepository();
      mockUserRepo = MockUserRepository();

      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
          communityRepositoryProvider.overrideWithValue(mockCommunityRepo),
          userRepositoryProvider.overrideWithValue(mockUserRepo),
          contentModerationServiceProvider.overrideWithValue(ContentModerationService()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Guest is restricted from creating posts (GUEST_NOT_ALLOWED)', () async {
      mockAuthRepo.setCurrentUser(null);
      final controller = container.read(communityFeedControllerProvider.notifier);

      final success = await controller.createPost(content: 'Halo teman-teman kursi roda!');
      expect(success, isFalse);

      final state = container.read(communityFeedControllerProvider);
      expect(state.errorMessage, equals('GUEST_NOT_ALLOWED'));
    });

    test('Guest is restricted from adding comments (GUEST_NOT_ALLOWED)', () async {
      mockAuthRepo.setCurrentUser(null);
      final controller = container.read(communityFeedControllerProvider.notifier);

      final success = await controller.addComment(postId: 1, content: 'Semangat latihannya!');
      expect(success, isFalse);

      final state = container.read(communityFeedControllerProvider);
      expect(state.errorMessage, equals('GUEST_NOT_ALLOWED'));
    });

    test('Guest CAN read posts feed and view comments', () async {
      mockAuthRepo.setCurrentUser(null);

      // Tambahkan post dan comment secara internal
      await mockCommunityRepo.createPost(
        authorUid: 'user_123',
        authorDisplayName: 'Budi Santoso',
        content: 'Berhasil menyelesaikan 10 repetisi latihan bahu hari ini! #semangat',
      );
      await mockCommunityRepo.addComment(
        postId: 1,
        authorUid: 'user_456',
        authorDisplayName: 'Siti Aminah',
        content: 'Keren sekali kak Budi!',
      );

      final controller = container.read(communityFeedControllerProvider.notifier);
      await controller.fetchFeed();

      final state = container.read(communityFeedControllerProvider);
      expect(state.posts.length, equals(1));
      expect(state.posts.first.content, contains('10 repetisi latihan bahu'));

      final comments = await controller.getComments(1);
      expect(comments.length, equals(1));
      expect(comments.first.content, equals('Keren sekali kak Budi!'));
    });

    test('Authenticated user CAN create post and comments', () async {
      // Simulasikan user login
      mockAuthRepo.setCurrentUser(
        const AuthUser(uid: 'auth_user_1', email: 'user@gerakin.id', displayName: 'Pejuang Gerak', emailVerified: true),
      );
      // Update auth controller state
      await container.read(authControllerProvider.notifier).signIn(
            email: 'user@gerakin.id',
            password: 'password123',
          );

      final controller = container.read(communityFeedControllerProvider.notifier);

      final createSuccess = await controller.createPost(
        content: 'Latihan arm raise 3 set selesai! #gerakin',
      );
      expect(createSuccess, isTrue);

      final commentSuccess = await controller.addComment(
        postId: 1,
        content: 'Terima kasih atas motivasinya!',
      );
      expect(commentSuccess, isTrue);
    });
  });
}
