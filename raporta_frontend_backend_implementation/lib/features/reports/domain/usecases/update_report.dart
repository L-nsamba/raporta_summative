import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class UpdateReport {
  final ReportsRepository repository;

  UpdateReport({required this.repository});

  Future<void> call(Report report) {
    return repository.updateReport(report);
  }
}
