import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_entry_screen.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/data/repositories/user_location_service.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:enhorario/features/establishments/presentation/bloc/real_establishments_cubit.dart';
import 'package:enhorario/features/establishments/presentation/pages/establishment_wait_time_detail_screen.dart';
import 'package:enhorario/features/establishments/presentation/widgets/establishment_map_view.dart';
import 'package:enhorario/features/establishments/presentation/widgets/category_filter_section.dart';
import 'package:enhorario/features/establishments/presentation/widgets/establishment_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

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

class _RealAppHomeView extends StatefulWidget {
  const _RealAppHomeView();

  @override
  State<_RealAppHomeView> createState() => _RealAppHomeViewState();
}

class _RealAppHomeViewState extends State<_RealAppHomeView> {
  final UserLocationService _locationService = UserLocationService();

  bool _isLoadingLocation = true;
  bool _permissionDenied = false;
  String? _locationMessage;
  double? _userLatitude;
  double? _userLongitude;
  RailwayEstablishmentView? _selectedEstablishment;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  @override
  void dispose() {
    context.read<RealEstablishmentsCubit>().clearAllFilters();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationMessage = null;
    });

    final result = await _locationService.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = false;
      _permissionDenied = result.permissionDenied;
      _locationMessage = result.message;
      _userLatitude = result.position?.latitude;
      _userLongitude = result.position?.longitude;
    });
  }

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

  String _buildEmptyMessage(RealEstablishmentsState state) {
    final hasCategoryFilters = state.selectedCategoryKeys.isNotEmpty;
    final hasQuery = state.query.trim().isNotEmpty;

    if (hasCategoryFilters && !hasQuery) {
      return 'No hay establecimientos en esta categoría';
    }
    if (hasCategoryFilters || hasQuery) {
      return 'No hay resultados con los filtros aplicados';
    }
    return 'No hay establecimientos disponibles.';
  }

  LatLng get _mapCenter {
    final latitude = _userLatitude ?? UserLocationService.fallbackLatitude;
    final longitude = _userLongitude ?? UserLocationService.fallbackLongitude;
    return LatLng(latitude, longitude);
  }

  String _afluenciaLabel(RailwayEstablishmentView item) {
    if (!item.isOpen) return 'Cerrado';
    final wait = item.averageWaitMinutes;
    if (wait == null) return 'Afluencia desconocida';
    if (wait <= 5) return 'Afluencia baja';
    if (wait <= 15) return 'Afluencia media';
    return 'Afluencia alta';
  }

  Color _afluenciaColor(RailwayEstablishmentView item) {
    if (!item.isOpen) return Colors.blueGrey;
    final wait = item.averageWaitMinutes;
    if (wait == null) return Colors.amber;
    if (wait <= 5) return Colors.green;
    if (wait <= 15) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMarkerInfoCard(
    BuildContext context,
    RailwayEstablishmentView item,
  ) {
    final color = _afluenciaColor(item);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  EstablishmentWaitTimeDetailScreen(establishmentId: item.id),
            ),
          );
        },
        title: Text(item.name),
        subtitle: Text(
          '${item.categoryName ?? 'Sin categoria'}\n${_afluenciaLabel(item)}',
        ),
        isThreeLine: true,
        trailing: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
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

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
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
                          if (_isLoadingLocation)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh),
                            label: const Text('Recargar tiempos'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loadUserLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Actualizar mi ubicacion'),
                        ),
                      ),
                    ),
                    if (_locationMessage != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Material(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Icon(
                                  _permissionDenied
                                      ? Icons.location_off
                                      : Icons.info_outline,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _locationMessage!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Material(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.error!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context
                                      .read<RealEstablishmentsCubit>()
                                      .loadInitial(),
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: SizedBox(
                        height: 320,
                        width: double.infinity,
                        child: EstablishmentMapView(
                          establishments: state.filtered,
                          center: _mapCenter,
                          showUserLocation:
                              _userLatitude != null && _userLongitude != null,
                          selectedEstablishmentId: _selectedEstablishment?.id,
                          markerColorResolver: _afluenciaColor,
                          onMarkerTap: (item) {
                            setState(() {
                              _selectedEstablishment = item;
                            });
                          },
                        ),
                      ),
                    ),
                    if (_selectedEstablishment != null)
                      _buildMarkerInfoCard(context, _selectedEstablishment!),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: EstablishmentSearchField(
                        value: state.query,
                        onChanged: context
                            .read<RealEstablishmentsCubit>()
                            .setQuery,
                        onClear: context
                            .read<RealEstablishmentsCubit>()
                            .clearAllFilters,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: CategoryFilterSection(
                        options: state.availableCategories,
                        selectedKeys: state.selectedCategoryKeys.toSet(),
                        onToggleCategory: context
                            .read<RealEstablishmentsCubit>()
                            .toggleCategory,
                        onClearAll: context
                            .read<RealEstablishmentsCubit>()
                            .clearAllFilters,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _buildEmptyMessage(state),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = state.filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _selectedEstablishment = item;
                              });
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      EstablishmentWaitTimeDetailScreen(
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
                            trailing: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _afluenciaColor(item),
                              ),
                            ),
                          ),
                        ),
                      );
                    }, childCount: state.filtered.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
