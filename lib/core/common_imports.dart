// Flutter Core
export 'package:flutter/material.dart';
export 'package:flutter/foundation.dart';

// State Management & Navigation
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:go_router/go_router.dart';

// Dependency Injection
export 'package:snackify_app/injection_container.dart' show sl;

// Theme
export 'package:snackify_app/core/theme/app_theme.dart';

// Common Custom Widgets
export 'package:snackify_app/core/widgets/bento_card.dart';
export 'package:snackify_app/core/widgets/floating_nav_bar.dart';
export 'package:snackify_app/core/widgets/glass_container.dart';

// Services Interfaces
export 'package:snackify_app/services/service_interface.dart';

// Core Models
export 'package:snackify_app/core/models/snack_model.dart';
export 'package:snackify_app/core/models/order_model.dart';
export 'package:snackify_app/core/models/user_model.dart';
export 'package:snackify_app/core/models/notification_model.dart';

// Blocs
export 'package:snackify_app/features/auth/presentation/bloc/auth_bloc.dart';
export 'package:snackify_app/features/cart/presentation/bloc/cart_bloc.dart';
export 'package:snackify_app/features/snacks/presentation/bloc/snack_bloc.dart';
export 'package:snackify_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
export 'package:snackify_app/features/orders/presentation/bloc/order_bloc.dart';
export 'package:snackify_app/features/notifications/presentation/bloc/notification_bloc.dart';
export 'package:snackify_app/features/profile/presentation/bloc/profile_bloc.dart';
export 'package:snackify_app/features/admin/presentation/bloc/admin_bloc.dart';

// Presentation View Screens
export 'package:snackify_app/features/auth/presentation/views/splash_screen.dart';
export 'package:snackify_app/features/auth/presentation/views/login_screen.dart';
export 'package:snackify_app/features/auth/presentation/views/forgot_password_screen.dart';
export 'package:snackify_app/features/auth/presentation/views/change_password_screen.dart';

export 'package:snackify_app/features/dashboard/presentation/views/employee_main_container.dart';
export 'package:snackify_app/features/dashboard/presentation/views/dashboard_view.dart';

export 'package:snackify_app/features/snacks/presentation/views/snack_menu_view.dart';
export 'package:snackify_app/features/snacks/presentation/views/snack_detail_screen.dart';

export 'package:snackify_app/features/cart/presentation/views/cart_view.dart';
export 'package:snackify_app/features/orders/presentation/views/orders_history_view.dart';
export 'package:snackify_app/features/profile/presentation/views/profile_view.dart';
export 'package:snackify_app/features/notifications/presentation/views/notifications_screen.dart';

export 'package:snackify_app/features/admin/presentation/views/admin_main_container.dart';
export 'package:snackify_app/features/admin/presentation/views/admin_dashboard_view.dart';
export 'package:snackify_app/features/admin/presentation/views/admin_snacks_view.dart';
export 'package:snackify_app/features/admin/presentation/views/add_edit_snack_screen.dart';
export 'package:snackify_app/features/admin/presentation/views/admin_orders_view.dart';
export 'package:snackify_app/features/admin/presentation/views/admin_employees_view.dart';
export 'package:snackify_app/features/admin/presentation/views/admin_reports_view.dart';
export 'package:snackify_app/core/widgets/ordering_window_banner.dart';
export 'package:snackify_app/features/admin/presentation/views/admin_combine_orders_view.dart';
export 'package:snackify_app/features/admin/presentation/views/admin_settings_view.dart';
export 'package:snackify_app/core/mock/mock_database.dart';
