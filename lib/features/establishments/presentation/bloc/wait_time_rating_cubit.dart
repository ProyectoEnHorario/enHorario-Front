import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enhorario/features/establishments/data/models/wait_time_rating_model.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';

class WaitTimeRatingState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const WaitTimeRatingState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });
}

class WaitTimeRatingCubit extends Cubit<WaitTimeRatingState> {
  final RailwayEstablishmentQueryService _service;
  
  // Guardamos en memoria los establecimientos ya calificados en esta sesión
  static final Set<String> _ratedEstablishmentsSession = {};

  WaitTimeRatingCubit(this._service) : super(const WaitTimeRatingState());

  bool hasAlreadyRated(String establishmentId) {
    return _ratedEstablishmentsSession.contains(establishmentId);
  }

  Future<void> sendRating(String establishmentId, int stars) async {
    if (hasAlreadyRated(establishmentId)) {
      emit(const WaitTimeRatingState(isSuccess: true)); // Ya calificado, lo tratamos como éxito
      return;
    }

    emit(const WaitTimeRatingState(isLoading: true));

    final model = WaitTimeRatingModel(rating: stars);
    final result = await _service.sendWaitTimeRating(establishmentId, model);

    result.fold(
      (failure) {
        emit(WaitTimeRatingState(error: failure.message));
      },
      (_) {
        _ratedEstablishmentsSession.add(establishmentId);
        emit(const WaitTimeRatingState(isSuccess: true));
      },
    );
  }
}
