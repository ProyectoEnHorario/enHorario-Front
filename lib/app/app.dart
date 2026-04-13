import 'package:enhorario/app/theme/app_theme.dart';
import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/navigation/navigation_service.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_favorites_repository.dart';
import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';
import 'package:enhorario/features/establishments/presentation/bloc/favorites_cubit.dart';
import 'package:enhorario/features/home/presentation/pages/home_screen.dart';
import 'package:enhorario/features/notifications/data/services/low_afluencia_service.dart';
import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';
import 'package:enhorario/features/notifications/presentation/bloc/notification_trigger_cubit.dart';
import 'package:enhorario/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        RepositoryProvider<RailwayEstablishmentQueryService>(
          create: (context) => RailwayEstablishmentQueryService(
            context.read<ApiClient>(),
          ),
        ),
        RepositoryProvider<LowAfluenciaService>(
          create: (context) => LowAfluenciaService(
            favoritesRepository: context.read<FavoritesRepository>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<FavoritesCubit>(
            create: (context) => FavoritesCubit(context.read<FavoritesRepository>()),
          ),
          BlocProvider<NotificationsCubit>(
            create: (context) => NotificationsCubit(context.read<NotificationRepository>()),
          ),
          BlocProvider<RealEstablishmentsCubit>(
            create: (context) => RealEstablishmentsCubit(
              context.read<RailwayEstablishmentQueryService>(),
            ),
          ),
          BlocProvider<NotificationTriggerCubit>(
            create: (context) => NotificationTriggerCubit(
              lowAfluenciaService: context.read<LowAfluenciaService>(),
              notificationRepository: context.read<NotificationRepository>(),
              notificationsCubit: context.read<NotificationsCubit>(),
            ),
          ),
        ],
        child: MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          title: 'EnHorario',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
