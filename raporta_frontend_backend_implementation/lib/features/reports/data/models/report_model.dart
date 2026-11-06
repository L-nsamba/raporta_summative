import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/decline_reason.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/report.dart';

class ReportModel extends Report {
  const ReportModel({
    required super.reportId,
    required super.userId,
    required super.areaId,
    required super.category,
    required super.description,
    required super.lat,
    required super.lng,
    super.photoUrl,
    required super.status,
    super.declineReason,
    super.declineFeedback,
    super.agencyId,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory ReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception('Report document does not exist.');
    }

    return ReportModel(
      reportId: document.id,
      userId: data['userId'] as String,
      areaId: data['areaId'] as String,
      category: ReportCategory.values.byName(data['category'] as String),
      description: data['description'] as String,
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      photoUrl: data['photoUrl'] as String?,
      status: _parseStatus(data['status'] as String),
      declineReason: _parseDeclineReason(data['declineReason'] as String?),
      declineFeedback: data['declineFeedback'] as String?,
      agencyId: data['agencyId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'areaId': areaId,
      'category': category.name,
      'description': description,
      'lat': lat,
      'lng': lng,
      'photoUrl': photoUrl,
      'status': _statusToFirestore(status),
      'declineReason': declineReason == null
          ? null
          : _declineReasonToFirestore(declineReason!),
      'declineFeedback': declineFeedback,
      'agencyId': agencyId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  static ReportStatus _parseStatus(String value) {
    return switch (value) {
      'pending' => ReportStatus.pending,
      'under_review' => ReportStatus.underReview,
      'forwarded' => ReportStatus.forwarded,
      'in_progress' => ReportStatus.inProgress,
      'resolved' => ReportStatus.resolved,
      'declined' => ReportStatus.declined,
      _ => throw FormatException('Unknown report status: $value'),
    };
  }

  static String _statusToFirestore(ReportStatus status) {
    return switch (status) {
      ReportStatus.pending => 'pending',
      ReportStatus.underReview => 'under_review',
      ReportStatus.forwarded => 'forwarded',
      ReportStatus.inProgress => 'in_progress',
      ReportStatus.resolved => 'resolved',
      ReportStatus.declined => 'declined',
    };
  }

  static DeclineReason? _parseDeclineReason(String? value) {
    if (value == null) return null;

    return switch (value) {
      'duplicate' => DeclineReason.duplicate,
      'unrelated' => DeclineReason.unrelated,
      'already_resolved' => DeclineReason.alreadyResolved,
      'other' => DeclineReason.other,
      _ => throw FormatException('Unknown decline reason: $value'),
    };
  }

  static String _declineReasonToFirestore(DeclineReason reason) {
    return switch (reason) {
      DeclineReason.duplicate => 'duplicate',
      DeclineReason.unrelated => 'unrelated',
      DeclineReason.alreadyResolved => 'already_resolved',
      DeclineReason.other => 'other',
    };
  }
}
