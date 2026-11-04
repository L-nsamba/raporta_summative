import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:raporta_frontend_backend_implementation/app/router/route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.login,
    routes: [
      // Authentication
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => 
        // const LoginPage(title: 'Login'),
        const SizedBox.shrink()
      ),

      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => 
        // const RegistrationPage(title: 'Register'),
        const Text('Registration in progress')
      ),

      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => 
        // const ForgotPasswordPage(title: 'ForgotPassword'),
        const Text('Forgot Password in progress')
      ),

      GoRoute(
        path: RouteNames.emailVerification,
        builder: (context, state) => 
        // const EmailVerificationPage(title: 'Email Verification'),
        const Text('Email Verification in progress')
      ),

      // Citizen workflow
      GoRoute(
        path: RouteNames.citizenDashboard,
        builder: (context, state) =>
        // const CitizenDashboardPage(title: 'Citizen Dashboard'),
        const Text('Citizen Dashboard in progress')
      ),

      GoRoute(
        path: RouteNames.createReport,
        builder: (context, state) =>
        // const CreateReportPage(title: 'Create Report'),
        const Text('Create Report In Progress')
      ),

      GoRoute(
        path: RouteNames.reports,
        builder: (context, state) => 
        //const ReportsPage(title: 'Reports'),
        const Text('Reports in progress')
      ),

      GoRoute(
        path: RouteNames.reportDetails,
        builder: (context, state) {
          return Text('Report Details in progress');
          // allowing navigation to different reports using the same screen
          // final reportId = state.pathParameters['reportId']!;

          // return ReportDetailsPage(title: 'Report Details: $reportId');
        },
      ),

      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) =>
        // const NotificationsPage(title: 'Notifications'),
        const Text('Notifications page in progress')
      ),

      // Official workflow
      GoRoute(
        path: RouteNames.officialDashboard,
        builder: (context, state) => 
        // const OfficialDashboardPage(title: 'Official Dashboard'),
        const Text('Official Dashboard in progress')
      ),

      GoRoute(
        path: RouteNames.assignedReports,
        builder: (context, state) => 
        // const AssignedReportsPage(title: 'Assigned Reports'),
        const Text('Assigned Reports in progress')
      ),

      GoRoute(
        path: RouteNames.reviewReport,
        builder: (context, state) {
          return Text('Review Reports in progress');
          // final reportId = state.pathParameters['reportId']!;

          // return ReviewReportsPage(title: 'Review Report: $reportId');
        },
      ),

      // Shared route
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => 
        // const ProfilePage(title: 'Profile')
        const Text('Profile page in progress')
        ,
      ),
    ],
  );
}
