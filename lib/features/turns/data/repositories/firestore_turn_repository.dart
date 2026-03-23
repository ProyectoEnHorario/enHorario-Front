import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/turns/data/models/turn_model.dart';
import 'package:enhorario/features/turns/domain/repositories/turn_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreTurnRepository implements TurnRepository {
  FirestoreTurnRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  String? _cachedAdminUid;
  bool? _cachedIsAdmin;

  CollectionReference<Map<String, dynamic>> _turnsOf(String establishmentId) {
    return _firestore
        .collection('establishments')
        .doc(establishmentId)
        .collection('turns');
  }

  @override
  Stream<List<TurnModel>> watchByEstablishment(String establishmentId) {
    return _turnsOf(establishmentId).orderBy('posicion').snapshots().asyncMap((
      snapshot,
    ) async {
      final isAdmin = await _isCurrentUserAdminCached();
      final currentUid = _auth.currentUser?.uid;
      final turns = snapshot.docs
          .map((doc) => TurnModel.fromMap(doc.data(), id: doc.id))
          .where((turn) => isAdmin || turn.userId == currentUid)
          .toList();
      turns.sort((a, b) => a.posicion.compareTo(b.posicion));
      return turns;
    });
  }

  @override
  Future<Result<void>> createTurn({
    required String establishmentId,
    required String tipo,
  }) async {
    try {
      final current = _auth.currentUser;
      if (current == null) {
        return const Left<Failure, void>(Failure('Debes iniciar sesion'));
      }
      final turnsRef = _turnsOf(establishmentId);
      final doc = turnsRef.doc();

      final snapshot = await turnsRef.get();
      final existing = snapshot.docs
          .map((d) => TurnModel.fromMap(d.data(), id: d.id))
          .toList();

      final totalByTipo = existing.where((t) => t.tipo == tipo).length;
      final codePrefix = tipo == 'prioritario' ? 'P' : 'A';
      final codigo =
          '$codePrefix-${(totalByTipo + 1).toString().padLeft(3, '0')}';

      final queue = existing.where((t) => t.estado == 'en_espera').toList()
        ..sort((a, b) {
          final prioA = a.tipo == 'prioritario' ? 0 : 1;
          final prioB = b.tipo == 'prioritario' ? 0 : 1;
          final byType = prioA.compareTo(prioB);
          if (byType != 0) return byType;
          return a.solicitadoEn.compareTo(b.solicitadoEn);
        });

      final prioCount = queue.where((t) => t.tipo == 'prioritario').length;
      final position = tipo == 'prioritario' ? prioCount + 1 : queue.length + 1;

      final model = TurnModel(
        id: doc.id,
        userId: current.uid,
        establishmentId: establishmentId,
        codigo: codigo,
        tipo: tipo,
        estado: 'en_espera',
        posicion: position,
        solicitadoEn: DateTime.now(),
      );

      await doc.set(model.toMap());

      await _recalculatePositions(establishmentId);
      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'No se pudo crear turno'),
      );
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado al crear turno'),
      );
    }
  }

  @override
  Future<Result<void>> updateStatus({
    required String establishmentId,
    required String turnId,
    required String estado,
  }) async {
    try {
      final docRef = _turnsOf(establishmentId).doc(turnId);
      final doc = await docRef.get();
      if (!doc.exists) {
        return const Left<Failure, void>(Failure('Turno no encontrado'));
      }

      final data = doc.data()!;
      final isAdmin = await _isCurrentUserAdminCached();
      final currentUid = _auth.currentUser?.uid;
      if (!isAdmin && data['userId'] != currentUid) {
        return const Left<Failure, void>(
          Failure('No tienes permisos para actualizar este turno'),
        );
      }

      final updates = <String, dynamic>{'estado': estado};
      if (estado == 'atendido') updates['atendidoEn'] = Timestamp.now();
      if (estado == 'cancelado') updates['canceladoEn'] = Timestamp.now();

      await docRef.update(updates);
      await _recalculatePositions(establishmentId);
      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'No se pudo actualizar estado'),
      );
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado al actualizar estado'),
      );
    }
  }

  @override
  Future<Result<void>> cancelTurn({
    required String establishmentId,
    required String turnId,
  }) async {
    try {
      final ref = _turnsOf(establishmentId).doc(turnId);
      final doc = await ref.get();
      if (!doc.exists) {
        return const Left<Failure, void>(Failure('Turno no encontrado'));
      }

      final data = doc.data()!;
      final current = _auth.currentUser;
      final isAdmin = await _isCurrentUserAdminCached();
      if (!isAdmin && data['userId'] != current?.uid) {
        return const Left<Failure, void>(
          Failure('Solo puedes cancelar tus propios turnos'),
        );
      }

      await ref.update({'estado': 'cancelado', 'canceladoEn': Timestamp.now()});
      await _recalculatePositions(establishmentId);
      return const Right<Failure, void>(null);
    } on FirebaseException catch (e) {
      return Left<Failure, void>(
        Failure(e.message ?? 'No se pudo cancelar turno'),
      );
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado al cancelar turno'),
      );
    }
  }

  Future<void> _recalculatePositions(String establishmentId) async {
    final ref = _turnsOf(establishmentId);
    final snapshot = await ref.where('estado', isEqualTo: 'en_espera').get();
    final queue =
        snapshot.docs.map((d) => TurnModel.fromMap(d.data(), id: d.id)).toList()
          ..sort((a, b) {
            final pa = a.tipo == 'prioritario' ? 0 : 1;
            final pb = b.tipo == 'prioritario' ? 0 : 1;
            final byType = pa.compareTo(pb);
            if (byType != 0) return byType;
            return a.solicitadoEn.compareTo(b.solicitadoEn);
          });

    final batch = _firestore.batch();
    for (var i = 0; i < queue.length; i++) {
      batch.update(ref.doc(queue[i].id), {'posicion': i + 1});
    }
    await batch.commit();
  }

  Future<bool> _isCurrentUserAdmin() async {
    final current = _auth.currentUser;
    if (current == null) return false;
    final userDoc = await _firestore.collection('users').doc(current.uid).get();
    return userDoc.data()?['rol'] == 'admin';
  }

  Future<bool> _isCurrentUserAdminCached() async {
    final current = _auth.currentUser;
    if (current == null) {
      _cachedAdminUid = null;
      _cachedIsAdmin = false;
      return false;
    }

    if (_cachedAdminUid == current.uid && _cachedIsAdmin != null) {
      return _cachedIsAdmin!;
    }

    final isAdmin = await _isCurrentUserAdmin();
    _cachedAdminUid = current.uid;
    _cachedIsAdmin = isAdmin;
    return isAdmin;
  }
}
