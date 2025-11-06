class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App name
  static const String appName = 'Moinc';

  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String dashboardRoute = '/dashboard';
  static const String profileRoute = '/profile';
  static const String reportsRoute = '/reports';
  static const String documentsRoute = '/documents';

  // Padding
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Animation durations
  // Animations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  // UI Constants

  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // API endpoints
  static const String baseUrl = 'https://api.moinc.ai';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String documentsEndpoint = '/documents';
  static const String reportsEndpoint = '/reports';
  static const String profileEndpoint = '/profile';
}
