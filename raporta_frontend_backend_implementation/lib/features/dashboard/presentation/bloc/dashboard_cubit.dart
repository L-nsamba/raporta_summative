import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_citizen_dashboard.dart';
import '../../domain/usecases/get_official_dashboard.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetCitizenDashboard getCitizenDashboard;
  final GetOfficialDashboard getOfficialDashboard;

  DashboardCubit({
    required this.getCitizenDashboard,
    required this.getOfficialDashboard,
  }) : super(const DashboardState());

  int _requestId = 0;

  Future<void> loadCitizenDashboard({
    required String userId,
    required String areaId,
  }) async {
    if (isClosed) return;

    final requestId = ++_requestId;

    emit(const DashboardState(status: DashboardStatus.loading));

    try {
      final stats = await getCitizenDashboard(userId: userId, areaId: areaId);

      if (isClosed || requestId != _requestId) return;

      emit(DashboardState(status: DashboardStatus.loaded, citizenStats: stats));
    } catch (error) {
      if (isClosed || requestId != _requestId) return;

      emit(
        DashboardState(
          status: DashboardStatus.failure,
          errorMessage: 'Unable to load your dashboard. Please try again.',
        ),
      );
    }
  }

  Future<void> loadOfficialDashboard() async {
    if (isClosed) return;

    final requestId = ++_requestId;

    emit(const DashboardState(status: DashboardStatus.loading));

    try {
      final stats = await getOfficialDashboard();

      if (isClosed || requestId != _requestId) return;

      emit(
        DashboardState(status: DashboardStatus.loaded, officialStats: stats),
      );
    } catch (error) {
      if (isClosed || requestId != _requestId) return;

      emit(
        DashboardState(
          status: DashboardStatus.failure,
          errorMessage:
              'Unable to load dashboard statistics. Please try again.',
        ),
      );
    }
  }

  void reset() {
    if (isClosed) return;

    _requestId++;

    emit(const DashboardState());
  }
}
