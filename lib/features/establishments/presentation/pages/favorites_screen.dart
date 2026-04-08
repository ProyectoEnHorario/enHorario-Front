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

            if (estState.error != null && favoriteItems.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Ocurrió un error al cargar tus favoritos:\n${estState.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<RealEstablishmentsCubit>().refreshTimes();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (favoriteItems.isEmpty && !estState.isLoading) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aún no tienes favoritos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explora el mapa y pulsa el corazón para guardar los establecimientos que más te gusten.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
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
