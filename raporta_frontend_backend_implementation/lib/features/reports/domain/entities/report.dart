import 'package:raporta_frontend_backend_implementation/core/enums/decline_reason.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';

class Report {
  final String reportId;
  final String userId;
  final String areaId;

  final ReportCategory category;
  final String description;

  final double lat;
  final double lng;
  final String locationDescription;

  final String? photoUrl;

  final ReportStatus status;
  final DeclineReason? declineReason;
  final String? declineFeedback;

  final String? agencyId;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Report({
    required this.reportId,
    required this.userId,
    required this.areaId,
    required this.category,
    required this.description,
    required this.lat,
    required this.lng,
    required this.locationDescription,
    this.photoUrl,
    required this.status,
    this.declineReason,
    this.declineFeedback,
    this.agencyId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}
