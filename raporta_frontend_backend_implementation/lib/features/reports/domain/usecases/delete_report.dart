import '../repositories/reports_repository.dart';

class DeleteReport {
  final ReportsRepository repository;

  DeleteReport({required this.repository});

  Future<void> call(String reportId) {
    return repository.deleteReport(reportId);
  }
}
