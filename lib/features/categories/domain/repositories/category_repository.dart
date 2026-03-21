import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/categories/data/models/category_model.dart';

abstract class CategoryRepository {
  Stream<List<CategoryModel>> watchAll();

  Future<Result<void>> create(CategoryModel model);

  Future<Result<void>> update(CategoryModel model);

  Future<Result<void>> delete(String id);
}
