import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/wait_times/data/models/wait_time_model.dart';
import 'package:enhorario/features/wait_times/domain/repositories/wait_time_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreWaitTimeRepository implements WaitTimeRepository {
  FirestoreWaitTimeRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('wait_times');

  @override
  Stream<WaitTimeModel?> watchByEstablishment(String establishmentId) {
    return _collection.doc(establishmentId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return WaitTimeModel.fromMap(doc.data()!, id: doc.id);
    });
  }

  @override
  Future<Result<void>> upsert(WaitTimeModel model) async {
    try {
      final current = _auth.currentUser;
      if (current == null) {
        return const Left<Failure, void>(Failure('Debes iniciar sesion'));
      }
      final userDoc = await _firestore
          .collection('users')
          .doc(current.uid)
          .get();
      if (userDoc.data()?['rol'] != 'admin') {
        return const Left<Failure, void>(
          Failure('Solo admin puede actualizar tiempos'),
        );
      }

      final data = model
          .copyWith(id: model.establishmentId, actualizadoEn: DateTime.now())
          .toMap();
      await _collection.doc(model.establishmentId).set(data);
      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'No se pudo actualizar tiempo'),
      );
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado al actualizar tiempo'),
      );
    }
  }
}
