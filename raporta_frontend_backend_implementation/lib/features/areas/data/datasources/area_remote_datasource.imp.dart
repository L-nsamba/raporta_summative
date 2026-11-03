
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raporta_frontend_backend_implementation/core/constants/firestore_collections.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/data/datasources/areas_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/data/models/area_model.dart';

class AreasRemoteDataSourceImpl implements AreasRemoteDataSource {
  final FirebaseFirestore firestore;

  AreasRemoteDataSourceImpl({
    required this.firestore,
  });

  @override
  Future<List<AreaModel>> getAreas() async {
    final snapshot = await firestore
        .collection(FirestoreCollections.areas)
        .get();

    return snapshot.docs
        .map((document) => AreaModel.fromFirestore(document))
        .toList();
  }

  @override
  Future<AreaModel?> getAreaById(String areaId) async {
    final document = await firestore
        .collection(FirestoreCollections.areas)
        .doc(areaId)
        .get();

    if (!document.exists) {
      return null;
    }

    return AreaModel.fromFirestore(document);
  }
}