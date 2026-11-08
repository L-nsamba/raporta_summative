import '../repositories/reports_repository.dart';

class ToggleUpvote {
  final ReportsRepository repository;

  ToggleUpvote({required this.repository});

  Future<void> call({required String reportId, required String userId}) {
    return repository.toggleUpvote(reportId: reportId, userId: userId);
  }
}
