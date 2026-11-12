import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/upvotes.dart';

class UpvoteModel extends Upvote {
  const UpvoteModel({required super.userId, required super.createdAt});

  factory UpvoteModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception('Upvote document does not exist.');
    }

    return UpvoteModel(
      userId: document.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'userId': userId, 'createdAt': Timestamp.fromDate(createdAt)};
  }
}
