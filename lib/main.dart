import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/core/dependency_injection.dart';
import 'package:moinc/screens/Auth/presentation/bloc/auth_bloc.dart';
import 'package:moinc/screens/Auth/presentation/bloc/user_cubit.dart';
import 'package:moinc/screens/Auth/presentation/signup_screen.dart';
import 'package:moinc/screens/Auth/services/token_service.dart';
import 'package:moinc/screens/dashboard_screen.dart';
import 'package:moinc/screens/Auth/presentation/login_screen.dart';
import 'package:moinc/screens/profile_screen.dart';

import 'package:moinc/screens/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependencies
  await initializeDependencies();

  // Initialize API token with error handling
  try {
    // Get the TokenService from dependency injection
    final tokenService = GetIt.I<TokenService>();
    final token = await tokenService.getAccessToken();
    if (token == null) {
      print(
        'WARNING: Failed to get initial access token. Some features may not work properly.',
      );
    } else {
      print('Successfully initialized API access token');
    }
  } catch (e) {
    print('Error initializing API token: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = GetIt.I<AuthBloc>();

    // final authRepository = GetIt.I<AuthRepository>();

    return MultiRepositoryProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => authBloc),
        BlocProvider(create: (_) => UserCubit()..loadUser()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.light, // Default to light theme
        debugShowCheckedModeBanner: false,
        initialRoute: AppConstants.splashRoute,
        routes: {
          AppConstants.splashRoute: (context) => const SplashScreen(),
          AppConstants.loginRoute: (context) => const LoginScreen(),
          // AppConstants.registerRoute: (context) => const RegisterScreen(),
          AppConstants.registerRoute: (context) => const SignUpScreen(),

          AppConstants.dashboardRoute: (context) => const DashboardScreen(),
          AppConstants.profileRoute: (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
