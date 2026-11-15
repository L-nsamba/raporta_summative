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
import 'package:raporta_frontend_backend_implementation/features/areas/presentation/bloc/areas_cubit.dart';
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
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/update_profile.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/domain/usecases/get_citizen_dashboard.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/domain/usecases/get_official_dashboard.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/data/datasources/agencies_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/data/repositories/agencies_repository_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/domain/repositories/agencies_repository.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/domain/usecases/get_agencies.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/presentation/cubit/agencies_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/presentation/cubit/moderation_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:raporta_frontend_backend_implementation/features/notifications/domain/usecases/get_notifications.dart';
import 'package:raporta_frontend_backend_implementation/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:raporta_frontend_backend_implementation/features/notifications/domain/usecases/watch_notifications.dart';
import 'package:raporta_frontend_backend_implementation/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/data/datasources/preferences_local_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/data/repositories/preferences_repository_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/domain/repositories/preferences_repository.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/domain/usecases/get_preferences.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/domain/usecases/save_preferences.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/presentation/bloc/preferences_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/datasources/reports_remote_datasource_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/repositories/reports_repository.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/create_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/decline_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/delete_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/forward_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_my_reports.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_public_reports.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_report_by_id.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_reports.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_upvote.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/toggle_upvote.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/update_report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/bloc/reports_scope.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/my_reports_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_details_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // register Factory => UI state, Bloc, Cubit, form controllers
  // register LazySingleton => Heavy services, databases and API clients intended to be delayed
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
      updateProfile: sl(),
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

  sl.registerLazySingleton(
    () => GetPublicReports(repository: sl<ReportsRepository>()),
  );

  sl.registerLazySingleton(() => GetReportById(repository: sl()));

  sl.registerLazySingleton(() => GetMyReports(repository: sl()));

  sl.registerLazySingleton(() => UpdateReportStatus(repository: sl()));

  sl.registerLazySingleton(() => ForwardReport(repository: sl()));

  sl.registerLazySingleton(() => DeclineReport(repository: sl()));

  sl.registerLazySingleton(() => DeleteReport(repository: sl()));

  sl.registerLazySingleton(() => GetUpvotes(repository: sl()));

  sl.registerLazySingleton(() => ToggleUpvote(repository: sl()));

  sl.registerFactory(
    () => ReportFormCubit(createReport: sl(), uploadReportPhoto: sl()),
  );

  sl.registerFactory(
    () => ModerationCubit(
      updateReportStatus: sl(),
      forwardReport: sl(),
      declineReport: sl(),
    ),
  );

  sl.registerFactoryParam<ReportsBloc, ReportsScope, void>(
    (scope, _) => ReportsBloc(
      getReports: sl<GetReports>(),
      getPublicReports: sl<GetPublicReports>(),
      scope: scope,
    ),
  );

  sl.registerFactory(() => MyReportsCubit(getMyReports: sl()));

  sl.registerFactory(
    () => ReportDetailsCubit(
      getReportById: sl(),
      getUpvotes: sl(),
      toggleUpvote: sl(),
    ),
  );

  // AGENCIES
  // Remote data source
  sl.registerLazySingleton<AgenciesRemoteDataSource>(
    () => AgenciesRemoteDataSourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<AgenciesRepository>(
    () => AgenciesRepositoryImpl(remoteDataSource: sl()),
  );

  // Use case
  sl.registerLazySingleton(() => GetAgencies(repository: sl()));

  sl.registerFactory(() => AgenciesCubit(getAgencies: sl()));

  sl.registerFactory(() => AreasCubit(getAreas: sl(), getAreaById: sl()));

  // NOTIFICATIONS
  // Remote data source
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotifications(repository: sl()));

  sl.registerLazySingleton(() => WatchNotifications(repository: sl()));

  sl.registerLazySingleton(() => MarkNotificationRead(repository: sl()));

  // NOTIFICATIONS
  sl.registerFactory(
    () =>
        NotificationsBloc(watchNotifications: sl(), markNotificationRead: sl()),
  );

  // PROFILE - PREFERENCES

  sl.registerLazySingleton<SharedPreferencesAsync>(
    () => SharedPreferencesAsync(),
  );

  sl.registerLazySingleton<PreferencesLocalDatasource>(
    () => PreferencesLocalDatasourceImpl(
      preferences: sl<SharedPreferencesAsync>(),
      firebaseAuth: sl<FirebaseAuth>(),
    ),
  );

  sl.registerLazySingleton<PreferencesRepository>(
    () => PreferencesRepositoryImpl(localDatasource: sl()),
  );

  sl.registerLazySingleton(() => GetPreferences(repository: sl()));

  sl.registerLazySingleton(() => SavePreferences(repository: sl()));

  sl.registerFactory(
    () => PreferencesCubit(getPreferences: sl(), savePreferences: sl()),
  );

  sl.registerLazySingleton(() => UpdateProfile(repository: sl()));

  // DASHBOARD
  sl.registerLazySingleton<GetCitizenDashboard>(
    () => GetCitizenDashboard(sl<ReportsRepository>()),
  );

  sl.registerLazySingleton<GetOfficialDashboard>(
    () => GetOfficialDashboard(sl<ReportsRepository>()),
  );

  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(
      getCitizenDashboard: sl<GetCitizenDashboard>(),
      getOfficialDashboard: sl<GetOfficialDashboard>(),
    ),
  );
}
