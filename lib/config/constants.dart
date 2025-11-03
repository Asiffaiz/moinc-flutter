class AppConstants {
  // App Info
  static const String appName = 'Moinc';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'https://api.moinc.ai';

  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String isFirstRunKey = 'is_first_run';
  static const String agentEnabledKey = 'agent_enabled';
  static const String registrationEnabledKey = 'registration_enabled';

  // Routes
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String dashboardRoute = '/dashboard';
  static const String profileRoute = '/profile';

  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String splashBackgroundPath =
      'assets/images/splash_background.png';
  static const String loginBackgroundPath =
      'assets/images/login_background.png';
  static const String profilePlaceholderPath =
      'assets/images/profile_placeholder.png';

  // Animations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultSpacing = 8.0;
}
