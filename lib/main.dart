import 'core/common_imports.dart';
import 'injection_container.dart' as di;
import 'config/routes.dart';

void main() async {
  // Initialize dependency injection and platforms
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => di.sl<AuthBloc>()),
        BlocProvider<CartBloc>(create: (context) => di.sl<CartBloc>()),
        BlocProvider<SnackBloc>(create: (context) => di.sl<SnackBloc>()),
        BlocProvider<DashboardBloc>(
          create: (context) => di.sl<DashboardBloc>(),
        ),
        BlocProvider<OrderBloc>(create: (context) => di.sl<OrderBloc>()),
        BlocProvider<NotificationBloc>(
          create: (context) => di.sl<NotificationBloc>(),
        ),
        BlocProvider<ProfileBloc>(create: (context) => di.sl<ProfileBloc>()),
        BlocProvider<AdminBloc>(create: (context) => di.sl<AdminBloc>()),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          // Determine active theme from ProfileState (Light vs Dark mode)
          final isDark = state.isDark;

          return MaterialApp.router(
            title: 'Snackify',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
