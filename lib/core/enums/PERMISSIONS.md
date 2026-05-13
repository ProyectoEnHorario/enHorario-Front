# Matriz de Permisos por Rol (RBAC) - EnHorario

Este documento detalla la estructura de permisos implementada en la aplicación Flutter mediante el enum `AppRole`.

## Roles Disponibles

| Rol | Identificador API | Descripción |
| :--- | :--- | :--- |
| **Superadministrador** | `SUPERADMIN` | Control total sobre la plataforma y gestión de usuarios. |
| **Administrador** | `ADMIN` | Gestión operativa y creación de administradores locales. |
| **Administrador Local** | `ADMIN_LOCAL` | Gestión de un establecimiento específico y sus turnos. |
| **Usuario** | `USER` | Cliente final que consume servicios y solicita turnos. |

## Matriz de Permisos (`AppRolePermissions`)

| Permiso | Propiedad en Código | SUPERADMIN | ADMIN | ADMIN_LOCAL | USER |
| :--- | :--- | :---: | :---: | :---: | :---: |
| Gestionar Usuarios Globales | `canManageUsers` | ✅ | ❌ | ❌ | ❌ |
| Crear Administradores | `canCreateAdmin` | ✅ | ❌ | ❌ | ❌ |
| Crear Admins Locales | `canCreateAdminLocal` | ✅ | ✅ | ❌ | ❌ |
| Gestionar Local Propio | `canManageLocal` | ❌ | ❌ | ✅ | ❌ |
| Ver y Crear Turnos | `canViewAndCreateTurns` | ❌ | ❌ | ✅ | ✅ |

## Implementación Técnica

### 1. Enum `AppRole`
Ubicación: `lib/core/enums/app_role.dart`
Centraliza la lógica de conversión desde el backend y define los permisos mediante una extensión.

### 2. Route Guards
Ubicación: `lib/core/navigation/role_guard.dart`
Widget que envuelve pantallas protegidas. Si el usuario no cumple con el `requirement` (ej. `role.canManageUsers`), es redirigido automáticamente a la `AccessDeniedScreen`.

### 3. Navegación Dinámica
Ubicación: `lib/features/home/presentation/pages/main_navigation_screen.dart`
Las pestañas del `NavigationBar` inferior se filtran en tiempo real basándose en la matriz de permisos del usuario logueado.
