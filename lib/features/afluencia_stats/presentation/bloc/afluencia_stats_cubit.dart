import 'dart:async';

import 'package:enhorario/features/afluencia_stats/data/models/afluencia_stat_model.dart';
import 'package:enhorario/features/afluencia_stats/domain/repositories/afluencia_stats_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AfluenciaStatsState {
  const AfluenciaStatsState({
    this.all = const [],
    this.filtered = const [],
    this.isLoading = true,
    this.error,
    this.periodo,
    this.from,
    this.to,
  });

  final List<AfluenciaStatModel> all;
  final List<AfluenciaStatModel> filtered;
  final bool isLoading;
  final String? error;
  final String? periodo;
  final DateTime? from;
  final DateTime? to;

  AfluenciaStatsState copyWith({
    List<AfluenciaStatModel>? all,
    List<AfluenciaStatModel>? filtered,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? periodo,
    bool clearPeriodo = false,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
  }) {
    return AfluenciaStatsState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      periodo: clearPeriodo ? null : (periodo ?? this.periodo),
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
    );
  }
}

class AfluenciaStatsCubit extends Cubit<AfluenciaStatsState> {
  AfluenciaStatsCubit(this._repository) : super(const AfluenciaStatsState()) {
    _subscription = _repository.watchAll().listen(
      (items) {
        final next = state.copyWith(
          all: items,
          isLoading: false,
          clearError: true,
        );
        emit(_applyFilters(next));
      },
      onError: (_) => emit(
        state.copyWith(isLoading: false, error: 'Error cargando estadisticas'),
      ),
    );
  }

  final AfluenciaStatsRepository _repository;
  StreamSubscription<List<AfluenciaStatModel>>? _subscription;

  void setPeriodo(String? periodo) {
    emit(
      _applyFilters(
        state.copyWith(periodo: periodo, clearPeriodo: periodo == null),
      ),
    );
  }

  void setRango(DateTime? from, DateTime? to) {
    emit(
      _applyFilters(
        state.copyWith(
          from: from,
          to: to,
          clearFrom: from == null,
          clearTo: to == null,
        ),
      ),
    );
  }

  Future<String?> create(AfluenciaStatModel model) async {
    final result = await _repository.create(model);
    return result.fold((l) => l.message, (_) => null);
  }

  AfluenciaStatsState _applyFilters(AfluenciaStatsState s) {
    final filtered = s.all.where((item) {
      final byPeriodo = s.periodo == null || s.periodo == item.periodo;
      final byFrom = s.from == null || !item.fechaHora.isBefore(s.from!);
      final byTo = s.to == null || !item.fechaHora.isAfter(s.to!);
      return byPeriodo && byFrom && byTo;
    }).toList();
    return s.copyWith(filtered: filtered);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
