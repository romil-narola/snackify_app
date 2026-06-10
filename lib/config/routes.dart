import '../core/common_imports.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/employee',
        builder: (context, state) => const EmployeeMainContainer(),
      ),
      GoRoute(
        path: '/snack-detail',
        builder: (context, state) {
          final snack = state.extra as SnackModel;
          return SnackDetailScreen(snack: snack);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminMainContainer(),
      ),
      GoRoute(
        path: '/admin/add-edit-snack',
        builder: (context, state) {
          final snack = state.extra as SnackModel?;
          return AddEditSnackScreen(snack: snack);
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route error: ${state.error}'))),
  );
}
