import 'dart:async';

import 'package:enhorario/core/utils/afluencia_utils.dart';
import 'package:enhorario/core/widgets/favorite_button.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/data/repositories/user_location_service.dart';
import 'package:enhorario/features/establishments/presentation/bloc/favorites_cubit.dart';
import 'package:enhorario/features/establishments/presentation/bloc/real_establishments_cubit.dart';
import 'package:enhorario/features/establishments/presentation/pages/pantalla_detalle_tiempo_espera_establecimiento.dart';
import 'package:enhorario/features/establishments/presentation/widgets/establishment_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class PantallaInicioAppReal extends StatelessWidget {
  const PantallaInicioAppReal({super.key});

  @override
  Widget build(BuildContext context) {
    // La inyección de RealEstablishmentsCubit y FavoritesCubit ya se realiza en MainNavigationScreen
    return const _VistaInicioAppReal();
  }
}

class _VistaInicioAppReal extends StatefulWidget {
  const _VistaInicioAppReal();

  @override
  State<_VistaInicioAppReal> createState() => _VistaInicioAppRealState();
}

class _VistaInicioAppRealState extends State<_VistaInicioAppReal> {
  final UserLocationService _locationService = UserLocationService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Distance _distance = const Distance();

  bool _permissionDenied = false;
  String? _locationMessage;
  bool _followMyLocation = false;
  double _nearbyRadiusKm = 5;
  String _mapQuery = '';
  String? _selectedCategory;

  double? _userLatitude;
  double? _userLongitude;
  LatLng? _mapFocus;
  int _centerChangeToken = 0;
  int _zoomChangeToken = 0;
  static const double _recenterZoomLevel = 16.5;
  RailwayEstablishmentView? _selectedEstablishment;
  StreamSubscription<Position>? _positionSubscription;
  final List<LatLng> _userTrail = <LatLng>[];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _loadUserLocation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (!mounted) return;
    setState(() {});
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

  LatLng get _distanceReferenceCenter {
    if (_userLatitude != null && _userLongitude != null) {
      return LatLng(_userLatitude!, _userLongitude!);
    }
    return _mapCenter;
  }

  double _distanceKmFromCenter(RailwayEstablishmentView item, LatLng center) {
    if (!item.hasValidCoordinates) return double.infinity;
    return _distance.as(
      LengthUnit.Kilometer,
      center,
      LatLng(item.latitude!, item.longitude!),
    );
  }

  List<RailwayEstablishmentView> _visibleItemsFromList(
    List<RailwayEstablishmentView> items,
  ) {
    final center = _distanceReferenceCenter;
    final q = _mapQuery.trim().toLowerCase();

    return items.where((item) {
      if (!item.hasValidCoordinates) return false;

      if (_selectedCategory != null && item.categoryName != _selectedCategory) {
        return false;
      }

      if (q.isNotEmpty) {
        final haystack = '${item.name} ${item.categoryName ?? ''} ${item.city}'
            .toLowerCase();
        if (!haystack.contains(q)) return false;
      }

      return _distanceKmFromCenter(item, center) <= _nearbyRadiusKm;
    }).toList();
  }

  List<RailwayEstablishmentView> _visibleItems(RealEstablishmentsState state) {
    return _visibleItemsFromList(state.items);
  }

  String _afluenciaLabel(RailwayEstablishmentView item) {
    return AfluenciaUtils.getLabel(
      isOpen: item.isOpen,
      waitMinutes: item.averageWaitMinutes,
    );
  }

