import 'dart:async';

import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:enhorario/features/establishments/data/repositories/user_location_service.dart';
import 'package:enhorario/features/establishments/presentation/bloc/real_establishments_cubit.dart';
import 'package:enhorario/features/establishments/presentation/pages/establishment_wait_time_detail_screen.dart';
import 'package:enhorario/features/establishments/presentation/widgets/establishment_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final Distance _distance = const Distance();

  bool _permissionDenied = false;
  String? _locationMessage;
  bool _followMyLocation = false;
  bool _showOnlyNearby = false;
  double _nearbyRadiusKm = 5;
  String _mapQuery = '';

  double? _userLatitude;
  double? _userLongitude;
  LatLng? _mapFocus;
  int _centerChangeToken = 0;
  RailwayEstablishmentView? _selectedEstablishment;
  StreamSubscription<Position>? _positionSubscription;
  final List<LatLng> _userTrail = <LatLng>[];

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    setState(() {
      _locationMessage = null;
    });

    final result = await _locationService.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _permissionDenied = result.permissionDenied;
      _locationMessage = result.message;
      _userLatitude = result.position?.latitude;
      _userLongitude = result.position?.longitude;
      if (result.position != null && (_followMyLocation || _mapFocus == null)) {
        _mapFocus = LatLng(
          result.position!.latitude,
          result.position!.longitude,
        );
      }
    });

    if (result.position != null) {
      _startTracking();
    }
  }

  void _startTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = _locationService.watchPositionStream().listen((
      position,
    ) {
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
        _userTrail.add(point);
        if (_userTrail.length > 40) {
          _userTrail.removeAt(0);
        }
        if (_followMyLocation) {
          _mapFocus = point;
          _centerChangeToken++;
        }
      });
    });
  }

  LatLng get _mapCenter {
    if (_mapFocus != null) {
      return _mapFocus!;
    }
    final latitude = _userLatitude ?? UserLocationService.fallbackLatitude;
    final longitude = _userLongitude ?? UserLocationService.fallbackLongitude;
    return LatLng(latitude, longitude);
  }

  double _distanceKmFromCenter(RailwayEstablishmentView item, LatLng center) {
    if (!item.hasValidCoordinates) return double.infinity;
    return _distance.as(
      LengthUnit.Kilometer,
      center,
      LatLng(item.latitude!, item.longitude!),
    );
  }

  List<RailwayEstablishmentView> _visibleItems(RealEstablishmentsState state) {
    final center = _mapCenter;
    final q = _mapQuery.trim().toLowerCase();

    return state.items.where((item) {
      if (!item.hasValidCoordinates) return false;

      if (q.isNotEmpty) {
        final haystack = '${item.name} ${item.categoryName ?? ''} ${item.city}'
            .toLowerCase();
        if (!haystack.contains(q)) return false;
      }

      if (_showOnlyNearby) {
        return _distanceKmFromCenter(item, center) <= _nearbyRadiusKm;
      }
      return true;
    }).toList();
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
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  EstablishmentWaitTimeDetailScreen(establishmentId: item.id),
            ),
          );
          if (!mounted) return;
          setState(() {
            _selectedEstablishment = null;
          });
        },
        title: Text(item.name),
        subtitle: Text(
          '${item.categoryName ?? 'Sin categoria'}\n${_afluenciaLabel(item)}\n${_distanceKmFromCenter(item, _mapCenter).toStringAsFixed(2)} km',
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

  Future<void> _openNearbyPanel(
    BuildContext context,
    List<RailwayEstablishmentView> visible,
  ) async {
    final sortedVisible = [...visible]
      ..sort(
        (a, b) => _distanceKmFromCenter(
          a,
          _mapCenter,
        ).compareTo(_distanceKmFromCenter(b, _mapCenter)),
      );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.45,
              minChildSize: 0.25,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Establecimientos cercanos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _showOnlyNearby,
                          title: const Text('Filtrar por radio'),
                          subtitle: Text(
                            _showOnlyNearby
                                ? 'Mostrando solo cercanos'
                                : 'Mostrando todos en el mapa',
                          ),
                          onChanged: (value) {
                            setState(() => _showOnlyNearby = value);
                            setSheetState(() {});
                          },
                        ),
                        Text('Radio: ${_nearbyRadiusKm.toStringAsFixed(1)} km'),
                        Slider(
                          value: _nearbyRadiusKm,
                          min: 0.5,
                          max: 30,
                          divisions: 59,
                          label: '${_nearbyRadiusKm.toStringAsFixed(1)} km',
                          onChanged: (value) {
                            setState(() => _nearbyRadiusKm = value);
                            setSheetState(() {});
                          },
                        ),
                        const SizedBox(height: 4),
                        Text('Locales visibles ahora: ${visible.length}'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: sortedVisible.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay locales con el filtro actual.',
                                  ),
                                )
                              : ListView.separated(
                                  controller: scrollController,
                                  itemCount: sortedVisible.length,
                                    separatorBuilder: (_, index) =>
                                      const SizedBox(height: 6),
                                  itemBuilder: (context, index) {
                                    final item = sortedVisible[index];
                                    final distance = _distanceKmFromCenter(
                                      item,
                                      _mapCenter,
                                    );
                                    final afluencia = _afluenciaLabel(item);

                                    return Card(
                                      elevation: 0,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                        leading: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _afluenciaColor(
                                              item,
                                            ).withValues(alpha: 0.18),
                                          ),
                                          child: Icon(
                                            Icons.store_mall_directory,
                                            color: _afluenciaColor(item),
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(item.name),
                                        subtitle: Text(
                                          '${item.city} - ${distance.toStringAsFixed(2)} km\n$afluencia',
                                        ),
                                        isThreeLine: true,
                                        trailing: const Icon(
                                          Icons.chevron_right,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedEstablishment = item;
                                            _mapFocus = LatLng(
                                              item.latitude!,
                                              item.longitude!,
                                            );
                                            _centerChangeToken++;
                                          });
                                          Navigator.pop(sheetContext);
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
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

  Future<void> _openSearchSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  _mapQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar establecimientos',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _mapQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _mapQuery = '';
                          });
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<RealEstablishmentsCubit, RealEstablishmentsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final visibleItems = _visibleItems(state);
          final userPosition = (_userLatitude != null && _userLongitude != null)
              ? LatLng(_userLatitude!, _userLongitude!)
              : null;

          return Stack(
            fit: StackFit.expand,
            children: [
              EstablishmentMapView(
                establishments: visibleItems,
                center: _mapCenter,
                autoRecenter: _followMyLocation,
                centerChangeToken: _centerChangeToken,
                onUserGesture: () {
                  if (!_followMyLocation) return;
                  setState(() {
                    _followMyLocation = false;
                  });
                },
                onMapTap: () {
                  FocusScope.of(context).unfocus();
                },
                userPosition: userPosition,
                userTrail: _userTrail,
                nearbyRadiusKm: _showOnlyNearby ? _nearbyRadiusKm : null,
                selectedEstablishmentId: _selectedEstablishment?.id,
                markerColorResolver: _afluenciaColor,
                onMarkerTap: (item) {
                  setState(() {
                    _selectedEstablishment = item;
                  });
                },
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _openSearchSheet,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _mapQuery.isEmpty
                                    ? 'Buscar establecimientos sobre el mapa'
                                    : _mapQuery,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.tune, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 90,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'btn-refresh',
                      onPressed: state.isRefreshing
                          ? null
                          : () => context
                                .read<RealEstablishmentsCubit>()
                                .refreshTimes(),
                      child: state.isRefreshing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'btn-follow',
                      onPressed: () {
                        setState(() {
                          _followMyLocation = !_followMyLocation;
                          if (_followMyLocation &&
                              _userLatitude != null &&
                              _userLongitude != null) {
                            _mapFocus = LatLng(_userLatitude!, _userLongitude!);
                            _centerChangeToken++;
                          }
                        });
                      },
                      child: Icon(
                        _followMyLocation
                            ? Icons.navigation
                            : Icons.navigation_outlined,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'btn-nearby',
                      onPressed: () => _openNearbyPanel(context, visibleItems),
                      child: const Icon(Icons.radar),
                    ),
                  ],
                ),
              ),
              if (_locationMessage != null)
                Positioned(
                  left: 12,
                  right: 70,
                  top: 82,
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    color: _permissionDenied
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _permissionDenied
                                ? Icons.location_off
                                : Icons.my_location,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _locationMessage!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (state.error != null)
                Positioned(
                  left: 12,
                  right: 12,
                  top: 140,
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 12,
                bottom: 18,
                child: FilledButton.icon(
                  onPressed: () => _openNearbyPanel(context, visibleItems),
                  icon: const Icon(Icons.place),
                  label: Text('Cercanos (${visibleItems.length})'),
                ),
              ),
              if (_selectedEstablishment != null)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 78,
                  child: _buildMarkerInfoCard(context, _selectedEstablishment!),
                ),
            ],
          );
        },
      ),
    );
  }
}
