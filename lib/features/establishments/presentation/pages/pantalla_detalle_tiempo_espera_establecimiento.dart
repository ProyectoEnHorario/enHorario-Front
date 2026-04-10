import 'dart:async';
import 'package:enhorario/core/widgets/indicador_afluencia.dart';

import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:enhorario/features/establishments/presentation/bloc/favorites_cubit.dart';
import 'package:enhorario/core/widgets/favorite_button.dart';
import 'package:enhorario/features/establishments/presentation/bloc/establishment_wait_time_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PantallaDetalleTiempoEsperaEstablecimiento extends StatefulWidget {
  const PantallaDetalleTiempoEsperaEstablecimiento({
    super.key,
    required this.establishmentId,
  });

  final String establishmentId;

  @override
  State<PantallaDetalleTiempoEsperaEstablecimiento> createState() =>
      _PantallaDetalleTiempoEsperaEstablecimientoState();
}

class _PantallaDetalleTiempoEsperaEstablecimientoState
    extends State<PantallaDetalleTiempoEsperaEstablecimiento> {
  Timer? _autoRefreshTimer;

  // Máximo de minutos que consideramos 100% de afluencia
  static const int _minutosMaximosEspera = 15;

  // Convierte averageWaitMinutes a valor 0.0 - 1.0 para IndicadorAfluencia
  double? _calcularValorAfluencia({required int? minutes}) {
    if (minutes == null) return null;
    return (minutes / _minutosMaximosEspera).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!mounted) return;
      context
          .read<EstablishmentWaitTimeCubit>()
          .refresh(widget.establishmentId);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  String _updatedLabel(DateTime? dateTime) {
    if (dateTime == null) return 'Sin actualización';
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return 'Última actualización: $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EstablishmentWaitTimeCubit(
        RailwayEstablishmentQueryService(ApiClient()),
      )..load(widget.establishmentId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del establecimiento'),
          actions: [
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                return FavoriteButton(
                  isFavorite: state.isFavorite(widget.establishmentId),
                  onToggle: (value) {
                    context
                        .read<FavoritesCubit>()
                        .toggleFavorite(widget.establishmentId);
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

            // ── Cargando por primera vez ──────────────────────────
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // ── Error sin datos previos ───────────────────────────
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
                child: Text('No hay información disponible.'),
              );
            }

            // Calculamos el valor de afluencia con datos reales
            final valorAfluencia = _calcularValorAfluencia(
              minutes: item.averageWaitMinutes,
            );

            return RefreshIndicator(
              onRefresh: () => context
                  .read<EstablishmentWaitTimeCubit>()
                  .refresh(widget.establishmentId),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // ── Nombre y ubicación ──────────────────────────
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.addressLine,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    item.city,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (item.categoryName != null &&
                      item.categoryName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Categoría: ${item.categoryName}'),
                  ],
                  if (item.shortDescription != null &&
                      item.shortDescription!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(item.shortDescription!),
                  ],

                  const SizedBox(height: 24),

                  // ── Chip de estado abierto/cerrado ──────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.isOpen
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: item.isOpen
                                ? Colors.green.withValues(alpha: 0.4)
                                : Colors.red.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          item.isOpen ? 'Abierto' : 'Cerrado',
                          style: TextStyle(
                            color: item.isOpen ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Sección de afluencia con tu widget ──────────
                  Text(
                    'Afluencia actual',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ← AQUÍ se usa tu IndicadorAfluencia con datos reales
                  IndicadorAfluencia(
                    valor: valorAfluencia,
                    abierto: item.isOpen,
                  ),

                  const SizedBox(height: 6),
                  Text(
                    item.isOpen
                        ? (item.averageWaitMinutes != null
                        ? 'Tiempo estimado de espera: ~${item.averageWaitMinutes} min'
                        : 'Tiempo de espera no disponible')
                        : 'Establecimiento cerrado',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 6),
                  Text(
                    _updatedLabel(state.lastUpdated),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),

                  // Barra de progreso de refresco automático
                  if (state.isRefreshing) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],

                  // Error secundario (ya hay datos, pero falló el refresh)
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}