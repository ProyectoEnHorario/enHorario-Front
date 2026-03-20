import 'package:enhorario/features/home/data/models/wait_point_model.dart';
import 'package:enhorario/features/home/domain/entities/wait_point.dart';
import 'package:enhorario/features/home/domain/repositories/wait_point_repository.dart';

class InMemoryWaitPointRepository implements WaitPointRepository {
  @override
  Future<List<WaitPoint>> getTodayWaitPoints() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();

    return [
      WaitPointModel(
        name: 'Banco Central - Sucursal Norte',
        category: 'Banco',
        estimatedMinutes: 18,
        updatedAt: now.subtract(const Duration(minutes: 3)),
      ),
      WaitPointModel(
        name: 'Mercado Plaza Viva',
        category: 'Supermercado',
        estimatedMinutes: 9,
        updatedAt: now.subtract(const Duration(minutes: 6)),
      ),
      WaitPointModel(
        name: 'Clínica San Miguel',
        category: 'Salud',
        estimatedMinutes: 27,
        updatedAt: now.subtract(const Duration(minutes: 8)),
      ),
    ];
  }
}
