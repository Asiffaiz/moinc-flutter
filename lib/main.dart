import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/core/dependency_injection.dart';
import 'package:moinc/features/ai%20agent/app.dart';
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
import 'package:moinc/services/call_service.dart';
import 'package:provider/provider.dart';
import 'package:moinc/features/reports/presentation/screens/reports_screen.dart';

import 'package:moinc/features/splash_screen.dart';
import 'package:moinc/services/local_notification_service.dart';
import 'package:moinc/services/messaging_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/////////////

// Future<void> _backgroundHandler(RemoteMessage message) async {
//   if (kDebugMode) print("Handling background message: ${message.data}");

//   // if (message != null) {
//   //   handleNotificationNavigation(message.data);
//   // }
//   // LocalNotificationService.display(message);
//   // Process the incoming message and perform appropriate actions
// }

// void handleInitialMessage() async {
//   RemoteMessage? initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();
//   // if (initialMessage != null) {
//   //   handleNotificationNavigation(initialMessage.data);
//   // }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  MessagingServices();
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

  /////////////
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  // FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //   if (kDebugMode) print('User granted permission');
  // } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  //   if (kDebugMode) print('User granted provisional permission');
  // } else {
  //   if (kDebugMode) print('User declined or has not accepted permission');
  // }

  // FirebaseMessaging.instance.getToken().then((token) {
  //   if (kDebugMode) print("FCM Token: $token");
  //   // Store the token on your server for sending targeted messages
  //   Globals.firebaseToken = token!;
  // });

  MessagingServices();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CallService())],
      child: const MyApp(),
    ),
  );
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

          AppConstants.dashboardRoute:
              (context) => MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(value: appCtrl),
                  ChangeNotifierProvider.value(value: appCtrl.roomContext),
                ],
                child: const HomeScreen(),
              ),
          AppConstants.profileRoute: (context) => const ProfileScreen(),
          AppConstants.reportsRoute: (context) => const ReportsScreen(),
        },
      ),
    );
  }
}
