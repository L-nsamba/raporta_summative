// This file acts as the central place where we create and register dependencies
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/data/datasources/area_remote_datasource.imp.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/data/datasources/areas_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/data/repositories/areas_repository_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/domain/repositories/areas_repository.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/domain/usecases/get_area_by_id.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/domain/usecases/get_areas.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/data/datasources/auth_remote_data_source_imp.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/repositories/auth_repository.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/datasources/reports_remote_datasource_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/repositories/reports_repository.dart';

// sl means service locator
final sl = GetIt.instance;

Future<void> intializeDependencies() async {
  // Firebase services
  // a singleton is a lifetime configuration that ensures a class has exactly one instance through the apps lifecycle
  // registerLazySingleton creates an instance when its first requested and resuses it afterwards
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Google Sign-in
  // Retrieval of the singleton
  final googleSignIn = GoogleSignIn.instance;

  await googleSignIn.initialize();

  sl.registerLazySingleton<GoogleSignIn>(() => googleSignIn);

  // Tells the GetIt how to construct the remote data source whenever something requests AuthRemoteDatasource
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  // Repository can be retrieved anywhere through GetIt
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );

  // Registering the area datasource and implementation
  sl.registerLazySingleton<AreasRemoteDataSource>(
    () => AreasRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  // Registering the area repository and implementation
  sl.registerLazySingleton<AreasRepository>(
    () => AreasRepositoryImpl(remoteDataSource: sl<AreasRemoteDataSource>()),
  );

  // Area use cases
  sl.registerLazySingleton(() => GetAreas(sl<AreasRepository>()));

  sl.registerLazySingleton(() => GetAreaById(sl<AreasRepository>()));

  // Auth bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  // Reports remote data source
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  // Reports repository
  sl.registerLazySingleton<ReportsRepository>(
    () =>
        ReportsRepositoryImpl(remoteDataSource: sl<ReportsRemoteDataSource>()),
  );
}
