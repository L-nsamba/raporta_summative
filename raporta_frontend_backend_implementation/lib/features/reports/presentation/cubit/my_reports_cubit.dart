import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_my_reports.dart';
import 'my_reports_state.dart';

class MyReportsCubit extends Cubit<MyReportsState> {
  final GetMyReports getMyReports;

  MyReportsCubit({required this.getMyReports}) : super(const MyReportsState());

  Future<void> loadMyReports(String userId) async {
    emit(state.copyWith(status: MyReportsStatus.loading, clearError: true));

    try {
      final reports = await getMyReports(userId);

      if (reports.isEmpty) {
        emit(
          state.copyWith(
            status: MyReportsStatus.empty,
            reports: reports,
            clearError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MyReportsStatus.loaded,
            reports: reports,
            clearError: true,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MyReportsStatus.failure,
          errorMessage: 'Unable to load your reports. Please try again.',
        ),
      );
    }
  }

  Future<void> refreshReports(String userId) async {
    await loadMyReports(userId);
  }

  void clearReports() {
    emit(const MyReportsState());
  }
}
