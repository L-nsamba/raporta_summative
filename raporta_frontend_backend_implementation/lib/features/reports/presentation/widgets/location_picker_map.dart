import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerMap extends StatelessWidget {
  final double? selectedLat;
  final double? selectedLng;
  final ValueChanged<LatLng> onLocationSelected;
  final bool enabled;

  const LocationPickerMap({
    super.key,
    required this.selectedLat,
    required this.selectedLng,
    required this.onLocationSelected,
    this.enabled = true,
  });

  // Starting view only, not selected report location
  static const LatLng _kigaliCenter = LatLng(-1.9500, 30.0600);

  // Stadia maps location configuration
  static const String _stadiaApiKey = String.fromEnvironment(
    'STADIA_MAPS_API_KEY',
  );

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedLat != null && selectedLng != null;
    final selectedPoint = hasSelection
        ? LatLng(selectedLat!, selectedLng!)
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: selectedPoint ?? _kigaliCenter,
          initialZoom: selectedPoint == null ? 12.5 : 16,
          minZoom: 9,
          maxZoom: 19,
          onTap: (tapPosition, point) {
            if (!enabled) return;

            onLocationSelected(point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tiles.stadiamaps.com/tiles/'
                'alidade_smooth/{z}/{x}/{y}.png'
                '?api_key=$_stadiaApiKey',
            userAgentPackageName: 'com.raporta.app',
          ),

          if (selectedPoint != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: selectedPoint,
                  width: 48,
                  height: 48,
                  alignment: Alignment.bottomCenter,
                  child: const Icon(
                    Icons.location_pin,
                    size: 46,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution('Stadia Maps'),
              TextSourceAttribution('OpenMapTiles'),
              TextSourceAttribution('OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
    );
  }
}
