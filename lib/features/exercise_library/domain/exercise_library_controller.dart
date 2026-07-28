import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/asset_exercise_repository_impl.dart';
import '../models/full_exercise_definition.dart';
import '../repository/exercise_repository.dart';
import '../services/exercise_filter.dart';
import '../services/exercise_search.dart';

/// Class pembungkus State Katalog Latihan untuk UI.
class ExerciseLibraryState {
  const ExerciseLibraryState({
    required this.allExercises,
    required this.filteredExercises,
    required this.selectedCategory,
    required this.selectedDifficulty,
    required this.searchQuery,
    required this.isLoading,
  });

  final List<FullExerciseDefinition> allExercises;
  final List<FullExerciseDefinition> filteredExercises;
  final String selectedCategory;
  final int selectedDifficulty;
  final String searchQuery;
  final bool isLoading;

  factory ExerciseLibraryState.initial() {
    return const ExerciseLibraryState(
      allExercises: [],
      filteredExercises: [],
      selectedCategory: 'All',
      selectedDifficulty: 0,
      searchQuery: '',
      isLoading: true,
    );
  }

  ExerciseLibraryState copyWith({
    List<FullExerciseDefinition>? allExercises,
    List<FullExerciseDefinition>? filteredExercises,
    String? selectedCategory,
    int? selectedDifficulty,
    String? searchQuery,
    bool? isLoading,
  }) {
    return ExerciseLibraryState(
      allExercises: allExercises ?? this.allExercises,
      filteredExercises: filteredExercises ?? this.filteredExercises,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider untuk [ExerciseRepository].
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return AssetExerciseRepositoryImpl();
});

/// Riverpod Provider untuk [ExerciseLibraryController].
final exerciseLibraryProvider =
    NotifierProvider<ExerciseLibraryController, ExerciseLibraryState>(
  ExerciseLibraryController.new,
);

/// Controller (Riverpod Notifier) untuk mengelola katalog latihan ECMS.
class ExerciseLibraryController extends Notifier<ExerciseLibraryState> {
  ExerciseLibraryController({
    ExerciseRepository? repository,
    ExerciseSearch? searchService,
    ExerciseFilter? filterService,
  })  : _overrideRepository = repository,
        _searchService = searchService ?? const ExerciseSearch(),
        _filterService = filterService ?? const ExerciseFilter();

  final ExerciseRepository? _overrideRepository;
  final ExerciseSearch _searchService;
  final ExerciseFilter _filterService;

  ExerciseRepository get _repository =>
      _overrideRepository ?? ref.read(exerciseRepositoryProvider);

  @override
  ExerciseLibraryState build() {
    state = ExerciseLibraryState.initial();
    loadLibrary();
    return state;
  }

  /// Memuat katalog latihan dari repository asset JSON.
  Future<void> loadLibrary() async {
    state = state.copyWith(isLoading: true);
    final list = await _repository.getAllExercises();
    state = state.copyWith(
      allExercises: list,
      filteredExercises: list,
      isLoading: false,
    );
  }

  /// Memperbarui query pencarian.
  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Memilih kategori latihan.
  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  /// Memilih level kesulitan (0 = Semua, 1-5).
  void selectDifficulty(int level) {
    state = state.copyWith(selectedDifficulty: level);
    _applyFilters();
  }

  void _applyFilters() {
    var result = _searchService.search(
      exercises: state.allExercises,
      query: state.searchQuery,
    );

    result = _filterService.filter(
      exercises: result,
      category: state.selectedCategory,
      difficultyLevel: state.selectedDifficulty,
    );

    state = state.copyWith(filteredExercises: result);
  }
}
