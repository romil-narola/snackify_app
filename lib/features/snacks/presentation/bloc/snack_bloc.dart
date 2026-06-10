import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../../../core/common_imports.dart';

// --- Events ---
abstract class SnackEvent extends Equatable {
  const SnackEvent();
  @override
  List<Object?> get props => [];
}

class LoadSnacks extends SnackEvent {}

class SearchQueryChanged extends SnackEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class CategorySelected extends SnackEvent {
  final String category;
  const CategorySelected(this.category);
  @override
  List<Object?> get props => [category];
}

class FilterApplied extends SnackEvent {
  final double minPrice;
  final double maxPrice;
  final bool onlyAvailable;
  const FilterApplied({
    required this.minPrice,
    required this.maxPrice,
    required this.onlyAvailable,
  });
  @override
  List<Object?> get props => [minPrice, maxPrice, onlyAvailable];
}

class ToggleViewMode extends SnackEvent {}

// --- States ---
abstract class SnackState extends Equatable {
  const SnackState();
  @override
  List<Object?> get props => [];
}

class SnackInitial extends SnackState {}

class SnackLoading extends SnackState {}

class SnackLoaded extends SnackState {
  final List<SnackModel> allSnacks;
  final List<SnackModel> filteredSnacks;
  final String selectedCategory;
  final String searchQuery;
  final double minPrice;
  final double maxPrice;
  final bool onlyAvailable;
  final bool isGridView;

  const SnackLoaded({
    required this.allSnacks,
    required this.filteredSnacks,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.minPrice = 0.0,
    this.maxPrice = 20.0,
    this.onlyAvailable = false,
    this.isGridView = true,
  });

  SnackLoaded copyWith({
    List<SnackModel>? allSnacks,
    List<SnackModel>? filteredSnacks,
    String? selectedCategory,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    bool? onlyAvailable,
    bool? isGridView,
  }) {
    return SnackLoaded(
      allSnacks: allSnacks ?? this.allSnacks,
      filteredSnacks: filteredSnacks ?? this.filteredSnacks,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      isGridView: isGridView ?? this.isGridView,
    );
  }

  @override
  List<Object?> get props => [
    allSnacks,
    filteredSnacks,
    selectedCategory,
    searchQuery,
    minPrice,
    maxPrice,
    onlyAvailable,
    isGridView,
  ];
}

class SnackError extends SnackState {
  final String message;
  const SnackError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class SnackBloc extends Bloc<SnackEvent, SnackState> {
  final SnackRepository snackRepository;
  StreamSubscription? _snackSubscription;

  SnackBloc({required this.snackRepository}) : super(SnackInitial()) {
    on<LoadSnacks>(_onLoadSnacks);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<CategorySelected>(_onCategorySelected);
    on<FilterApplied>(_onFilterApplied);
    on<ToggleViewMode>(_onToggleViewMode);
    on(_onSnacksDataUpdated);
  }

  void _onLoadSnacks(LoadSnacks event, Emitter<SnackState> emit) {
    emit(SnackLoading());
    _snackSubscription?.cancel();
    _snackSubscription = snackRepository.getSnacks().listen((snacks) {
      if (!isClosed) {
        add(_SnacksUpdated(snacks));
      }
    });
  }

  void _onSnacksDataUpdated(_SnacksUpdated event, Emitter<SnackState> emit) {
    final currentState = state;
    if (currentState is SnackLoaded) {
      final updatedFiltered = _filterList(
        event.snacks,
        currentState.selectedCategory,
        currentState.searchQuery,
        currentState.minPrice,
        currentState.maxPrice,
        currentState.onlyAvailable,
      );
      emit(
        currentState.copyWith(
          allSnacks: event.snacks,
          filteredSnacks: updatedFiltered,
        ),
      );
    } else {
      emit(SnackLoaded(allSnacks: event.snacks, filteredSnacks: event.snacks));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SnackState> emit,
  ) {
    final currentState = state;
    if (currentState is SnackLoaded) {
      final updatedFiltered = _filterList(
        currentState.allSnacks,
        currentState.selectedCategory,
        event.query,
        currentState.minPrice,
        currentState.maxPrice,
        currentState.onlyAvailable,
      );
      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredSnacks: updatedFiltered,
        ),
      );
    }
  }

  void _onCategorySelected(CategorySelected event, Emitter<SnackState> emit) {
    final currentState = state;
    if (currentState is SnackLoaded) {
      final updatedFiltered = _filterList(
        currentState.allSnacks,
        event.category,
        currentState.searchQuery,
        currentState.minPrice,
        currentState.maxPrice,
        currentState.onlyAvailable,
      );
      emit(
        currentState.copyWith(
          selectedCategory: event.category,
          filteredSnacks: updatedFiltered,
        ),
      );
    }
  }

  void _onFilterApplied(FilterApplied event, Emitter<SnackState> emit) {
    final currentState = state;
    if (currentState is SnackLoaded) {
      final updatedFiltered = _filterList(
        currentState.allSnacks,
        currentState.selectedCategory,
        currentState.searchQuery,
        event.minPrice,
        event.maxPrice,
        event.onlyAvailable,
      );
      emit(
        currentState.copyWith(
          minPrice: event.minPrice,
          maxPrice: event.maxPrice,
          onlyAvailable: event.onlyAvailable,
          filteredSnacks: updatedFiltered,
        ),
      );
    }
  }

  void _onToggleViewMode(ToggleViewMode event, Emitter<SnackState> emit) {
    final currentState = state;
    if (currentState is SnackLoaded) {
      emit(currentState.copyWith(isGridView: !currentState.isGridView));
    }
  }

  List<SnackModel> _filterList(
    List<SnackModel> list,
    String category,
    String query,
    double min,
    double max,
    bool onlyAvailable,
  ) {
    return list.where((snack) {
      final matchesCategory =
          category == 'All' ||
          snack.category.toLowerCase() == category.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          snack.name.toLowerCase().contains(query.toLowerCase()) ||
          snack.description.toLowerCase().contains(query.toLowerCase());
      final matchesPrice = snack.price >= min && snack.price <= max;
      final matchesAvailability = !onlyAvailable || snack.available;
      return matchesCategory &&
          matchesQuery &&
          matchesPrice &&
          matchesAvailability;
    }).toList();
  }

  @override
  Future<void> close() {
    _snackSubscription?.cancel();
    return super.close();
  }
}

// Internal update event
class _SnacksUpdated extends SnackEvent {
  final List<SnackModel> snacks;
  const _SnacksUpdated(this.snacks);
  @override
  List<Object?> get props => [snacks];
}
