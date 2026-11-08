import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class GetReportById {
  final ReportsRepository repository;

  GetReportById({required this.repository});

  Future<Report?> call(String reportId) {
    return repository.getReportById(reportId);
  }
}
