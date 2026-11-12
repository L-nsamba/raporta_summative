import 'package:equatable/equatable.dart';

import '../../domain/entities/report.dart';

enum MyReportsStatus { initial, loading, loaded, empty, failure }

class MyReportsState extends Equatable {
  final MyReportsStatus status;
  final List<Report> reports;
  final String? errorMessage;

  const MyReportsState({
    this.status = MyReportsStatus.initial,
    this.reports = const [],
    this.errorMessage,
  });

  MyReportsState copyWith({
    MyReportsStatus? status,
    List<Report>? reports,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyReportsState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reports, errorMessage];
}
