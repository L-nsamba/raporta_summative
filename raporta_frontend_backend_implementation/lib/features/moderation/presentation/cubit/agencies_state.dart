import 'package:equatable/equatable.dart';

import '../../domain/entities/agency.dart';

enum AgenciesStatus { initial, loading, loaded, empty, failure }

class AgenciesState extends Equatable {
  final AgenciesStatus status;
  final List<Agency> agencies;
  final String? errorMessage;

  const AgenciesState({
    this.status = AgenciesStatus.initial,
    this.agencies = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, agencies, errorMessage];
}
