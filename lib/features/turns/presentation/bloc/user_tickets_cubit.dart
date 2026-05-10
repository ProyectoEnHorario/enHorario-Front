import 'dart:convert';

import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/config/app_config.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/turns/data/models/turn_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTicketsState {
  const UserTicketsState({
    this.tickets = const [],
    this.isLoading = false,
    this.isCreatingTurn = false,
    this.isDeletingTurn = false,
    this.error,
    this.successMessage,
  });

  final List<TurnModel> tickets;
  final bool isLoading;
  final bool isCreatingTurn;
  final bool isDeletingTurn;
  final String? error;
  final String? successMessage;

  UserTicketsState copyWith({
    List<TurnModel>? tickets,
    bool? isLoading,
    bool? isCreatingTurn,
    bool? isDeletingTurn,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return UserTicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      isCreatingTurn: isCreatingTurn ?? this.isCreatingTurn,
      isDeletingTurn: isDeletingTurn ?? this.isDeletingTurn,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class UserTicketsCubit extends Cubit<UserTicketsState> {
  UserTicketsCubit({
    ApiClient? apiClient,
    AuthSessionRepository? sessionRepository,
  }) : _apiClient = apiClient ?? ApiClient(),
       _session_repository = sessionRepository ?? AuthSessionRepository(),
       super(const UserTicketsState());

  static const String _ticketsKeyPrefix = 'user_tickets_';
  final ApiClient _apiClient;
  final AuthSessionRepository _session_repository;

  Future<String> _buildStorageKey(SharedPreferences prefs) async {
    final email = prefs.getString(AppConfig.userKey) ?? 'anon';
    return '$_ticketsKeyPrefix$email';
  }

  Future<void> _persistTickets(List<TurnModel> tickets) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _buildStorageKey(prefs);
    final payload = tickets.map((ticket) => ticket.toMap()).toList();
    await prefs.setString(key, jsonEncode(payload));
  }

  Future<String?> _getSessionUserId() async {
    try {
      return await _session_repository.getCurrentUserId();
    } catch (_) {
      return null;
    }
  }

  /// Cargar tickets persistidos del usuario o desde API si hay sesión
  Future<void> loadUserTickets() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final userId = await _getSessionUserId();
      if (userId == null || userId.trim().isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final key = await _buildStorageKey(prefs);
        final encoded = prefs.getString(key);

        final List<TurnModel> tickets;
        if (encoded == null || encoded.trim().isEmpty) {
          tickets = const <TurnModel>[];
        } else {
          final decoded = jsonDecode(encoded) as List<dynamic>;
          tickets = decoded.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            final id =
                (map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
                    .toString();
            return TurnModel.fromMap(map, id: id);
          }).toList();
        }

        emit(state.copyWith(tickets: tickets, isLoading: false));
        return;
      }

      final active = await _fetchTickets(
        '/turns/my-turns/active',
        token: userId,
      );
      final history = await _fetchTickets(
        '/turns/my-turns/history',
        token: userId,
      );
      final tickets = _mergeTickets(active, history);
      await _persistTickets(tickets);
      emit(state.copyWith(tickets: tickets, isLoading: false));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          error: 'No fue posible cargar los turnos: ${e.message}',
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(error: 'Error al cargar tickets: $e', isLoading: false),
      );
    }
  }

  /// Crear un nuevo ticket (turno) en API o local si no hay sesión
  Future<void> createTurn({
    required String establishmentId,
    required bool isPriority,
    String? priorityReason,
  }) async {
    emit(state.copyWith(isCreatingTurn: true, clearError: true));
    try {
      final hasActive = state.tickets.any((t) => t.estado == 'en_espera');
      if (hasActive) {
        emit(
          state.copyWith(
            isCreatingTurn: false,
            error: 'Ya tienes un turno activo.',
          ),
        );
        return;
      }

      final userId = await _getSessionUserId();
      if (userId == null || userId.trim().isEmpty) {
        final newTurn = TurnModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user',
          establishmentId: establishmentId,
          codigo:
              'T-${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
          tipo: isPriority ? 'preferencial' : 'regular',
          estado: 'en_espera',
          posicion: 1,
          solicitadoEn: DateTime.now(),
        );
        final updated = [...state.tickets, newTurn];
        await _persistTickets(updated);
        emit(
          state.copyWith(
            tickets: updated,
            isCreatingTurn: false,
            successMessage: 'Ticket creado (local)',
          ),
        );
        return;
      }

      await _apiClient.post<dynamic>(
        '/turns',
        data: {
          'establishmentId': establishmentId,
          'turnType': isPriority ? 'PRIORITY' : 'REGULAR',
        },
        token: userId,
      );
      await loadUserTickets();
      emit(
        state.copyWith(
          isCreatingTurn: false,
          successMessage: 'Ticket creado exitosamente',
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          error: 'Error al crear ticket: ${e.message}',
          isCreatingTurn: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Error al crear ticket: $e',
          isCreatingTurn: false,
        ),
      );
    }
  }

  /// Cancelar turno (API) o eliminar localmente
  Future<void> deleteTurn(String turnId) async {
    emit(state.copyWith(isDeletingTurn: true, clearError: true));
    try {
      final userId = await _getSessionUserId();
      if (userId == null || userId.trim().isEmpty) {
        final updated = state.tickets.where((t) => t.id != turnId).toList();
        await _persistTickets(updated);
        emit(
          state.copyWith(
            tickets: updated,
            isDeletingTurn: false,
            successMessage: 'Ticket eliminado (local)',
          ),
        );
        return;
      }

      await _apiClient.delete('/turns/$turnId/cancel', token: userId);
      await loadUserTickets();
      emit(
        state.copyWith(
          isDeletingTurn: false,
          successMessage: 'Ticket cancelado exitosamente',
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          error: 'Error al cancelar ticket: ${e.message}',
          isDeletingTurn: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Error al eliminar ticket: $e',
          isDeletingTurn: false,
        ),
      );
    }
  }

  /// Marcar atendido (API) o local
  Future<void> markTicketAsAttended(String turnId) async {
    try {
      final userId = await _getSessionUserId();
      if (userId == null || userId.trim().isEmpty) {
        final updated = state.tickets
            .map((t) => t.id == turnId ? t.copyWith(estado: 'atendido') : t)
            .toList();
        await _persistTickets(updated);
        emit(
          state.copyWith(
            tickets: updated,
            successMessage: 'Ticket marcado como atendido (local)',
          ),
        );
        return;
      }

      await _apiClient.put<dynamic>(
        '/turns/$turnId/status',
        data: {'status': 'ATTENDED'},
        token: userId,
      );
      await loadUserTickets();
      emit(state.copyWith(successMessage: 'Ticket marcado como atendido'));
    } on ApiException catch (e) {
      emit(state.copyWith(error: 'Error al actualizar ticket: ${e.message}'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al actualizar ticket: $e'));
    }
  }

  Future<List<TurnModel>> _fetchTickets(
    String path, {
    required String token,
  }) async {
    final response = await _apiClient.get<dynamic>(path, token: token);
    final items = _extractList(response);
    return items.whereType<Map<String, dynamic>>().map((item) {
      final id =
          (item['id'] ??
                  item['turnId'] ??
                  DateTime.now().millisecondsSinceEpoch.toString())
              .toString();
      return TurnModel.fromMap(item, id: id);
    }).toList();
  }

  List<TurnModel> _mergeTickets(
    List<TurnModel> active,
    List<TurnModel> history,
  ) {
    final byId = <String, TurnModel>{};
    for (final t in [...active, ...history]) byId[t.id] = t;
    final list = byId.values.toList()
      ..sort((a, b) => b.solicitadoEn.compareTo(a.solicitadoEn));
    return list;
  }

  List<dynamic> _extractList(dynamic resp) {
    if (resp is List) return resp;
    if (resp is Map<String, dynamic>) {
      final c = resp['content'];
      if (c is List) return c;
    }
    return const [];
  }

  /// Limpiar mensajes de éxito
  void clearSuccessMessage() {
    emit(state.copyWith(successMessage: '', clearSuccessMessage: true));
  }

  /// Limpiar errores
  void clearError() {
    emit(state.copyWith(error: '', clearError: true));
  }
}
