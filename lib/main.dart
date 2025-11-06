import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/core/dependency_injection.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:moinc/features/auth/presentation/bloc/user_cubit.dart';
import 'package:moinc/features/auth/presentation/signup_screen.dart';
import 'package:moinc/features/auth/services/token_service.dart';
import 'package:moinc/features/dashboard/domain/Repositories/dashboard_repository.dart';
import 'package:moinc/features/dashboard/presentation/bloc/bloc/dashboard_bloc.dart';
import 'package:moinc/features/home/home_screen.dart';
import 'package:moinc/features/auth/presentation/login_screen.dart';
import 'package:moinc/features/profile/presentation/screens/profile_screen.dart';
import 'package:moinc/features/reports/domain/repositories/reports_repository.dart';
import 'package:moinc/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:moinc/features/reports/presentation/screens/reports_screen.dart';

import 'package:moinc/features/splash_screen.dart';

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
        BlocProvider<ReportsBloc>(
          create:
              (context) =>
                  ReportsBloc(reportsRepository: GetIt.I<ReportsRepository>()),
        ),
        BlocProvider<DashboardBloc>(
          create:
              (context) => DashboardBloc(
                dashboardRepository: GetIt.I<DashboardRepository>(),
              ),
        ),
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

          AppConstants.dashboardRoute: (context) => const HomeScreen(),
          AppConstants.profileRoute: (context) => const ProfileScreen(),
          AppConstants.reportsRoute: (context) => const ReportsScreen(),
        },
      ),
    );
  }
}
