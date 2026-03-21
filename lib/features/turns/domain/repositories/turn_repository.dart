import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/turns/data/models/turn_model.dart';

abstract class TurnRepository {
  Stream<List<TurnModel>> watchByEstablishment(String establishmentId);

  Future<Result<void>> createTurn({
    required String establishmentId,
    required String tipo,
  });

  Future<Result<void>> updateStatus({
    required String establishmentId,
    required String turnId,
    required String estado,
  });

  Future<Result<void>> cancelTurn({
    required String establishmentId,
    required String turnId,
  });
}
