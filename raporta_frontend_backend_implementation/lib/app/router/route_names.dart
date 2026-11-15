class RouteNames {
  const RouteNames._();

  static const splash = '/splash';

  // Authentication
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const emailVerification = '/email-verification';

  // Citizen workflow
  static const citizenDashboard = '/citizen';
  static const createReport = '/citizen/create-report';
  static const reports = '/citizen/reports';
  static const reportDetails = '/citizen/reports/:reportId';
  static const myReports = '/citizen/my-reports';

  // Preserve the existing citizen notifications route.
  static const notifications = '/citizen/notifications';

  // Official workflow
  static const officialDashboard = '/official';
  static const assignedReports = '/official/reports';
  static const reviewReport = '/official/reports/:reportId';
  static const reportQueue = '/official/report-queue';
  static const officialNotifications = '/official/notifications';

  // Shared account screens
  static const profile = '/profile';
  static const editAccount = '/profile/edit-account';
}
