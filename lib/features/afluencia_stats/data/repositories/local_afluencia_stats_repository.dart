import 'dart:async';

import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/afluencia_stats/data/models/afluencia_stat_model.dart';
import 'package:enhorario/features/afluencia_stats/domain/repositories/afluencia_stats_repository.dart';

class LocalAfluenciaStatsRepository implements AfluenciaStatsRepository {
  static final StreamController<List<AfluenciaStatModel>> _controller =
      StreamController<List<AfluenciaStatModel>>.broadcast();

  static final List<AfluenciaStatModel> _items = [
    AfluenciaStatModel(
      id: 'afl-001',
      establishmentId: 'est-banco-centro',
      categoryId: 'cat-bancos',
      totalTurnos: 42,
      turnosPrioritarios: 8,
      fechaHora: DateTime.now().subtract(const Duration(hours: 2)),
      periodo: 'diario',
    ),
    AfluenciaStatModel(
      id: 'afl-002',
      establishmentId: 'est-pizza-norte',
      categoryId: 'cat-restaurantes',
      totalTurnos: 28,
      turnosPrioritarios: 6,
      fechaHora: DateTime.now().subtract(const Duration(hours: 1)),
      periodo: 'diario',
    ),
  ];

  @override
  Stream<List<AfluenciaStatModel>> watchAll() async* {
    yield List<AfluenciaStatModel>.unmodifiable(_items);
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> create(AfluenciaStatModel model) async {
    _items.add(model);
    _controller.add(List<AfluenciaStatModel>.unmodifiable(_items));
    return const Right<Failure, void>(null);
  }
}
