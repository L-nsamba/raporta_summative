import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class GetPublicReports {
  final ReportsRepository repository;

  GetPublicReports({required this.repository});

  Future<List<Report>> call() {
    return repository.getPublicReports();
  }
}
