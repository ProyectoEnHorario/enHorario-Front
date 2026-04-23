import 'package:enhorario/features/establishments/data/models/wait_time_report_model.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WaitTimeReportState {
  const WaitTimeReportState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  final bool isLoading;
  final bool isSuccess;
  final String? error;
}

class WaitTimeReportCubit extends Cubit<WaitTimeReportState> {
  WaitTimeReportCubit(this._service) : super(const WaitTimeReportState());

  final RailwayEstablishmentQueryService _service;

  // Lista estática en memoria para evitar envíos duplicados en la sesión actual
  static final Set<String> _reportedEstablishmentsSession = {};

  bool hasAlreadyReported(String establishmentId) {
    return _reportedEstablishmentsSession.contains(establishmentId);
  }

  Future<void> reportTime(String establishmentId, int minutes) async {
    if (hasAlreadyReported(establishmentId)) {
      emit(const WaitTimeReportState(error: 'Ya repotaste el tiempo de espera para este establecimiento en esta sesión.'));
      return;
    }

    emit(const WaitTimeReportState(isLoading: true));

    final model = WaitTimeReportModel(minutes: minutes);
    final result = await _service.reportWaitTime(establishmentId, model);

    result.fold(
      (failure) {
        emit(WaitTimeReportState(error: failure.message));
      },
      (_) {
        // Bloqueamos envíos futuros a este ID durante esta sesión
        _reportedEstablishmentsSession.add(establishmentId);
        emit(const WaitTimeReportState(isSuccess: true));
      },
    );
  }
}
