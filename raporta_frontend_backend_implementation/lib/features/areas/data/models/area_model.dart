import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/domain/entities/area.dart';

class AreaModel extends Area {
  const AreaModel({
    required super.areaId,
    required super.name,
    required super.centerLat,
    required super.centerLng,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AreaModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception('Area document does not exist.');
    }

    return AreaModel(
      areaId: document.id,
      name: data['name'] as String,
      centerLat: (data['centerLat'] as num).toDouble(),
      centerLng: (data['centerLng'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'centerLat': centerLat,
      'centerLng': centerLng,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
