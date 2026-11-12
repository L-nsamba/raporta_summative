import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class CreateReport {
  final ReportsRepository repository;

  CreateReport({required this.repository});

  Future<String> call(Report report) {
    return repository.createReport(report);
  }
}
