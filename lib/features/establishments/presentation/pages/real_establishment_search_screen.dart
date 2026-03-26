import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:enhorario/features/establishments/presentation/bloc/real_establishments_cubit.dart';
import 'package:enhorario/features/establishments/presentation/pages/establishment_wait_time_detail_screen.dart';
import 'package:enhorario/features/establishments/presentation/widgets/establishment_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RealEstablishmentSearchScreen extends StatelessWidget {
  const RealEstablishmentSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RealEstablishmentsCubit(
        RailwayEstablishmentQueryService(ApiClient()),
      ),
      child: const _RealEstablishmentSearchView(),
    );
  }
}

class _RealEstablishmentSearchView extends StatelessWidget {
  const _RealEstablishmentSearchView();

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
            child:
                BlocBuilder<RealEstablishmentsCubit, RealEstablishmentsState>(
                  builder: (context, state) => EstablishmentSearchField(
                    value: state.query,
                    onChanged: context.read<RealEstablishmentsCubit>().setQuery,
                    onClear: () =>
                        context.read<RealEstablishmentsCubit>().setQuery(''),
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
                            onPressed: context
                                .read<RealEstablishmentsCubit>()
                                .load,
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
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.city} - ${item.addressLine}'),
                      trailing: Text(
                        item.averageWaitMinutes == null
                            ? 'N/D'
                            : '~${item.averageWaitMinutes} min',
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => EstablishmentWaitTimeDetailScreen(
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
