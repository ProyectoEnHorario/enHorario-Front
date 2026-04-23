import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:enhorario/app/app.dart';
import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';

import 'package:enhorario/features/notifications/domain/entities/notification_status.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  testWidgets('Muestra contenido base de home', (WidgetTester tester) async {
    final mockRepo = MockNotificationRepository();

    when(() => mockRepo.requestStatus())
        .thenAnswer((_) async => NotificationStatus.granted);
    when(() => mockRepo.getStatus())
        .thenAnswer((_) async => NotificationStatus.granted);

    await tester.pumpWidget(EnHorarioApp(notificationRepository: mockRepo));
    await tester.pumpAndSettle();

    expect(find.text('EnHorario - Inicio'), findsOneWidget);
    expect(find.text('Selecciona un modo'), findsOneWidget);
    expect(find.text('App real'), findsOneWidget);
  });
}
