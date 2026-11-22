import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/repositories/reports_repository.dart';

class UpdateReportStatus {
  final ReportsRepository repository;

  UpdateReportStatus({required this.repository});

  Future<void> call({required String reportId, required ReportStatus status}) {
    return repository.updateReportStatus(reportId: reportId, status: status);
  }
}
