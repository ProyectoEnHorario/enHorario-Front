enum AppRole {
  superadmin,
  admin,
  adminLocal,
  user,
  unknown;

  /// Parsea un String del backend (ej. "SUPERADMIN") a AppRole.
  factory AppRole.fromString(String? roleStr) {
    switch (roleStr?.toUpperCase()) {
      case 'SUPERADMIN':
        return AppRole.superadmin;
      case 'ADMIN':
        return AppRole.admin;
      case 'ADMIN_LOCAL':
        return AppRole.adminLocal;
      case 'USER':
        return AppRole.user;
      default:
        return AppRole.unknown;
    }
  }

  /// Devuelve el nombre en el formato que el backend espera (Mayúsculas con guiones bajos).
  String toBackendString() {
    switch (this) {
      case AppRole.superadmin:
        return 'SUPERADMIN';
      case AppRole.admin:
        return 'ADMIN';
      case AppRole.adminLocal:
        return 'ADMIN_LOCAL';
      case AppRole.user:
        return 'USER';
      case AppRole.unknown:
        return 'USER'; // Default seguro
    }
  }

  /// Devuelve un nombre legible para el usuario final.
  String get displayName {
    switch (this) {
      case AppRole.superadmin:
        return 'Superadministrador';
      case AppRole.admin:
        return 'Administrador';
      case AppRole.adminLocal:
        return 'Administrador Local';
      case AppRole.user:
        return 'Usuario Normal';
      case AppRole.unknown:
        return 'Desconocido';
    }
  }
}

/// Matriz de permisos por rol (Basado en requerimientos del backend)
extension AppRolePermissions on AppRole {
  /// ¿Puede ver la gestión global de usuarios?
  bool get canManageUsers => this == AppRole.superadmin;

  /// ¿Puede crear otros administradores globales?
  bool get canCreateAdmin => this == AppRole.superadmin;

  /// ¿Puede crear administradores locales?
  bool get canCreateAdminLocal => this == AppRole.superadmin || this == AppRole.admin;

  /// ¿Puede gestionar un local específico?
  bool get canManageLocal => this == AppRole.adminLocal;

  /// ¿Puede ver y crear turnos? (Todos menos ADMIN/SUPERADMIN que son de gestión técnica)
  /// Nota: Basado en la matriz del backend, ADMIN/SUPERADMIN no crean turnos directamente.
  bool get canViewAndCreateTurns => this == AppRole.adminLocal || this == AppRole.user;
}
