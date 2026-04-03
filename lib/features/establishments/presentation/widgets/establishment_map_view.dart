import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EstablishmentMapView extends StatefulWidget {
  const EstablishmentMapView({
    super.key,
    required this.establishments,
    required this.center,
    required this.showUserLocation,
    required this.onMarkerTap,
    required this.markerColorResolver,
    this.selectedEstablishmentId,
  });

  final List<RailwayEstablishmentView> establishments;
  final LatLng center;
  final bool showUserLocation;
  final ValueChanged<RailwayEstablishmentView> onMarkerTap;
  final Color Function(RailwayEstablishmentView item) markerColorResolver;
  final String? selectedEstablishmentId;

  @override
  State<EstablishmentMapView> createState() => _EstablishmentMapViewState();
}

class _EstablishmentMapViewState extends State<EstablishmentMapView> {
  static const int _maxMarkers = 120;
  static const double _nearbyThresholdMeters = 15000;

  final MapController _mapController = MapController();
  final Distance _distance = const Distance();

  @override
  void didUpdateWidget(covariant EstablishmentMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.center != widget.center) {
      _mapController.move(widget.center, _mapController.camera.zoom);
    }
  }

  List<RailwayEstablishmentView> _buildDisplayItems() {
    final validItems = widget.establishments.where((item) => item.hasValidCoordinates).toList();

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

    final nearby = validItems.where((item) {
      final itemDistance = _distance.as(
        LengthUnit.Meter,
        widget.center,
        LatLng(item.latitude!, item.longitude!),
      );
      return itemDistance <= _nearbyThresholdMeters;
    }).toList();

    final source = nearby.isNotEmpty ? nearby : validItems;
    if (source.length <= _maxMarkers) return source;
    return source.take(_maxMarkers).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _buildDisplayItems();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.center,
          initialZoom: 14,
          minZoom: 3,
          maxZoom: 19,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.enhorario',
          ),
          MarkerLayer(
            markers: [
              if (widget.showUserLocation)
                Marker(
                  point: widget.center,
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
      ),
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
  const _EstablishmentMarker({
    required this.color,
    required this.selected,
  });

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
        border: Border.all(
          color: Colors.white,
          width: selected ? 3 : 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
