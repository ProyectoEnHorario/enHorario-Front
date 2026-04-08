import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:enhorario/features/establishments/presentation/bloc/real_establishments_cubit.dart';
import 'package:enhorario/features/establishments/presentation/pages/pantalla_detalle_tiempo_espera_establecimiento.dart';
import 'package:enhorario/core/widgets/indicador_afluencia.dart';
import 'package:enhorario/features/establishments/presentation/widgets/establishment_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PantallaBusquedaEstablecimientoReal extends StatelessWidget {
  const PantallaBusquedaEstablecimientoReal({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RealEstablishmentsCubit(
        RailwayEstablishmentQueryService(ApiClient()),
      ),
      child: const _VistaBusquedaEstablecimientoReal(),
    );
  }
}

class _VistaBusquedaEstablecimientoReal extends StatelessWidget {
  const _VistaBusquedaEstablecimientoReal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App real - Establecimientos'),
        actions: [
          IconButton(
            tooltip: 'Recargar tiempos',
            onPressed: () => context.read<RealEstablishmentsCubit>().load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: BlocBuilder<RealEstablishmentsCubit, RealEstablishmentsState>(
              builder: (context, state) => EstablishmentSearchField(
                value: state.query,
                onChanged: context.read<RealEstablishmentsCubit>().setQuery,
                onClear: () => context.read<RealEstablishmentsCubit>().setQuery(''),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<RealEstablishmentsCubit, RealEstablishmentsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: context.read<RealEstablishmentsCubit>().load,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.filtered.isEmpty) {
                  final hasSearch = state.query.trim().isNotEmpty;
                  return Center(
                    child: Text(
                      hasSearch
                          ? 'No se encontraron establecimientos con ese nombre'
                          : 'No hay establecimientos para mostrar',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = state.filtered[index];
                    final minutosMaximosEspera = 15.0;
                    final double? valorAfluencia = (item.averageWaitMinutes == null)
                        ? null
                        : (item.averageWaitMinutes! / minutosMaximosEspera).clamp(0.0, 1.0);

                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.city} - ${item.addressLine}'),
                      trailing: SizedBox(
                        width: 140,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.averageWaitMinutes == null
                                  ? 'T. espera N/D'
                                  : '~${item.averageWaitMinutes} min',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            IndicadorAfluencia(
                              valor: valorAfluencia,
                              abierto: item.isOpen,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PantallaDetalleTiempoEsperaEstablecimiento(
                              establishmentId: item.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
