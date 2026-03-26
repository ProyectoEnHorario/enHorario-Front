import 'dart:async';

import 'package:enhorario/features/afluencia_stats/data/models/afluencia_dashboard_model.dart';
import 'package:enhorario/features/afluencia_stats/domain/filters/stats_date_filter.dart';
import 'package:enhorario/features/afluencia_stats/domain/repositories/afluencia_dashboard_repository.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AfluenciaStatsState {
  const AfluenciaStatsState({
    required this.filter,
    this.data,
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.accessDenied = false,
  });

  final StatsDateFilter filter;
  final AfluenciaDashboardModel? data;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final bool accessDenied;

  AfluenciaStatsState copyWith({
    StatsDateFilter? filter,
    AfluenciaDashboardModel? data,
    bool keepData = true,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    bool? accessDenied,
  }) {
    return AfluenciaStatsState(
      filter: filter ?? this.filter,
      data: keepData ? (data ?? this.data) : data,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      accessDenied: accessDenied ?? this.accessDenied,
    );
  }
}

class AfluenciaStatsCubit extends Cubit<AfluenciaStatsState> {
  AfluenciaStatsCubit(this._repository, this._sessionRepository)
      : super(AfluenciaStatsState(filter: StatsDateFilter.initial())) {
    _loadDashboard(forceInitialLoading: true);
  }

  final AfluenciaDashboardRepository _repository;
  final AuthSessionRepository _sessionRepository;

  int _requestId = 0;
  Timer? _debounce;

  void setPreset(StatsDatePreset preset) {
    final nextFilter = StatsDateFilter.fromPreset(preset);
    emit(
      state.copyWith(
        filter: nextFilter,
        clearError: true,
        accessDenied: false,
      ),
    );
    _scheduleLoad();
  }

  void setCustomRange(DateTime from, DateTime to) {
    final normalizedFrom = DateTime(from.year, from.month, from.day);
    final normalizedTo = DateTime(to.year, to.month, to.day, 23, 59, 59);

    final nextFilter = StatsDateFilter(
      preset: StatsDatePreset.custom,
      from: normalizedFrom,
      to: normalizedTo,
    );

    if (!nextFilter.isValid) {
      emit(
        state.copyWith(
          error: 'El rango es invalido: la fecha inicio no puede ser mayor a la fecha fin.',
          accessDenied: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        filter: nextFilter,
        clearError: true,
        accessDenied: false,
      ),
    );
    _scheduleLoad();
  }

  void refresh() {
    _loadDashboard(forceInitialLoading: state.data == null);
  }

  void _scheduleLoad() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      _loadDashboard(forceInitialLoading: false);
    });
  }

  Future<void> _loadDashboard({required bool forceInitialLoading}) async {
    final currentRequest = ++_requestId;

    if (forceInitialLoading || state.data == null) {
      emit(
        state.copyWith(
          isLoading: true,
          isRefreshing: false,
          clearError: true,
          accessDenied: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: true,
          clearError: true,
          accessDenied: false,
        ),
      );
    }

    final token = await _sessionRepository.getAuthToken() ?? '';
    final result = await _repository.fetchDashboard(
      filter: state.filter,
      token: token,
    );

    if (currentRequest != _requestId) {
      return;
    }

    result.fold(
      (failure) {
        final denied = failure.message.toLowerCase().contains('acceso denegado');
        emit(
          state.copyWith(
            isLoading: false,
            isRefreshing: false,
            error: failure.message,
            accessDenied: denied,
          ),
        );
      },
      (dashboard) {
        emit(
          state.copyWith(
            data: dashboard,
            isLoading: false,
            isRefreshing: false,
            clearError: true,
            accessDenied: false,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
