import 'package:enhorario/features/auth/data/models/app_user_model.dart';
import 'package:enhorario/features/auth/domain/entities/app_user.dart';
import 'package:enhorario/features/auth/domain/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileState {
  const UserProfileState({
    this.user,
    this.isLoading = false,
    this.isEditing = false,
    this.error,
  });

  final AppUser? user;
  final bool isLoading;
  final bool isEditing;
  final String? error;

  UserProfileState copyWith({
    AppUser? user,
    bool? isLoading,
    bool? isEditing,
    String? error,
    bool clearError = false,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit(this._userRepository) : super(const UserProfileState());

  final UserRepository _userRepository;

  Future<void> loadProfile() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _userRepository.getUserProfile();

    result.fold(
      (failure) {
        // Si hay error en la carga pero ya teníamos usuario, mantenemos el anterior
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (user) => emit(state.copyWith(isLoading: false, user: user)),
    );
  }

  void startEditing() {
    emit(state.copyWith(isEditing: true, clearError: true));
  }

  void cancelEditing() {
    emit(state.copyWith(isEditing: false, clearError: true));
  }

  Future<void> updateProfile({
    required String nombre,
    required String apellido,
    String? telefono,
  }) async {
    if (state.user == null) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _userRepository.updateProfile(
      name: nombre,
      lastName: apellido,
      phone: telefono,
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (user) => emit(state.copyWith(
        isLoading: false,
        isEditing: false,
        user: user,
      )),
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));
}
