import 'dart:async';

import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/categories/data/models/category_model.dart';
import 'package:enhorario/features/categories/domain/repositories/category_repository.dart';

class LocalCategoryRepository implements CategoryRepository {
  static final StreamController<List<CategoryModel>> _controller =
      StreamController<List<CategoryModel>>.broadcast();

  static final List<CategoryModel> _items = [
    const CategoryModel(
      id: 'cat-bancos',
      nombre: 'Bancos',
      icono: 'account_balance',
      activa: true,
    ),
    const CategoryModel(
      id: 'cat-restaurantes',
      nombre: 'Restaurantes',
      icono: 'restaurant',
      activa: true,
    ),
    const CategoryModel(
      id: 'cat-supermercados',
      nombre: 'Supermercados',
      icono: 'shopping_cart',
      activa: true,
    ),
  ];

  @override
  Stream<List<CategoryModel>> watchAll() async* {
    yield List<CategoryModel>.unmodifiable(_items);
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> create(CategoryModel model) async {
    _items.add(model);
    _emit();
    return const Right<Failure, void>(null);
  }

  @override
  Future<Result<void>> update(CategoryModel model) async {
    final index = _items.indexWhere((it) => it.id == model.id);
    if (index < 0) {
      return const Left<Failure, void>(Failure('Categoria no encontrada'));
    }
    _items[index] = model;
    _emit();
    return const Right<Failure, void>(null);
  }

  @override
  Future<Result<void>> delete(String id) async {
    _items.removeWhere((it) => it.id == id);
    _emit();
    return const Right<Failure, void>(null);
  }

  static void _emit() {
    _controller.add(List<CategoryModel>.unmodifiable(_items));
  }
}
