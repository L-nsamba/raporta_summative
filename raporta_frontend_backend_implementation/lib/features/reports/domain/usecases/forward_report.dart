import 'package:raporta_frontend_backend_implementation/features/reports/domain/repositories/reports_repository.dart';

class ForwardReport {
  final ReportsRepository repository;

  ForwardReport({required this.repository});

  Future<void> call({
    required String reportId,
    required String agencyId,
  }) {
    return repository.forwardReport(
      reportId: reportId,
      agencyId: agencyId,
    );
  }
}