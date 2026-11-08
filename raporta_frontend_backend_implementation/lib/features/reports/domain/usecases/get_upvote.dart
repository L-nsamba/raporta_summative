import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/upvotes.dart';

import '../repositories/reports_repository.dart';

class GetUpvotes {
  final ReportsRepository repository;

  GetUpvotes({required this.repository});

  Future<List<Upvote>> call(String reportId) {
    return repository.getUpvotes(reportId);
  }
}