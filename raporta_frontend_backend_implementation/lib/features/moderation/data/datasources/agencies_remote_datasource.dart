import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/agency_model.dart';

abstract class AgenciesRemoteDataSource {
  Future<List<AgencyModel>> getAgencies();
}

class AgenciesRemoteDataSourceImpl implements AgenciesRemoteDataSource {
  final FirebaseFirestore firestore;

  AgenciesRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AgencyModel>> getAgencies() async {
    final snapshot = await firestore.collection('agencies').get();

    final agencies = snapshot.docs
        .map((document) => AgencyModel.fromFirestore(document))
        .toList();

    agencies.sort((a, b) => a.name.compareTo(b.name));

    return agencies;
  }
}
