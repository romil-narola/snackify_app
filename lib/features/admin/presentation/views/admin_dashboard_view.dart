import '../../../../core/common_imports.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardView extends StatelessWidget {
  final Function(int, {int? subTabIndex}) onTabChanged;

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
                final weeklyCounts = List<double>.filled(7, 0.0);
                for (var order in state.orders) {
                  if (order.status != 'draft') {
                    final dayIndex = order.orderDate.weekday - 1;
                    if (dayIndex >= 0 && dayIndex < 7) {
                      weeklyCounts[dayIndex] += 1;
                    }
                  }
                }
                final maxCount = weeklyCounts.reduce((a, b) => a > b ? a : b);
                final maxY = maxCount < 5 ? 5.0 : (maxCount + 2).toDouble();
                final lineChartSpots = List.generate(
                  7,
                  (i) => FlSpot(i.toDouble(), weeklyCounts[i]),
                );

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
                          onTap: () => onTabChanged(
                            1,
                            subTabIndex: 0,
                          ), // Switch to Orders tab (All)
                        ),
                        BentoCard(
                          icon: const Icon(
                            Icons.attach_money_rounded,
                            color: AppTheme.success,
                          ),
                          value: '\$${state.totalRevenue.toStringAsFixed(2)}',
                          title: 'Revenue Earned',
                          onTap: () => onTabChanged(
                            5,
                          ), // Switch to Reports tab (index 5)
                        ),
                        BentoCard(
                          icon: Icon(
                            state.isStatusWise
                                ? Icons.pending_actions_rounded
                                : Icons.drafts_outlined,
                            color: state.isStatusWise
                                ? Colors.orange
                                : Colors.blueGrey,
                          ),
                          value: '${state.pendingOrdersCount}',
                          title: state.isStatusWise
                              ? 'Pending Orders'
                              : 'Draft Orders',
                          subtitle: state.isStatusWise
                              ? 'Awaiting Action'
                              : 'Saved Drafts',
                          onTap: () => onTabChanged(
                            1,
                            subTabIndex: 1,
                          ), // Switch to Orders tab (Pending or Draft)
                        ),
                        BentoCard(
                          icon: const Icon(
                            Icons.task_alt_rounded,
                            color: AppTheme.secondary,
                          ),
                          value: '${state.completedOrdersCount}',
                          title: state.isStatusWise
                              ? 'Ready/Done Orders'
                              : 'Completed Orders',
                          subtitle: 'Completed requests',
                          onTap: () => onTabChanged(
                            1,
                            subTabIndex: state.isStatusWise ? 5 : 2,
                          ), // Switch to Completed tab
                        ),
                        BentoCard(
                          icon: const Icon(
                            Icons.cookie_outlined,
                            color: AppTheme.primary,
                          ),
                          value: '${state.snacks.length}',
                          title: 'Total Snacks',
                          subtitle: 'Items in catalog',
                          onTap: () => onTabChanged(
                            3,
                          ), // Switch to Snack manager (index 3)
                        ),
                        BentoCard(
                          icon: const Icon(
                            Icons.people_outline_rounded,
                            color: Colors.blue,
                          ),
                          value: '${state.employees.length}',
                          title: 'Staff Directory',
                          subtitle: 'Registered users',
                          onTap: () => onTabChanged(
                            4,
                          ), // Switch to Employee manager (index 4)
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Trends charts inside a Bento container
                    BentoCard(
                      height: 250,
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
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.withValues(
                                        alpha: 0.15,
                                      ),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    tooltipRoundedRadius: 8,
                                    tooltipBgColor: AppTheme.primary.withValues(
                                      alpha: 0.9,
                                    ),
                                    getTooltipItems: (touchedSpots) {
                                      return touchedSpots.map((spot) {
                                        return LineTooltipItem(
                                          '${spot.y.toInt()} orders',
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      interval: maxY <= 5
                                          ? 1.0
                                          : (maxY <= 10
                                                ? 2.0
                                                : (maxY / 5).roundToDouble()),
                                      getTitlesWidget: (value, meta) {
                                        if (value % 1 != 0) {
                                          return const SizedBox.shrink();
                                        }
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(
                                            value.toInt().toString(),
                                            style: context.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 22,
                                      getTitlesWidget: (value, meta) {
                                        const days = [
                                          'Mon',
                                          'Tue',
                                          'Wed',
                                          'Thu',
                                          'Fri',
                                          'Sat',
                                          'Sun',
                                        ];
                                        final index = value.toInt();
                                        String label = '';
                                        if (index >= 0 && index < days.length) {
                                          label = days[index];
                                        }
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(
                                            label,
                                            style: context.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                minX: 0,
                                maxX: 6,
                                minY: 0,
                                maxY: maxY,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: lineChartSpots,
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
