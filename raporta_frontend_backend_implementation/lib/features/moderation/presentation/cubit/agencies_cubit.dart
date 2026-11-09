import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_agencies.dart';
import 'agencies_state.dart';

class AgenciesCubit extends Cubit<AgenciesState> {
  final GetAgencies getAgencies;

  AgenciesCubit({required this.getAgencies}) : super(const AgenciesState());

  Future<void> loadAgencies() async {
    emit(const AgenciesState(status: AgenciesStatus.loading));

    try {
      final agencies = await getAgencies();

      if (agencies.isEmpty) {
        emit(const AgenciesState(status: AgenciesStatus.empty));
        return;
      }

      emit(AgenciesState(status: AgenciesStatus.loaded, agencies: agencies));
    } catch (e) {
      emit(
        AgenciesState(
          status: AgenciesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refreshAgencies() async {
    await loadAgencies();
  }

  void clearAgencies() {
    emit(const AgenciesState());
  }
}
