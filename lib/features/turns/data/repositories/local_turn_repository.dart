import 'dart:async';

import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/data/repositories/local_auth_repository.dart';
import 'package:enhorario/features/turns/data/models/turn_model.dart';
import 'package:enhorario/features/turns/domain/repositories/turn_repository.dart';

class LocalTurnRepository implements TurnRepository {
  static final StreamController<List<TurnModel>> _controller =
      StreamController<List<TurnModel>>.broadcast();

  static final List<TurnModel> _items = [
    TurnModel(
      id: 'turn-001',
      userId: 'usr-tester',
      establishmentId: 'est-banco-centro',
      codigo: 'A-001',
      tipo: 'regular',
      estado: 'en_espera',
      posicion: 1,
      solicitadoEn: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  @override
  Stream<List<TurnModel>> watchByEstablishment(String establishmentId) async* {
    yield _turnsOf(establishmentId);
    yield* _controller.stream.map(
      (_) => _turnsOf(establishmentId),
    );
  }

  @override
  Future<Result<void>> createTurn({
    required String establishmentId,
    required String tipo,
  }) async {
    final user = LocalAuthRepository.currentUserSync;
    if (user == null) {
      return const Left<Failure, void>(Failure('Debes iniciar sesion'));
    }

    final waiting = _turnsOf(establishmentId)
        .where((t) => t.estado == 'en_espera')
        .toList();
    final nextNumber = waiting.length + 1;
    final prefix = tipo == 'prioritario' ? 'P' : 'A';

    _items.add(
      TurnModel(
        id: _generateId('turn'),
        userId: user.uid,
        establishmentId: establishmentId,
        codigo: '$prefix-${nextNumber.toString().padLeft(3, '0')}',
        tipo: tipo,
        estado: 'en_espera',
        posicion: nextNumber,
        solicitadoEn: DateTime.now(),
      ),
    );

    _recalculatePositions(establishmentId);
    _emit();
    return const Right<Failure, void>(null);
  }

  @override
  Future<Result<void>> updateStatus({
    required String establishmentId,
    required String turnId,
    required String estado,
  }) async {
    final index = _items.indexWhere(
      (it) => it.id == turnId && it.establishmentId == establishmentId,
    );
    if (index < 0) {
      return const Left<Failure, void>(Failure('Turno no encontrado'));
    }

    final now = DateTime.now();
    _items[index] = _items[index].copyWith(
      estado: estado,
      atendidoEn: estado == 'atendido' ? now : null,
      canceladoEn: estado == 'cancelado' ? now : null,
      clearAtendidoEn: estado != 'atendido',
      clearCanceladoEn: estado != 'cancelado',
    );

    _recalculatePositions(establishmentId);
    _emit();
    return const Right<Failure, void>(null);
  }

  @override
  Future<Result<void>> cancelTurn({
    required String establishmentId,
    required String turnId,
  }) {
    return updateStatus(
      establishmentId: establishmentId,
      turnId: turnId,
      estado: 'cancelado',
    );
  }

  static List<TurnModel> _turnsOf(String establishmentId) {
    final filtered = _items
        .where((it) => it.establishmentId == establishmentId)
        .toList();
    filtered.sort((a, b) => a.posicion.compareTo(b.posicion));
    return filtered;
  }

  static void _recalculatePositions(String establishmentId) {
    final waiting = _items
        .where(
          (it) =>
              it.establishmentId == establishmentId && it.estado == 'en_espera',
        )
        .toList();

    waiting.sort((a, b) {
      final pa = a.tipo == 'prioritario' ? 0 : 1;
      final pb = b.tipo == 'prioritario' ? 0 : 1;
      final byType = pa.compareTo(pb);
      if (byType != 0) return byType;
      return a.solicitadoEn.compareTo(b.solicitadoEn);
    });

    for (var i = 0; i < waiting.length; i++) {
      final idx = _items.indexWhere((it) => it.id == waiting[i].id);
      if (idx >= 0) {
        _items[idx] = _items[idx].copyWith(posicion: i + 1);
      }
    }
  }

  static void _emit() {
    _controller.add(List<TurnModel>.unmodifiable(_items));
  }

  static String _generateId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}
