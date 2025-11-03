import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/screens/dashboard_screen.dart';
import 'package:moinc/screens/login_screen.dart';
import 'package:moinc/screens/profile_screen.dart';
import 'package:moinc/screens/register_screen.dart';
import 'package:moinc/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light, // Default to light theme
      debugShowCheckedModeBanner: false,
      initialRoute: AppConstants.splashRoute,
      routes: {
        AppConstants.splashRoute: (context) => const SplashScreen(),
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.registerRoute: (context) => const RegisterScreen(),
        AppConstants.dashboardRoute: (context) => const DashboardScreen(),
        AppConstants.profileRoute: (context) => const ProfileScreen(),
      },
    );
  }
}
