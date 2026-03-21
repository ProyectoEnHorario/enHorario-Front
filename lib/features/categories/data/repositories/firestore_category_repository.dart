import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/categories/data/models/category_model.dart';
import 'package:enhorario/features/categories/domain/repositories/category_repository.dart';

class FirestoreCategoryRepository implements CategoryRepository {
  FirestoreCategoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('categories');

  @override
  Stream<List<CategoryModel>> watchAll() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), id: doc.id))
          .toList(),
    );
  }

  @override
  Future<Result<void>> create(CategoryModel model) async {
    try {
      final doc = _collection.doc();
      final data = model.copyWith(id: doc.id).toMap();
      await doc.set(data);
      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'No se pudo crear categoria'),
      );
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado al crear categoria'),
      );
    }
  }

  @override
  Future<Result<void>> update(CategoryModel model) async {
    try {
      await _collection.doc(model.id).update(model.toMap());
      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'No se pudo actualizar categoria'),
      );
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado al actualizar categoria'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _collection.doc(id).delete();
      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'No se pudo eliminar categoria'),
      );
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado al eliminar categoria'),
      );
    }
  }
}
