import 'dart:async';

import 'package:enhorario/features/categories/data/models/category_model.dart';
import 'package:enhorario/features/categories/domain/repositories/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesState {
  const CategoriesState({
    this.items = const [],
    this.isLoading = true,
    this.error,
  });

  final List<CategoryModel> items;
  final bool isLoading;
  final String? error;

  CategoriesState copyWith({
    List<CategoryModel>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CategoriesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._repository) : super(const CategoriesState()) {
    _subscription = _repository.watchAll().listen(
      (items) => emit(
        state.copyWith(items: items, isLoading: false, clearError: true),
      ),
      onError: (_) => emit(
        state.copyWith(isLoading: false, error: 'Error cargando categorias'),
      ),
    );
  }

  final CategoryRepository _repository;
  StreamSubscription<List<CategoryModel>>? _subscription;

  Future<String?> create(CategoryModel model) async {
    final result = await _repository.create(model);
    return result.fold((l) => l.message, (_) => null);
  }

  Future<String?> update(CategoryModel model) async {
    final result = await _repository.update(model);
    return result.fold((l) => l.message, (_) => null);
  }

  Future<String?> delete(String id) async {
    final result = await _repository.delete(id);
    return result.fold((l) => l.message, (_) => null);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
