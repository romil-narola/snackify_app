import 'dart:io' show Platform;
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/common_imports.dart';

import 'services/mock_services.dart';
import 'services/firebase_services.dart';

final sl = GetIt.instance;

Future<void> init() async {
  bool isFirebaseAvailable = false;

  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Check if we are running in a unit/widget test to prevent Firebase initialization from hanging
    bool isTesting = false;
    if (!kIsWeb) {
      isTesting = Platform.environment.containsKey('FLUTTER_TEST');
    }

    if (isTesting) {
      throw Exception(
        'Running in test environment, skipping Firebase initialization.',
      );
    }

    // Attempt Firebase initialization
    await Firebase.initializeApp();
    isFirebaseAvailable = true;
    if (kDebugMode) {
      print(
        'Snakify: Firebase initialized successfully. Running in Cloud Database Mode.',
      );
    }
  } catch (e) {
    isFirebaseAvailable = false;
    if (kDebugMode) {
      print('Snakify: Firebase initialization skipped/failed: $e');
      print(
        'Snakify: Falling back to Local Mock Database Mode. App will be fully interactive.',
      );
    }
  }

  // Register Repositories (Conditional Injection)
  if (isFirebaseAvailable) {
    sl.registerLazySingleton<AuthRepository>(() => FirebaseAuthService());
    sl.registerLazySingleton<SnackRepository>(() => FirebaseSnackService());
    sl.registerLazySingleton<OrderRepository>(() => FirebaseOrderService());
    sl.registerLazySingleton<NotificationRepository>(
      () => FirebaseNotificationService(),
    );
    sl.registerLazySingleton<EmployeeRepository>(
      () => FirebaseEmployeeService(),
    );
  } else {
    sl.registerLazySingleton<AuthRepository>(() => MockAuthService());
    sl.registerLazySingleton<SnackRepository>(() => MockSnackService());
    sl.registerLazySingleton<OrderRepository>(() => MockOrderService());
    sl.registerLazySingleton<NotificationRepository>(
      () => MockNotificationService(),
    );
    sl.registerLazySingleton<EmployeeRepository>(() => MockEmployeeService());
  }

  // Register Blocs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(
    () => DashboardBloc(snackRepository: sl(), orderRepository: sl()),
  );
  sl.registerFactory(() => SnackBloc(snackRepository: sl()));
  sl.registerFactory(() => CartBloc());
  sl.registerFactory(
    () => OrderBloc(orderRepository: sl(), authRepository: sl()),
  );
  sl.registerFactory(
    () => NotificationBloc(notificationRepository: sl(), authRepository: sl()),
  );
  sl.registerFactory(() => ProfileBloc(authRepository: sl()));
  sl.registerFactory(
    () => AdminBloc(
      snackRepository: sl(),
      orderRepository: sl(),
      employeeRepository: sl(),
    ),
  );
}
