import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class GetMyReports {
  final ReportsRepository repository;

  GetMyReports({required this.repository});

  Future<List<Report>> call(String userId) {
    return repository.getMyReports(userId);
  }
}
