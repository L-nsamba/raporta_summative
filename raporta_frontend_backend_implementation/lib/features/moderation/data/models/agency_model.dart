import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/agency.dart';

class AgencyModel extends Agency {
  const AgencyModel({
    required super.agencyId,
    required super.name,
    required super.category,
  });

  factory AgencyModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw FormatException('Agency document ${document.id} has no data.');
    }

    return AgencyModel(
      agencyId: document.id,
      name: data['name'] as String,
      category: data['category'] as String,
    );
  }
}
