import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_entry_screen.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:enhorario/features/establishments/presentation/bloc/real_establishments_cubit.dart';
import 'package:enhorario/features/establishments/presentation/pages/establishment_wait_time_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RealAppHomeScreen extends StatelessWidget {
  const RealAppHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RealEstablishmentsCubit(
        RailwayEstablishmentQueryService(ApiClient()),
      ),
      child: const _RealAppHomeView(),
    );
  }
}

class _RealAppHomeView extends StatelessWidget {
  const _RealAppHomeView();

  String _formatWaitLabel(int? minutes, bool isOpen) {
    if (!isOpen) {
      return 'Establecimiento cerrado';
    }
    if (minutes == null) {
      return 'Tiempo de espera no disponible';
    }
    if (minutes <= 0) {
      return 'Poco tiempo de espera';
    }
    return '~$minutes minutos';
  }

  String _formatLastUpdated(DateTime? dateTime) {
    if (dateTime == null) return 'Sin actualizacion';
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return 'Actualizado $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App real - Establecimientos'),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthSessionRepository().clearSession();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => const RealAppEntryScreen(),
                ),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesion',
          ),
        ],
      ),
      body: BlocBuilder<RealEstablishmentsCubit, RealEstablishmentsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.items.isEmpty) {
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
                          .read<RealEstablishmentsCubit>()
                          .loadInitial(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatLastUpdated(state.lastUpdated),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: state.isRefreshing
                          ? null
                          : () => context
                              .read<RealEstablishmentsCubit>()
                              .refreshTimes(),
                      icon: state.isRefreshing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: const Text('Recargar tiempos'),
                    ),
                  ],
                ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    state.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              Expanded(
                child: state.items.isEmpty
                    ? const Center(
                        child: Text('No hay establecimientos disponibles.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return Card(
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => EstablishmentWaitTimeDetailScreen(
                                      establishmentId: item.id,
                                    ),
                                  ),
                                );
                              },
                              title: Text(item.name),
                              subtitle: Text(
                                '${item.addressLine} - ${item.city}\n${_formatWaitLabel(item.averageWaitMinutes, item.isOpen)}',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
