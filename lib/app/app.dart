import 'package:enhorario/features/establishments/data/repositories/railway_favorites_repository.dart';
import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';
import 'package:enhorario/features/establishments/presentation/bloc/favorites_cubit.dart';
import 'package:enhorario/features/home/presentation/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enhorario/app/theme/app_theme.dart';
import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';

class EnHorarioApp extends StatelessWidget {
  const EnHorarioApp({
    required this.notificationRepository,
    super.key,
  });

  final NotificationRepository notificationRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>(
          create: (_) => ApiClient(),
        ),
        RepositoryProvider<NotificationRepository>.value(
          value: notificationRepository,
        ),
        RepositoryProvider<FavoritesRepository>(
          create: (context) => RailwayFavoritesRepository(
            context.read<ApiClient>(),
          ),
        ),
      ],
      child: BlocProvider<FavoritesCubit>(
        create: (context) => FavoritesCubit(context.read<FavoritesRepository>()),
        child: MaterialApp(
          title: 'EnHorario',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
