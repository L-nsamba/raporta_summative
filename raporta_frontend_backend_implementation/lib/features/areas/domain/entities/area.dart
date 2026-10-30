class Area {
  final String areaId;
  final String name;
  final double centerLat;
  final double centerLng;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Area({
    required this.areaId,
    required this.name,
    required this.centerLat,
    required this.centerLng,
    required this.createdAt,
    required this.updatedAt,
  });
}
