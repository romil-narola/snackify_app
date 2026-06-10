import '../../../../core/common_imports.dart';

class EmployeeMainContainer extends StatefulWidget {
  const EmployeeMainContainer({super.key});

  @override
  State<EmployeeMainContainer> createState() => _EmployeeMainContainerState();
}

class _EmployeeMainContainerState extends State<EmployeeMainContainer> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Preload dashboard and notification streams
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<DashboardBloc>().add(LoadDashboard(authState.user.uid));
      context.read<NotificationBloc>().add(
        LoadNotifications(authState.user.uid),
      );
    }
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      DashboardView(onTabChange: _onTabChange),
      const SnackMenuView(),
      const CartView(),
      const OrdersHistoryView(),
      const ProfileView(),
    ];

    return Scaffold(
      // Standard Transparent AppBar with Notification Bell Icon
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.fastfood_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Snakify',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          // Cart item badge shortcut (visible on dashboard/menu tabs)
          if (_currentIndex != 2)
            BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                if (cartState.items.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_bag_outlined),
                        onPressed: () => _onTabChange(2), // Jump to cart tab
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cartState.items.length}',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Real-time Notification Bell Badge
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is NotificationsLoaded) {
                unreadCount = state.notifications
                    .where((n) => !n.isRead)
                    .length;
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          // IndexedStack houses views to prevent tab reloading latency
          IndexedStack(index: _currentIndex, children: views),

          // Floating Navigation Bar Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: _onTabChange,
              items: const [
                FloatingNavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                ),
                FloatingNavBarItem(
                  icon: Icons.search_rounded,
                  activeIcon: Icons.search_rounded,
                  label: 'Catalog',
                ),
                FloatingNavBarItem(
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart_rounded,
                  label: 'Cart',
                ),
                FloatingNavBarItem(
                  icon: Icons.history_rounded,
                  activeIcon: Icons.history_rounded,
                  label: 'Track',
                ),
                FloatingNavBarItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
