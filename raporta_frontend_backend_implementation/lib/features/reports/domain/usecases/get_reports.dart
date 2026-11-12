import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class GetReports {
  final ReportsRepository repository;

  GetReports({required this.repository});

  Future<List<Report>> call() {
    return repository.getReports();
  }
}
