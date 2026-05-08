import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enhorario/features/turns/data/models/turn_model.dart';
import 'package:enhorario/features/turns/data/repositories/railway_turn_repository.dart';

class DailySummaryState {
  final bool isLoading;
  final List<TurnModel> turns;
  final String? error;
  final DateTime selectedDate;

  DailySummaryState({
    this.isLoading = false,
    this.turns = const [],
    this.error,
    required this.selectedDate,
  });

  // Métricas calculadas
  int get totalAtendidos => turns.where((t) => t.estado == 'atendido').length;
  int get totalCancelados => turns.where((t) => t.estado == 'cancelado').length;
  
  double get porcentajePrioritarios {
    if (turns.isEmpty) return 0.0;
    final prioritarios = turns.where((t) => t.tipo == 'prioritario').length;
    return (prioritarios / turns.length) * 100;
  }

  int get tiempoPromedioEsperaMinutos {
    // Solo tomamos turnos atendidos que tengan AMBAS fechas válidas
    final atendidosConFecha = turns.where((t) => 
      t.estado == 'atendido' && 
      t.atendidoEn != null
    ).toList();
    
    if (atendidosConFecha.isEmpty) return 0;

    final totalEspera = atendidosConFecha.fold<int>(0, (sum, t) {
      final espera = t.atendidoEn!.difference(t.solicitadoEn).inMinutes;
      // Evitamos valores negativos si por alguna razón la fecha de atención es previa a la solicitud
      return sum + (espera > 0 ? espera : 0);
    });

    return (totalEspera / atendidosConFecha.length).round();
  }

  DailySummaryState copyWith({
    bool? isLoading,
    List<TurnModel>? turns,
    String? error,
    DateTime? selectedDate,
  }) {
    return DailySummaryState(
      isLoading: isLoading ?? this.isLoading,
      turns: turns ?? this.turns,
      error: error ?? this.error,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class DailySummaryCubit extends Cubit<DailySummaryState> {
  final RailwayTurnRepository _repository;
  Timer? _refreshTimer;

  DailySummaryCubit(this._repository)
      : super(DailySummaryState(selectedDate: DateTime.now()));

  void startAutoRefresh(String establishmentId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      loadSummary(establishmentId);
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  Future<void> loadSummary(String establishmentId, {DateTime? date}) async {
    final targetDate = date ?? state.selectedDate;
    
    // No mostramos loading si es un refresco automático para no molestar al usuario
    if (date != null) {
      emit(state.copyWith(isLoading: true, error: null, selectedDate: targetDate));
    }

    final result = await _repository.fetchDailyTurns(
      establishmentId: establishmentId,
      date: targetDate,
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (turns) => emit(state.copyWith(isLoading: false, turns: turns)),
    );
  }
}
