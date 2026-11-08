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
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/get_current_user.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/register_with_email.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/send_email_verification.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/send_password_reset.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/sign_out.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/datasources/reports_remote_datasource_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/repositories/reports_repository.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/create_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/delete_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_my_reports.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_report_by_id.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_reports.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_upvote.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/toggle_upvote.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/update_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/my_reports_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_details_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_cubit.dart';

// sl means service locator
final sl = GetIt.instance;

Future<void> initializeDependencies() async {
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
    () => AuthBloc(
      registerWithEmail: sl<RegisterWithEmail>(),
      signInWithEmail: sl<SignInWithEmail>(),
      signInWithGoogle: sl<SignInWithGoogle>(),
      sendEmailVerification: sl<SendEmailVerification>(),
      sendPasswordReset: sl<SendPasswordReset>(),
      getCurrentUser: sl<GetCurrentUser>(),
      watchAuthState: sl<WatchAuthState>(),
      signOut: sl<SignOut>(),
    ),
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

  // Authentication use cases
  sl.registerLazySingleton(() => RegisterWithEmail(sl<AuthRepository>()));

  sl.registerLazySingleton(() => SignInWithEmail(sl<AuthRepository>()));

  sl.registerLazySingleton(() => SignInWithGoogle(sl<AuthRepository>()));

  sl.registerLazySingleton(() => SendEmailVerification(sl<AuthRepository>()));

  sl.registerLazySingleton(() => SendPasswordReset(sl<AuthRepository>()));

  sl.registerLazySingleton(() => GetCurrentUser(sl<AuthRepository>()));

  sl.registerLazySingleton(() => WatchAuthState(sl<AuthRepository>()));

  sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));

  // Reports Use Cases
  sl.registerLazySingleton(() => CreateReport(repository: sl()));

  sl.registerLazySingleton(() => GetReports(repository: sl()));

  sl.registerLazySingleton(() => GetReportById(repository: sl()));

  sl.registerLazySingleton(() => GetMyReports(repository: sl()));

  sl.registerLazySingleton(() => UpdateReport(repository: sl()));

  sl.registerLazySingleton(() => DeleteReport(repository: sl()));

  sl.registerLazySingleton(() => GetUpvotes(repository: sl()));

  sl.registerLazySingleton(() => ToggleUpvote(repository: sl()));

  sl.registerFactory(() => ReportFormCubit(createReport: sl()));

  sl.registerFactory(() => ReportsBloc(getReports: sl()));

  sl.registerFactory(() => MyReportsCubit(getMyReports: sl()));

  sl.registerFactory(
    () => ReportDetailsCubit(
      getReportById: sl(),
      getUpvotes: sl(),
      toggleUpvote: sl(),
    ),
  );
}
