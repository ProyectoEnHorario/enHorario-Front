import 'package:enhorario/app/theme/app_theme.dart';
import 'package:enhorario/features/establishments/data/repositories/local_favorites_repository.dart';
import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';
import 'package:enhorario/features/establishments/presentation/bloc/favorites_cubit.dart';
import 'package:enhorario/features/home/presentation/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnHorarioApp extends StatelessWidget {
  const EnHorarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<FavoritesRepository>(
      create: (_) => LocalFavoritesRepository(),
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
