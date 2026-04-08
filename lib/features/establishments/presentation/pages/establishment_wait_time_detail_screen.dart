import 'dart:async';

import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:enhorario/features/establishments/presentation/bloc/establishment_wait_time_cubit.dart';
import 'package:enhorario/core/widgets/favorite_button.dart';
import 'package:enhorario/features/establishments/presentation/bloc/favorites_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EstablishmentWaitTimeDetailScreen extends StatefulWidget {
  const EstablishmentWaitTimeDetailScreen({
    super.key,
    required this.establishmentId,
  });

  final String establishmentId;

  @override
  State<EstablishmentWaitTimeDetailScreen> createState() =>
      _EstablishmentWaitTimeDetailScreenState();
}

class _EstablishmentWaitTimeDetailScreenState
    extends State<EstablishmentWaitTimeDetailScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!mounted) return;
      context.read<EstablishmentWaitTimeCubit>().refresh(widget.establishmentId);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  String _waitText({required bool isOpen, required int? minutes}) {
    if (!isOpen) return 'Establecimiento cerrado';
    if (minutes == null) return 'Tiempo de espera no disponible';
    if (minutes <= 0) return 'Poco tiempo de espera';
    return '~$minutes minutos';
  }

  String _updatedLabel(DateTime? dateTime) {
    if (dateTime == null) return 'Sin actualizacion';
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return 'Ultima actualizacion: $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EstablishmentWaitTimeCubit(
        RailwayEstablishmentQueryService(ApiClient()),
      )..load(widget.establishmentId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de espera'),
          actions: [
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                return FavoriteButton(
                  isFavorite: favState.isFavorite(widget.establishmentId),
                  onToggle: () {
                    context.read<FavoritesCubit>().toggleFavorite(widget.establishmentId);
                  },
                );
              },
            ),
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Recargar',
                  onPressed: () => context
                      .read<EstablishmentWaitTimeCubit>()
                      .refresh(widget.establishmentId),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<EstablishmentWaitTimeCubit, EstablishmentWaitTimeState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && state.item == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context
                            .read<EstablishmentWaitTimeCubit>()
                            .load(widget.establishmentId),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final item = state.item;
            if (item == null) {
              return const Center(
                child: Text('No hay informacion disponible.'),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context
                  .read<EstablishmentWaitTimeCubit>()
                  .refresh(widget.establishmentId),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(item.addressLine),
                  const SizedBox(height: 4),
                  Text(item.city),
                  const SizedBox(height: 8),
                  if (item.categoryName != null && item.categoryName!.isNotEmpty)
                    Text('Categoria: ${item.categoryName}'),
                  if (item.shortDescription != null &&
                      item.shortDescription!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(item.shortDescription!),
                    ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tiempo estimado de espera',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _waitText(
                              isOpen: item.isOpen,
                              minutes: item.averageWaitMinutes,
                            ),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(_updatedLabel(state.lastUpdated)),
                          if (state.isRefreshing) ...[
                            const SizedBox(height: 12),
                            const LinearProgressIndicator(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        state.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
