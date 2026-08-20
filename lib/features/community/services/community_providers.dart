import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/objectbox_store.dart';
import '../../sync/data/repositories/sync_repository_impl.dart';
import '../data/datasources/local_community_data_source.dart';
import '../data/repositories/community_repository_impl.dart';
import '../domain/repositories/community_repository.dart';
import 'content_moderation_service.dart';

/// Provider untuk instansiasi [ContentModerationService].
final contentModerationServiceProvider = Provider<ContentModerationService>((ref) {
  return ContentModerationService();
});

/// Provider untuk instansiasi [LocalCommunityDataSource].
final localCommunityDataSourceProvider = Provider<LocalCommunityDataSource>((ref) {
  final store = ref.watch(objectBoxStoreProvider);
  return LocalCommunityDataSourceImpl(store);
});

/// Provider untuk instansiasi [CommunityRepository].
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final localDataSource = ref.watch(localCommunityDataSourceProvider);
  final syncRepository = ref.watch(syncRepositoryProvider);
  return CommunityRepositoryImpl(
    localDataSource: localDataSource,
    syncRepository: syncRepository,
  );
});
