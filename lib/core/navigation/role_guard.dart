import 'package:enhorario/core/enums/app_role.dart';
import 'package:enhorario/core/presentation/pages/access_denied_screen.dart';
import 'package:enhorario/features/auth/presentation/bloc/user_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoleGuard extends StatelessWidget {
  /// El widget que se mostrará si el usuario tiene permiso.
  final Widget child;

  /// Función que valida si el rol actual tiene permiso para ver el [child].
  final bool Function(AppRole role) requirement;

  const RoleGuard({
    super.key,
    required this.child,
    required this.requirement,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, state) {
        final user = state.user;

        // Si aún está cargando el perfil, mostramos un loader
        if (state.isLoading || user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Validamos el permiso usando la función de requerimiento
        if (requirement(user.rol)) {
          return child;
        }

        // Si no tiene permiso, mostramos la pantalla de acceso denegado
        return const AccessDeniedScreen();
      },
    );
  }
}
