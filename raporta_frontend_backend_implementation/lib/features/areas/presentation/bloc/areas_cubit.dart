import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/domain/usecases/get_area_by_id.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/domain/usecases/get_areas.dart';

import 'areas_state.dart';

class AreasCubit extends Cubit<AreasState> {
  final GetAreas getAreas;
  final GetAreaById getAreaById;

  AreasCubit({required this.getAreas, required this.getAreaById})
    : super(const AreasState());

  Future<void> fetchAreas() async {
    emit(state.copyWith(status: AreasStatus.loading, errorMessage: null));

    try {
      final areas = await getAreas();

      emit(state.copyWith(status: AreasStatus.success, areas: areas));
    } catch (e) {
      emit(
        state.copyWith(
          status: AreasStatus.failure,
          errorMessage: 'Failed to load areas. Please try again.',
        ),
      );
    }
  }

  Future<void> fetchAreaById(String areaId) async {
    try {
      final area = await getAreaById(areaId);

      if (area == null) {
        emit(state.copyWith(errorMessage: 'Area not found.'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to retrieve area details.'));
    }
  }
}
