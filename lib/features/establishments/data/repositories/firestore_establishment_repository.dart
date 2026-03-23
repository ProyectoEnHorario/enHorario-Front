import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/core/utils/string_normalizer.dart';
import 'package:enhorario/features/establishments/data/models/establishment_model.dart';
import 'package:enhorario/features/establishments/domain/repositories/establishment_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreEstablishmentRepository implements EstablishmentRepository {
  FirestoreEstablishmentRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('establishments');

  @override
  Stream<List<EstablishmentModel>> watchAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EstablishmentModel.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Future<Result<void>> create(EstablishmentModel model) async {
    try {
      final adminId = await _ensureAdmin();
      final doc = _collection.doc();
      final data = model
          .copyWith(
            id: doc.id,
            adminId: adminId,
            nombreNormalizado: StringNormalizer.normalize(model.nombre),
          )
          .toMap();
      await doc.set(data);
      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'No se pudo crear establecimiento'),
      );
    } on StateError catch (e) {
      return Left<Failure, void>(Failure(e.message));
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado al crear establecimiento'),
      );
    }
  }

  @override
  Future<Result<void>> update(EstablishmentModel model) async {
    try {
      await _ensureAdmin();
      await _collection
          .doc(model.id)
          .update(
            model
                .copyWith(
                  nombreNormalizado: StringNormalizer.normalize(model.nombre),
                )
                .toMap(),
          );
      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'No se pudo actualizar establecimiento'),
      );
    } on StateError catch (e) {
      return Left<Failure, void>(Failure(e.message));
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado al actualizar establecimiento'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _ensureAdmin();
      await _collection.doc(id).delete();
      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'No se pudo eliminar establecimiento'),
      );
    } on StateError catch (e) {
      return Left<Failure, void>(Failure(e.message));
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado al eliminar establecimiento'),
      );
    }
  }

  Future<String> _ensureAdmin() async {
    final current = _auth.currentUser;
    if (current == null) {
      throw StateError('Debes iniciar sesion');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(current.uid)
        .get();
    final rol = snapshot.data()?['rol'];
    if (rol != 'admin') {
      throw StateError('Solo administradores pueden realizar esta accion');
    }
    return current.uid;
  }
}
