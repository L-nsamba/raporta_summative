class RouteNames {
  // Authentication
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const emailVerification = 'email-verification';

  // Citizen workflow
  static const citizenDashboard = '/citizen';
  static const createReport = '/citizen/create-report';
  static const reports = '/citizen/reports';
  static const reportDetails = '/citizen/reports/:reportId';
  static const notifications = '/citizen/notifications';

  // Official
  static const officialDashboard = '/official';
  static const assignedReports = '/official/reports';
  static const reviewReport = '/official/reports/:reportId';

  // Shared
  static const profile = '/profile';
}
