import '../../../../core/common_imports.dart';

class AdminEmployeesView extends StatefulWidget {
  const AdminEmployeesView({super.key});

  @override
  State<AdminEmployeesView> createState() => _AdminEmployeesViewState();
}

class _AdminEmployeesViewState extends State<AdminEmployeesView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search staff by name or email...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),

          // Employees Directory list
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminDashboardLoaded) {
                  final filtered = state.employees.where((e) {
                    final matchesName = e.name.toLowerCase().contains(
                      _searchQuery,
                    );
                    final matchesEmail = e.email.toLowerCase().contains(
                      _searchQuery,
                    );
                    return matchesName || matchesEmail;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No employees found.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final employee = filtered[index];
                      return _buildEmployeeCard(context, employee);
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, UserModel employee) {
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(employee.profileImage),
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${employee.employeeId} • ${employee.department}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Active/Deactive Toggle
          Column(
            children: [
              Text(
                employee.isActive ? 'Active' : 'Inactive',
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: employee.isActive ? AppTheme.success : AppTheme.error,
                ),
              ),
              const SizedBox(height: 2),
              Switch(
                value: employee.isActive,
                activeThumbColor: AppTheme.success,
                inactiveThumbColor: AppTheme.error,
                onChanged: (val) {
                  context.read<AdminBloc>().add(
                    AdminToggleEmployeeActive(employee.uid, val),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${employee.name} is now ${val ? "Active" : "Deactivated"}',
                      ),
                      backgroundColor: val ? AppTheme.success : AppTheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
