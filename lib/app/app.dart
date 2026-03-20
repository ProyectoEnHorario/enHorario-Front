import 'package:enhorario/app/theme/app_theme.dart';
import 'package:enhorario/features/home/data/repositories/in_memory_wait_point_repository.dart';
import 'package:enhorario/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

class EnHorarioApp extends StatelessWidget {
  const EnHorarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = InMemoryWaitPointRepository();

    return MaterialApp(
      title: 'EnHorario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: HomePage(repository: repository),
    );
  }
}
