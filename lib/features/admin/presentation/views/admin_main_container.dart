import '../../../../core/common_imports.dart';

class AdminMainContainer extends StatefulWidget {
  const AdminMainContainer({super.key});

  @override
  State<AdminMainContainer> createState() => _AdminMainContainerState();
}

class _AdminMainContainerState extends State<AdminMainContainer> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadAdminDashboard());
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      AdminDashboardView(onTabChanged: _onTabChanged),
      const AdminOrdersView(),
      const AdminSnacksView(),
      const AdminEmployeesView(),
      const AdminReportsView(),
    ];

    final titles = [
      'Overview Console',
      'Order Processings',
      'Inventory Catalog',
      'Staff Directory',
      'Business Reports',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/login');
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      // Drawer navigation for admin menu
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.primary),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppTheme.primary,
                  size: 36,
                ),
              ),
              accountName: Text(
                'Snakify Admin Panel',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                context.watch<AuthBloc>().state is Authenticated
                    ? (context.watch<AuthBloc>().state as Authenticated)
                          .user
                          .email
                    : 'admin@snakify.com',
              ),
            ),
            _buildDrawerTile(0, 'Dashboard Overview', Icons.dashboard_outlined),
            _buildDrawerTile(
              1,
              'Order Processings',
              Icons.receipt_long_rounded,
            ),
            _buildDrawerTile(2, 'Snack Management', Icons.fastfood_rounded),
            _buildDrawerTile(
              3,
              'Employee Directory',
              Icons.people_outline_rounded,
            ),
            _buildDrawerTile(
              4,
              'Operations Reports',
              Icons.pie_chart_outline_rounded,
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppTheme.error),
              title: Text(
                'Log Out',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                context.read<AuthBloc>().add(LogoutRequested());
                context.go('/login');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      body: views[_currentIndex],
    );
  }

  Widget _buildDrawerTile(int index, String label, IconData icon) {
    final isSelected = index == _currentIndex;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey),
      title: Text(
        label,
        style: context.textTheme.bodyLarge?.copyWith(
          color: isSelected ? AppTheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        _onTabChanged(index);
        Navigator.pop(context); // Close drawer
      },
    );
  }
}
