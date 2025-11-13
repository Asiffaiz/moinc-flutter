import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:moinc/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:moinc/features/auth/data/services/auth_service.dart';
import 'package:moinc/features/auth/domain/repositories/auth_repository.dart';
import 'package:moinc/features/auth/network/api_client.dart';
import 'package:moinc/features/auth/services/token_service.dart';
import 'package:moinc/features/dashboard/data/Repositories/dashboard_repository_impl.dart';
import 'package:moinc/features/dashboard/data/services/dashboard_service.dart';
import 'package:moinc/features/dashboard/domain/Repositories/dashboard_repository.dart';
import 'package:moinc/features/profile/data/repositories/profile_repository.dart';
import 'package:moinc/features/profile/data/services/profile_service.dart';
import 'package:moinc/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:moinc/features/reports/data/services/reports_service.dart';
import 'package:moinc/features/reports/domain/repositories/reports_repository.dart';

// Set this to false to disable Firebase
const bool useFirebase = true;

final GetIt getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Register API Services
  getIt.registerLazySingleton(() => TokenService());
  getIt.registerLazySingleton(() => ApiClient());

  // Register AuthService
  getIt.registerLazySingleton(() => AuthService());

  // // Register AgreementService
  // getIt.registerLazySingleton(() => AgreementService());

  // // Register DashboardService
  getIt.registerLazySingleton(() => DashboardService());

  // // Register ReportsService
  getIt.registerLazySingleton(() => ReportsService());

  // // Register FormsService
  // getIt.registerLazySingleton(() => FormsService());

  // // Register DocumentService
  // getIt.registerLazySingleton(() => DocumentService());

  // // Register ProductService
  // getIt.registerLazySingleton(() => ProductService());

  // // Register ProfileService
  getIt.registerLazySingleton(() => ProfileService());

  // We'll register the GoRouter after the AuthBloc is created in main.dart
  // Don't register an empty GoRouter here as it will cause issues
  // getIt.registerLazySingleton(() => GoRouter(routes: []));

  // Firebase
  if (useFirebase) {
    // Firebase is already initialized in main.dart

    // External
    // getIt.registerLazySingleton(() => FirebaseAuth.instance);
    getIt.registerLazySingleton(
      () => GoogleSignIn(
        serverClientId:
            '670668615517-8l9qcinrhtgrfoagl2ioo6kneanmhm4d.apps.googleusercontent.com',
      ),
    );

    // Repositories
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        // firebaseAuth: getIt<FirebaseAuth>(),
        googleSignIn: getIt<GoogleSignIn>(),
        authService: getIt<AuthService>(),
      ),
    );
  }

  // getIt.registerLazySingleton<AgreementsRepository>(
  //   () => MockAgreementsRepositoryImpl(
  //     agreementsService: getIt<AgreementService>(),
  //   ),
  // );

  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(dashboardService: getIt<DashboardService>()),
  );

  getIt.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(reportsService: getIt<ReportsService>()),
  );

  // getIt.registerLazySingleton<FormsRepository>(
  //   () => FormsRepositoryImpl(formsService: getIt<FormsService>()),
  // );

  // getIt.registerLazySingleton<DocumentRepository>(() => DocumentRepository());

  // getIt.registerLazySingleton<ProductRepository>(() => ProductRepository());

  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository());

  // BLoCs
  getIt.registerFactory(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
      // agreementsRepository: getIt<AgreementsRepository>(),
    ),
  );

  // Initialize OpenAI API key
  // Replace with your actual API key or load from secure storage
  // var apiKey =
  //     "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";
  // OpenAIService.setApiKey(apiKey);

  // Services
  // getIt.registerLazySingleton<TextRecognitionService>(
  //   () => TextRecognitionService(),
  // );
}
