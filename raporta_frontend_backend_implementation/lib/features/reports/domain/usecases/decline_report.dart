import 'package:raporta_frontend_backend_implementation/core/enums/decline_reason.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/repositories/reports_repository.dart';

class DeclineReport {
  final ReportsRepository repository;

  DeclineReport({required this.repository});

  Future<void> call({
    required String reportId,
    required DeclineReason reason,
    String? feedback,
  }) {
    return repository.declineReport(
      reportId: reportId,
      reason: reason,
      feedback: feedback,
    );
  }
}
