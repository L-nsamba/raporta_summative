import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/pages/login_page.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/pages/register_page.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/pages/verify_email_page.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/pages/welcome_page.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/presentation/pages/citizen_dashboard_page.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/presentation/pages/official_dashboard_page.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/presentation/pages/report_moderation_page.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/presentation/pages/edit_account_page.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/presentation/pages/profile_page.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/pages/create_report_page.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/presentation/pages/report_management_page.dart';

import '../../core/enums/user_role.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,

    // AUTHENTICATION AND ROLE-BASED REDIRECTION
    redirect: (context, routerState) {
      final authState = context.read<AuthBloc>().state;
      final location = routerState.matchedLocation;

      final isChecking =
          authState.status == AuthStatus.unknown ||
          authState.status == AuthStatus.checking;

      final isSplashPage = location == RouteNames.splash;

      final isVerificationPage = location == RouteNames.emailVerification;

      final isPublicAuthPage = [
        RouteNames.welcome,
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
      ].contains(location);

      // 1. Wait for the authentication check.
      if (isChecking) {
        return isSplashPage ? null : RouteNames.splash;
      }

      // 2. Handle unauthenticated users.
      if (authState.status != AuthStatus.authenticated ||
          authState.user == null) {
        return isPublicAuthPage ? null : RouteNames.welcome;
      }

      // 3. Require email verification.
      if (!authState.isEmailVerified) {
        return isVerificationPage ? null : RouteNames.emailVerification;
      }

      final user = authState.user!;

      // Determine the user's dashboard based on their role.
      final dashboard = user.role == UserRole.official
          ? RouteNames.officialDashboard
          : RouteNames.citizenDashboard;

      // 4. Verified users should not remain on auth pages.
      if (isPublicAuthPage || isSplashPage || isVerificationPage) {
        return dashboard;
      }

      // 5. Prevent citizens from accessing official routes.
      if (location.startsWith('/official') && user.role != UserRole.official) {
        return RouteNames.citizenDashboard;
      }

      // 6. Prevent officials from accessing citizen routes.
      if (location.startsWith('/citizen') && user.role != UserRole.citizen) {
        return RouteNames.officialDashboard;
      }

      // No redirection needed.
      return null;
    },

    routes: [
      // =========================
      // SPLASH
      // =========================

      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),

      // =========================
      // AUTHENTICATION
      // =========================
      GoRoute(
        path: RouteNames.welcome,
        builder: (context, state) => const WelcomePage(),
      ),

      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),

      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      GoRoute(
        path: RouteNames.emailVerification,
        builder: (context, state) => const VerifyEmailPage(),
      ),

      // =========================
      // CITIZEN WORKFLOW
      // =========================
      GoRoute(
        path: RouteNames.citizenDashboard,
        builder: (context, state) => const CitizenDashboardPage(),
      ),

      GoRoute(
        path: RouteNames.createReport,
        builder: (context, state) => const CreateReportPage(),
      ),

      GoRoute(
        path: RouteNames.reports,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Browse Reports in progress')),
        ),
      ),

      GoRoute(
        path: RouteNames.reportDetails,
        builder: (context, state) {
          final reportId = state.pathParameters['reportId']!;

          return Scaffold(
            body: Center(child: Text('Report Details: $reportId')),
          );
        },
      ),

      GoRoute(
        path: RouteNames.myReports,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('My Reports in progress'))),
      ),

      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Citizen Notifications in progress')),
        ),
      ),

      GoRoute(
        path: RouteNames.officialDashboard,
        builder: (context, state) => const OfficialDashboardPage(),
      ),

      GoRoute(
        path: RouteNames.assignedReports,
        builder: (context, state) => const ReportManagementPage(),
      ),

      GoRoute(
        path: RouteNames.reportQueue,
        builder: (context, state) => const ReportModerationPage(),
      ),

      GoRoute(
        path: RouteNames.reviewReport,
        builder: (context, state) {
          final reportId = state.pathParameters['reportId']!;

          return Scaffold(
            body: Center(child: Text('Review Report: $reportId')),
          );
        },
      ),

      GoRoute(
        path: RouteNames.officialNotifications,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Official Notifications in progress')),
        ),
      ),

      // =========================
      // SHARED ACCOUNT SCREENS
      // =========================
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),

      GoRoute(
        path: RouteNames.editAccount,
        builder: (context, state) => const EditAccountPage(),
      ),
    ],
  );
}
