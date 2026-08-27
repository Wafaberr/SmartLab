class Endpoints {
  // static final String baseUrl = 'http://172.16.0.163:8000/';
  static final String baseUrl = 'http://10.0.2.2:8000/';
  static final String login = 'auth/login/';
  static final String refreshToken = 'auth/token/refresh/';
  static final String signup = 'auth/signup/';
  static final String profile = 'auth/profile/';
  static const String users = 'auth/users/';
  static const String forgotPassword = 'auth/forgot-password/';
  static const String resetPassword = 'auth/reset-password/';
  static const String changePassword = 'auth/change-password/';
  static const String home = '/home';
  static const String products = 'inventory/products/';

  static String productMovements(int productId) =>
      'inventory/products/$productId/movements/';
  static const String laboratorySessions = 'laboratory/sessions/';
  static const String laboratoryAnalysisTypes = 'laboratory/analysis-types/';
}
