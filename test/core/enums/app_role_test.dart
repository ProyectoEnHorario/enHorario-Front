import 'package:enhorario/core/enums/app_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRole Permissions Matrix Tests', () {
    test('SUPERADMIN should have all permissions', () {
      const role = AppRole.superadmin;
      expect(role.canManageUsers, isTrue);
      expect(role.canCreateAdmin, isTrue);
      expect(role.canCreateAdminLocal, isTrue);
      expect(role.canManageLocal, isFalse); // Local management is usually for AdminLocal
      expect(role.canViewAndCreateTurns, isFalse); // Tickets are usually for users/local admins
    });

    test('ADMIN should have specific administrative permissions', () {
      const role = AppRole.admin;
      expect(role.canManageUsers, isFalse);
      expect(role.canCreateAdmin, isFalse);
      expect(role.canCreateAdminLocal, isTrue);
      expect(role.canManageLocal, isFalse);
    });

    test('ADMIN_LOCAL should manage their local and turns', () {
      const role = AppRole.adminLocal;
      expect(role.canManageUsers, isFalse);
      expect(role.canManageLocal, isTrue);
      expect(role.canViewAndCreateTurns, isTrue);
    });

    test('USER should only have turn permissions', () {
      const role = AppRole.user;
      expect(role.canManageUsers, isFalse);
      expect(role.canManageLocal, isFalse);
      expect(role.canViewAndCreateTurns, isTrue);
    });

    test('fromString should handle all backend strings correctly', () {
      expect(AppRole.fromString('SUPERADMIN'), AppRole.superadmin);
      expect(AppRole.fromString('ADMIN'), AppRole.admin);
      expect(AppRole.fromString('ADMIN_LOCAL'), AppRole.adminLocal);
      expect(AppRole.fromString('USER'), AppRole.user);
      expect(AppRole.fromString('UNKNOWN_ROLE'), AppRole.unknown);
      expect(AppRole.fromString(null), AppRole.unknown);
    });
  });
}
