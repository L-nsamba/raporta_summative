import 'package:equatable/equatable.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/domain/entities/area.dart';

enum AreasStatus { initial, loading, success, failure }

class AreasState extends Equatable {
  final AreasStatus status;
  final List<Area> areas;
  final String? errorMessage;

  const AreasState({
    this.status = AreasStatus.initial,
    this.areas = const [],
    this.errorMessage,
  });

  AreasState copyWith({
    AreasStatus? status,
    List<Area>? areas,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AreasState(
      status: status ?? this.status,
      areas: areas ?? this.areas,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, areas, errorMessage];
}
