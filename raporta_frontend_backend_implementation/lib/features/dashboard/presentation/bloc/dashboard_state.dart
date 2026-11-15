import '../../domain/entities/citizen_dashboard_stats.dart';
import '../../domain/entities/official_dashboard_stats.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState {
  final DashboardStatus status;

  final CitizenDashboardStats? citizenStats;
  final OfficialDashboardStats? officialStats;

  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.citizenStats,
    this.officialStats,
    this.errorMessage,
  });
}

