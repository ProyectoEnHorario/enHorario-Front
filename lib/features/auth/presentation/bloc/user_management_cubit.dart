import 'package:enhorario/features/auth/domain/entities/app_user.dart';
import 'package:enhorario/features/auth/domain/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum UserManagementStatus { initial, loading, success, error }

class UserManagementState {
  const UserManagementState({
    this.status = UserManagementStatus.initial,
    this.users = const [],
    this.searchQuery = '',
    this.message,
    this.error,
  });

  final UserManagementStatus status;
  final List<AppUser> users;
  final String searchQuery;
  final String? message;
  final String? error;

  UserManagementState copyWith({
    UserManagementStatus? status,
    List<AppUser>? users,
    String? searchQuery,
    String? message,
    String? error,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return UserManagementState(
      status: status ?? this.status,
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class UserManagementCubit extends Cubit<UserManagementState> {
  UserManagementCubit(this._userRepository) : super(const UserManagementState());

  final UserRepository _userRepository;

  Future<void> loadUsers([String? query]) async {
    emit(state.copyWith(
      status: UserManagementStatus.loading,
      clearError: true,
      clearMessage: true,
      searchQuery: query ?? state.searchQuery,
    ));

    final result = await _userRepository.getAllUsers(query ?? state.searchQuery);

    result.fold(
      (failure) => emit(state.copyWith(status: UserManagementStatus.error, error: failure.message)),
      (users) => emit(state.copyWith(status: UserManagementStatus.success, users: users)),
    );
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    emit(state.copyWith(status: UserManagementStatus.loading, clearError: true, clearMessage: true));

    final result = await _userRepository.updateUserRole(uid, newRole);

    result.fold(
      (failure) => emit(state.copyWith(status: UserManagementStatus.error, error: failure.message)),
      (message) {
        // Update local list
        final updatedUsers = state.users.map((u) {
          if (u.uid == uid) {
            // Need to return a modified user. Since AppUser might not have copyWith (only AppUserModel does),
            // We just fetch users again to ensure sync with backend, or modify it if possible.
            // Let's just reload users for simplicity and safety.
          }
          return u;
        }).toList();

        emit(state.copyWith(status: UserManagementStatus.success, message: message));
        loadUsers(); // refresh list
      },
    );
  }

  Future<void> deleteUser(String uid) async {
    emit(state.copyWith(status: UserManagementStatus.loading, clearError: true, clearMessage: true));

    final result = await _userRepository.deleteUser(uid);

    result.fold(
      (failure) => emit(state.copyWith(status: UserManagementStatus.error, error: failure.message)),
      (message) {
        emit(state.copyWith(status: UserManagementStatus.success, message: message));
        loadUsers(); // refresh list
      },
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));
  void clearMessage() => emit(state.copyWith(clearMessage: true));
}
