import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/establishments/data/models/establishment_model.dart';

abstract class EstablishmentRepository {
  Stream<List<EstablishmentModel>> watchAll();

  Future<Result<void>> create(EstablishmentModel model);

  Future<Result<void>> update(EstablishmentModel model);

  Future<Result<void>> delete(String id);
}
