import 'dart:async';

import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/data/repositories/local_auth_repository.dart';
import 'package:enhorario/features/wait_times/data/models/wait_time_model.dart';
import 'package:enhorario/features/wait_times/domain/repositories/wait_time_repository.dart';

class LocalWaitTimeRepository implements WaitTimeRepository {
  static final StreamController<Map<String, WaitTimeModel>> _controller =
      StreamController<Map<String, WaitTimeModel>>.broadcast();

  static final Map<String, WaitTimeModel> _itemsByEstablishment = {
    'est-banco-centro': WaitTimeModel(
      id: 'est-banco-centro',
      establishmentId: 'est-banco-centro',
      minutos: 18,
      actualizadoEn: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    'est-pizza-norte': WaitTimeModel(
      id: 'est-pizza-norte',
      establishmentId: 'est-pizza-norte',
      minutos: 7,
      actualizadoEn: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
  };

  @override
  Stream<WaitTimeModel?> watchByEstablishment(String establishmentId) async* {
    yield _itemsByEstablishment[establishmentId];
    yield* _controller.stream.map((map) => map[establishmentId]);
  }

  @override
  Future<Result<void>> upsert(WaitTimeModel model) async {
    if (LocalAuthRepository.currentUserSync == null) {
      return const Left<Failure, void>(Failure('Debes iniciar sesion'));
    }

    _itemsByEstablishment[model.establishmentId] = model.copyWith(
      id: model.establishmentId,
      actualizadoEn: DateTime.now(),
    );
    _emit();
    return const Right<Failure, void>(null);
  }

  static void _emit() {
    _controller.add(Map<String, WaitTimeModel>.from(_itemsByEstablishment));
  }
}
