import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/report.dart';

class ExploreReportsMap extends StatelessWidget {
  final List<Report> reports;
  final ValueChanged<String> onReportSelected;
  const ExploreReportsMap({
    super.key,
    required this.reports,
    required this.onReportSelected,
  });

  static const String _stadiaApiKey = String.fromEnvironment(
    'STADIA_MAPS_API_KEY',
  );

  static const LatLng _kigaliCenter = LatLng(-1.9500, 30.0600);

  @override
  Widget build(BuildContext context) {
    final validReports = reports.where((report) {
      return report.status.isPublic &&
          report.lat.isFinite &&
          report.lng.isFinite &&
          report.lat >= -90 &&
          report.lat <= 90 &&
          report.lng >= -180 &&
          report.lng <= 180 &&
          !(report.lat == 0 && report.lng == 0);
    }).toList();
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(12),
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: _kigaliCenter,
          initialZoom: 12.5,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tiles.stadiamaps.com/tiles/'
                'alidade_smooth/{z}/{x}/{y}.png'
                '?api_key=$_stadiaApiKey',
            userAgentPackageName: 'com.raporta.app',
          ),

          MarkerLayer(
            markers: [
              for (final report in validReports)
                Marker(
                  point: LatLng(report.lat, report.lng),
                  width: 48,
                  height: 48,
                  alignment: Alignment.bottomCenter,
                  child: Tooltip(
                    message: report.category.name,
                    child: GestureDetector(
                      onTap: () => onReportSelected(report.reportId),

                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 44,
                      ),
                    ),
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
