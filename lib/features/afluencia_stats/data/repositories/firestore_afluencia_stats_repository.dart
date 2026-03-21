import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/afluencia_stats/data/models/afluencia_stat_model.dart';
import 'package:enhorario/features/afluencia_stats/domain/repositories/afluencia_stats_repository.dart';

class FirestoreAfluenciaStatsRepository implements AfluenciaStatsRepository {
  FirestoreAfluenciaStatsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('afluencia_stats');

  @override
  Stream<List<AfluenciaStatModel>> watchAll() {
    return _collection
        .orderBy('fechaHora', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AfluenciaStatModel.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Future<Result<void>> create(AfluenciaStatModel model) async {
    try {
      final doc = _collection.doc();
      await doc.set(model.copyWith(id: doc.id).toMap());
      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'No se pudo crear estadistica'),
      );
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado al crear estadistica'),
      );
    }
  }
}
