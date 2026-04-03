import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EstablishmentMapView extends StatefulWidget {
  const EstablishmentMapView({
    super.key,
    required this.establishments,
    required this.center,
    required this.onMarkerTap,
    required this.markerColorResolver,
    this.autoRecenter = false,
    this.centerChangeToken = 0,
    this.onUserGesture,
    this.userPosition,
    this.userTrail = const [],
    this.nearbyRadiusKm,
    this.selectedEstablishmentId,
  });

  final List<RailwayEstablishmentView> establishments;
  final LatLng center;
  final ValueChanged<RailwayEstablishmentView> onMarkerTap;
  final Color Function(RailwayEstablishmentView item) markerColorResolver;
  final bool autoRecenter;
  final int centerChangeToken;
  final VoidCallback? onUserGesture;
  final LatLng? userPosition;
  final List<LatLng> userTrail;
  final double? nearbyRadiusKm;
  final String? selectedEstablishmentId;

  @override
  State<EstablishmentMapView> createState() => _EstablishmentMapViewState();
}

class _EstablishmentMapViewState extends State<EstablishmentMapView> {
  static const int _maxMarkers = 120;

  final MapController _mapController = MapController();
  final Distance _distance = const Distance();
  bool _mapReady = false;
  double _lastZoom = 14;

  void _moveToCenter() {
    try {
      _mapController.move(widget.center, _lastZoom);
    } catch (_) {
      // Ignora errores transitorios cuando el mapa cambia de estado de montaje.
    }
  }

  @override
  void didUpdateWidget(covariant EstablishmentMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_mapReady) return;

    final shouldForceMove =
        oldWidget.centerChangeToken != widget.centerChangeToken;
    final shouldAutoMove =
        oldWidget.center != widget.center && widget.autoRecenter;
    if (shouldForceMove || shouldAutoMove) {
      _moveToCenter();
    }
  }

  List<RailwayEstablishmentView> _buildDisplayItems() {
    final validItems = widget.establishments
        .where((item) => item.hasValidCoordinates)
        .toList();

    validItems.sort((a, b) {
      final distanceA = _distance.as(
        LengthUnit.Meter,
        widget.center,
        LatLng(a.latitude!, a.longitude!),
      );
      final distanceB = _distance.as(
        LengthUnit.Meter,
        widget.center,
        LatLng(b.latitude!, b.longitude!),
      );
      return distanceA.compareTo(distanceB);
    });

    if (validItems.length <= _maxMarkers) return validItems;
    return validItems.take(_maxMarkers).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _buildDisplayItems();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.center,
        initialZoom: 14,
        minZoom: 3,
        maxZoom: 19,
        onMapReady: () {
          _mapReady = true;
          _moveToCenter();
        },
        onPositionChanged: (position, hasGesture) {
          _lastZoom = position.zoom;
          if (hasGesture) {
            widget.onUserGesture?.call();
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.enhorario',
        ),
        if (widget.userPosition != null && widget.nearbyRadiusKm != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: widget.userPosition!,
                radius: widget.nearbyRadiusKm! * 1000,
                useRadiusInMeter: true,
                color: Colors.blue.withValues(alpha: 0.12),
                borderColor: Colors.blue.withValues(alpha: 0.7),
                borderStrokeWidth: 2,
              ),
            ],
          ),
        if (widget.userTrail.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.userTrail,
                strokeWidth: 4,
                color: Colors.blue.withValues(alpha: 0.75),
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (widget.userPosition != null)
              Marker(
                point: widget.userPosition!,
                width: 48,
                height: 48,
                child: const _UserLocationMarker(),
              ),
            ...visibleItems.map((item) {
              final isSelected = item.id == widget.selectedEstablishmentId;
              final markerColor = widget.markerColorResolver(item);

              return Marker(
                point: LatLng(item.latitude!, item.longitude!),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => widget.onMarkerTap(item),
                  child: _EstablishmentMarker(
                    color: markerColor,
                    selected: isSelected,
                  ),
                ),
              );
            }),
          ],
        ),
        RichAttributionWidget(
          attributions: const [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withValues(alpha: 0.2),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
      ),
    );
  }
}

class _EstablishmentMarker extends StatelessWidget {
  const _EstablishmentMarker({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: selected ? 24 : 20,
      height: selected ? 24 : 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: selected ? 3 : 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}
