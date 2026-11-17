import 'package:flutter_test/flutter_test.dart';

import 'package:raporta_frontend_backend_implementation/features/moderation/domain/entities/agency.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/domain/repositories/agencies_repository.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/domain/usecases/get_agencies.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/presentation/cubit/agencies_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/presentation/cubit/agencies_state.dart';

class FakeAgenciesRepository extends Fake implements AgenciesRepository {
  List<Agency> agencies = [];
  bool shouldFail = false;
  int callCount = 0;

  @override
  Future<List<Agency>> getAgencies() async {
    callCount++;

    if (shouldFail) {
      throw Exception('Failed to fetch agencies');
    }

    return agencies;
  }
}

void main() {
  late FakeAgenciesRepository repository;
  late AgenciesCubit cubit;

  final sampleAgencies = [
    const Agency(
      agencyId: 'roads_office',
      name: 'Roads Office',
      category: 'roads',
    ),
    const Agency(
      agencyId: 'sanitation_office',
      name: 'Sanitation Office',
      category: 'sanitation',
    ),
  ];

  setUp(() {
    repository = FakeAgenciesRepository();

    cubit = AgenciesCubit(getAgencies: GetAgencies(repository: repository));
  });

  tearDown(() async {
    await cubit.close();
  });

  test('initial state is correct', () {
    expect(cubit.state.status, AgenciesStatus.initial);
    expect(cubit.state.agencies, isEmpty);
    expect(cubit.state.errorMessage, isNull);
  });

  test('loads agencies successfully', () async {
    repository.agencies = sampleAgencies;

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<AgenciesState>().having(
          (state) => state.status,
          'status',
          AgenciesStatus.loading,
        ),
        isA<AgenciesState>().having(
          (state) => state.status,
          'status',
          AgenciesStatus.loaded,
        ),
      ]),
    );

    await cubit.loadAgencies();
    await expectation;

    expect(cubit.state.agencies, sampleAgencies);
    expect(repository.callCount, 1);
  });

  test('emits empty when no agencies exist', () async {
    repository.agencies = [];

    await cubit.loadAgencies();

    expect(cubit.state.status, AgenciesStatus.empty);
    expect(cubit.state.agencies, isEmpty);
  });

  test('handles retrieval failures', () async {
    repository.shouldFail = true;

    await cubit.loadAgencies();

    expect(cubit.state.status, AgenciesStatus.failure);
    expect(cubit.state.errorMessage, contains('Failed to fetch agencies'));
  });

  test('refresh fetches agencies again', () async {
    repository.agencies = sampleAgencies;

    await cubit.loadAgencies();
    await cubit.refreshAgencies();

    expect(repository.callCount, 2);
    expect(cubit.state.status, AgenciesStatus.loaded);
    expect(cubit.state.agencies.length, 2);
  });

  test('clearAgencies resets state', () async {
    repository.agencies = sampleAgencies;

    await cubit.loadAgencies();
    cubit.clearAgencies();

    expect(cubit.state.status, AgenciesStatus.initial);
    expect(cubit.state.agencies, isEmpty);
    expect(cubit.state.errorMessage, isNull);
  });

  test('recovers from a previous failure', () async {
    repository.shouldFail = true;

    await cubit.loadAgencies();

    expect(cubit.state.status, AgenciesStatus.failure);

    repository.shouldFail = false;
    repository.agencies = sampleAgencies;

    await cubit.refreshAgencies();

    expect(cubit.state.status, AgenciesStatus.loaded);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.agencies, sampleAgencies);
  });
}