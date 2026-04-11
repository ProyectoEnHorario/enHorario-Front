import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:enhorario/app/app.dart';
import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  testWidgets('Muestra contenido base de home', (WidgetTester tester) async {
    final mockRepo = MockNotificationRepository();

    await tester.pumpWidget(EnHorarioApp(notificationRepository: mockRepo));
    await tester.pumpAndSettle();

    expect(find.text('EnHorario'), findsOneWidget);
    expect(find.text('Estado de afluencia'), findsOneWidget);
    expect(find.text('Banco Central - Sucursal Norte'), findsOneWidget);
  });
}
