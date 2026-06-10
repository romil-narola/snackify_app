import '../../../../core/common_imports.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardView extends StatelessWidget {
  final Function(int) onTabChanged;

  const AdminDashboardView({super.key, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AdminBloc>().add(LoadAdminDashboard());
        },
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          child: BlocBuilder<AdminBloc, AdminState>(
            builder: (context, state) {
              if (state is AdminLoading || state is AdminInitial) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80.0),
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                );
              } else if (state is AdminDashboardLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome & Role Header
                    Text(
                      'Admin Dashboard ⚙️',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pantry Operations & Metrics',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bento Grid Layout
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.15,
                      children: [
                        BentoCard(
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppTheme.primary,
                          ),
                          value: '${state.orders.length}',
                          title: 'Total Requests',
                          onTap: () => onTabChanged(1), // Switch to Orders tab
                        ),
                        BentoCard(
                          icon: const Icon(
                            Icons.attach_money_rounded,
                            color: AppTheme.success,
                          ),
                          value: '\$${state.totalRevenue.toStringAsFixed(2)}',
                          title: 'Revenue Earned',
                          onTap: () => onTabChanged(4), // Switch to Reports tab
                        ),
                        BentoCard(
                          icon: const Icon(
                            Icons.pending_actions_rounded,
                            color: Colors.orange,
                          ),
                          value: '${state.pendingOrdersCount}',
                          title: 'Pending Orders',
                          subtitle: 'Awaiting Action',
                          onTap: () => onTabChanged(1),
                        ),
                        BentoCard(
                          icon: const Icon(
                            Icons.task_alt_rounded,
                            color: AppTheme.secondary,
                          ),
                          value: '${state.completedOrdersCount}',
                          title: 'Ready/Done Orders',
                          subtitle: 'Completed requests',
                          onTap: () => onTabChanged(1),
                        ),
                        BentoCard(
                          icon: const Icon(
                            Icons.cookie_outlined,
                            color: AppTheme.primary,
                          ),
                          value: '${state.snacks.length}',
                          title: 'Total Snacks',
                          subtitle: 'Items in catalog',
                          onTap: () =>
                              onTabChanged(2), // Switch to Snack manager
                        ),
                        BentoCard(
                          icon: const Icon(
                            Icons.people_outline_rounded,
                            color: Colors.blue,
                          ),
                          value: '${state.employees.length}',
                          title: 'Staff Directory',
                          subtitle: 'Registered users',
                          onTap: () =>
                              onTabChanged(3), // Switch to Employee manager
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Trends charts inside a Bento container
                    BentoCard(
                      height: 220,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Weekly Activity',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.trending_up,
                                color: AppTheme.success,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: 6,
                                minY: 0,
                                maxY: 10,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: const [
                                      FlSpot(0, 3),
                                      FlSpot(1, 4),
                                      FlSpot(2, 2.5),
                                      FlSpot(3, 7.5),
                                      FlSpot(4, 6),
                                      FlSpot(5, 8.5),
                                      FlSpot(6, 9),
                                    ],
                                    isCurved: true,
                                    color: AppTheme.primary,
                                    barWidth: 3,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppTheme.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else if (state is AdminError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
