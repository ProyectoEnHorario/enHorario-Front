import 'dart:async';

import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/core/utils/string_normalizer.dart';
import 'package:enhorario/features/auth/data/repositories/local_auth_repository.dart';
import 'package:enhorario/features/establishments/data/models/establishment_model.dart';
import 'package:enhorario/features/establishments/domain/repositories/establishment_repository.dart';

class LocalEstablishmentRepository implements EstablishmentRepository {
  static final StreamController<List<EstablishmentModel>> _controller =
      StreamController<List<EstablishmentModel>>.broadcast();

  static final List<EstablishmentModel> _items = [
    EstablishmentModel(
      id: 'est-banco-centro',
      nombre: 'Banco Centro',
      nombreNormalizado: 'banco centro',
      descripcion: 'Sucursal principal en el centro.',
      direccion: 'Calle 10 # 5-20',
      categoryId: 'cat-bancos',
      adminId: 'usr-admin',
      activo: true,
      abierto: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    EstablishmentModel(
      id: 'est-pizza-norte',
      nombre: 'Pizza Norte',
      nombreNormalizado: 'pizza norte',
      descripcion: 'Restaurante de comida rapida.',
      direccion: 'Avenida 30 # 18-90',
      categoryId: 'cat-restaurantes',
      adminId: 'usr-admin',
      activo: true,
      abierto: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Stream<List<EstablishmentModel>> watchAll() async* {
    yield _sortedItems();
    yield* _controller.stream;
  }

  @override
  Future<Result<List<EstablishmentModel>>> fetchForSearch() async {
    return Right<Failure, List<EstablishmentModel>>(_sortedItems());
  }

  @override
  Future<Result<void>> create(EstablishmentModel model) async {
    final user = LocalAuthRepository.currentUserSync;
    if (user == null) {
      return const Left<Failure, void>(Failure('Debes iniciar sesion'));
    }

    _items.add(
      model.copyWith(
        adminId: user.uid,
        nombreNormalizado: StringNormalizer.normalize(model.nombre),
      ),
    );
    _emit();
    return const Right<Failure, void>(null);
  }

  @override
  Future<Result<void>> update(EstablishmentModel model) async {
    final index = _items.indexWhere((it) => it.id == model.id);
    if (index < 0) {
      return const Left<Failure, void>(Failure('Establecimiento no encontrado'));
    }

    _items[index] = model.copyWith(
      nombreNormalizado: StringNormalizer.normalize(model.nombre),
    );
    _emit();
    return const Right<Failure, void>(null);
  }

  @override
  Future<Result<void>> delete(String id) async {
    _items.removeWhere((it) => it.id == id);
    _emit();
    return const Right<Failure, void>(null);
  }

  static List<EstablishmentModel> _sortedItems() {
    final cloned = List<EstablishmentModel>.from(_items);
    cloned.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return cloned;
  }

  static void _emit() {
    _controller.add(_sortedItems());
  }
}