  Color _afluenciaColor(RailwayEstablishmentView item) {
    return AfluenciaUtils.getColor(
      isOpen: item.isOpen,
      waitMinutes: item.averageWaitMinutes,
    );
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
                  PantallaDetalleTiempoEsperaEstablecimiento(establishmentId: item.id),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                return FavoriteButton(
                  isFavorite: favState.isFavorite(item.id),
                  onToggle: (value) {
                    context.read<FavoritesCubit>().toggleFavorite(item.id);
                  },
                );
              },
            ),
            const SizedBox(width: 8),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNearbyPanel(
    BuildContext context,
    List<RailwayEstablishmentView> sourceItems,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final visibleNow = _visibleItemsFromList(sourceItems);
            final sortedVisible = [...visibleNow]
              ..sort(
                (a, b) => _distanceKmFromCenter(
                  a,
                  _distanceReferenceCenter,
                ).compareTo(_distanceKmFromCenter(b, _distanceReferenceCenter)),
              );

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Establecimientos cercanos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
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
                    Text('Locales visibles ahora: ${visibleNow.length}'),
                    const SizedBox(height: 8),
                    Expanded(
                      child: sortedVisible.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay locales con el filtro actual.',
                              ),
                            )
                          : ListView.separated(
                              itemCount: sortedVisible.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final item = sortedVisible[index];
                                final distance = _distanceKmFromCenter(
                                  item,
                                  _distanceReferenceCenter,
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
                                    contentPadding: const EdgeInsets.symmetric(
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
                                    trailing: const Icon(Icons.chevron_right),
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
  }

  void _focusEstablishment(RailwayEstablishmentView item) {
    setState(() {
      _followMyLocation = false;
      _selectedEstablishment = item;
      _mapFocus = LatLng(item.latitude!, item.longitude!);
      _centerChangeToken++;
    });
    FocusScope.of(context).unfocus();
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
          final categories = state.items
              .map((item) => item.categoryName)
              .whereType<String>()
              .map((c) => c.trim())
              .where((c) => c.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          return Stack(
            fit: StackFit.expand,
            children: [
              BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, favState) {
                  return EstablishmentMapView(
                    establishments: visibleItems,
                    center: _mapCenter,
                    autoRecenter: _followMyLocation,
                    centerChangeToken: _centerChangeToken,
                    onUserGesture: () {
                      FocusScope.of(context).unfocus();
                      if (_followMyLocation) {
                        setState(() {
                          _followMyLocation = false;
                        });
                      }
                    },
                    onMapTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    userPosition: userPosition,
                    userTrail: _userTrail,
                    nearbyRadiusKm: _nearbyRadiusKm,
                    selectedEstablishmentId: _selectedEstablishment?.id,
                    zoomChangeToken: _zoomChangeToken,
                    targetZoomOnToken: _recenterZoomLevel,
                    markerColorResolver: _afluenciaColor,
                    favoriteIds: favState.favoriteIds,
                    onMarkerTap: (item) {
                      setState(() {
                        _followMyLocation = false;
                        _selectedEstablishment = item;
                      });
                    },
                  );
                },
              ),
              Positioned(
                left: 12,
                right: 12,
                top: 10,
                child: SafeArea(
                  bottom: false,
                  child: TextFieldTapRegion(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      onChanged: (value) {
                        setState(() {
                          _mapQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar establecimientos sobre el mapa',
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
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.96),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_mapQuery.trim().isNotEmpty && _searchFocusNode.hasFocus)
                Positioned(
                  left: 12,
                  right: 12,
                  top: 116,
                  child: TextFieldTapRegion(
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(14),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 260),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: visibleItems.length > 6
                              ? 6
                              : visibleItems.length,
                          separatorBuilder: (_, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = visibleItems[index];
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.location_on,
                                color: _afluenciaColor(item),
                              ),
                              title: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(item.city),
                              onTap: () => _focusEstablishment(item),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                right: 72,
                top: 72,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Todas'),
                          selected: _selectedCategory == null,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                        ),
                        ...categories.map(
                          (category) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
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
                        if (_userLatitude == null || _userLongitude == null) {
                          return;
                        }
                        setState(() {
                          _followMyLocation = true;
                          _selectedEstablishment = null;
                          _mapFocus = LatLng(_userLatitude!, _userLongitude!);
                          _centerChangeToken++;
                          _zoomChangeToken++;
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
                  top: 130,
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
                  top: 188,
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
