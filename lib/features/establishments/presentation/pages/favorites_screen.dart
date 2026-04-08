import 'package:enhorario/core/widgets/favorite_button.dart';
import 'package:enhorario/features/establishments/presentation/bloc/favorites_cubit.dart';
import 'package:enhorario/features/establishments/presentation/bloc/real_establishments_cubit.dart';
import 'package:enhorario/features/establishments/presentation/pages/establishment_wait_time_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        return BlocBuilder<RealEstablishmentsCubit, RealEstablishmentsState>(
          builder: (context, estState) {
            if (estState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final favoriteItems = estState.items
                .where((item) => favState.isFavorite(item.id))
                .toList();

            if (favoriteItems.isEmpty) {
              return const Center(
                child: Text('Cero favoritos. ¡Empieza a descubrir lugares!'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = favoriteItems[index];

                // Extraemos colores de lógica (ej. afluencia)
                Color afluenciaColor = Colors.blueGrey;
                String afluenciaLabel = 'Cerrado';
                if (item.isOpen) {
                  final wait = item.averageWaitMinutes;
                  if (wait == null) {
                    afluenciaColor = Colors.amber;
                    afluenciaLabel = 'Afluencia desconocida';
                  } else if (wait <= 5) {
                    afluenciaColor = Colors.green;
                    afluenciaLabel = 'Afluencia baja';
                  } else if (wait <= 15) {
                    afluenciaColor = Colors.orange;
                    afluenciaLabel = 'Afluencia media';
                  } else {
                    afluenciaColor = Colors.red;
                    afluenciaLabel = 'Afluencia alta';
                  }
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EstablishmentWaitTimeDetailScreen(
                            establishmentId: item.id,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: afluenciaColor.withValues(alpha: 0.15),
                            ),
                            child: Icon(
                              Icons.storefront,
                              color: afluenciaColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.city} - $afluenciaLabel',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          FavoriteButton(
                            isFavorite: true,
                            onToggle: () {
                              context.read<FavoritesCubit>().toggleFavorite(item.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
