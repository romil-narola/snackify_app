import '../../../../core/common_imports.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminReportsView extends StatefulWidget {
  const AdminReportsView({super.key});

  @override
  State<AdminReportsView> createState() => _AdminReportsViewState();
}

class _AdminReportsViewState extends State<AdminReportsView> {
  String _selectedRange = 'weekly';

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadReports(_selectedRange));
  }

  void _onRangeChanged(String? range) {
    if (range != null) {
      setState(() {
        _selectedRange = range;
      });
      context.read<AdminBloc>().add(LoadReports(range));
    }
  }

  void _exportSimulated(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exporting report as $type'),
        content: const Row(
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(width: 20),
            Text('Generating file...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Pop loading
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Complete!'),
            content: Text(
              'Report successfully exported as $type. Saved in Documents.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 12,
          left: 20,
          right: 20,
          bottom: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter Range controls & Export buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedRange,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Today')),
                    DropdownMenuItem(value: 'weekly', child: Text('This Week')),
                    DropdownMenuItem(
                      value: 'monthly',
                      child: Text('This Month'),
                    ),
                  ],
                  onChanged: _onRangeChanged,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: AppTheme.error,
                      ),
                      onPressed: () => _exportSimulated('PDF'),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.table_view_outlined,
                        color: AppTheme.success,
                      ),
                      onPressed: () => _exportSimulated('Excel'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is ReportLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Total sales bento
                      Row(
                        children: [
                          Expanded(
                            child: BentoCard(
                              icon: const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppTheme.primary,
                              ),
                              value: '${state.totalOrdersCount}',
                              title: MockDatabase().isStatusWise
                                  ? 'Orders Processed'
                                  : 'Orders Completed',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: BentoCard(
                              icon: const Icon(
                                Icons.attach_money_rounded,
                                color: AppTheme.success,
                              ),
                              value:
                                  '\$${state.totalSalesAmount.toStringAsFixed(2)}',
                              title: 'Sales Volume',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sales Bar Chart
                      BentoCard(
                        height: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sales Distribution Trend',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: BarChart(
                                BarChartData(
                                  borderData: FlBorderData(show: false),
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  barGroups: List.generate(
                                    state.chartData.length,
                                    (idx) {
                                      return BarChartGroupData(
                                        x: idx,
                                        barRods: [
                                          BarChartRodData(
                                            toY: state.chartData[idx],
                                            color: AppTheme.primary,
                                            width: 14,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category breakdown Pie Chart
                      BentoCard(
                        height: 220,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 40,
                                  sections: _buildPieSections(
                                    state.categorySales,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: state.categorySales.entries.map((
                                  entry,
                                ) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          color: _getCategoryColor(entry.key),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${entry.key} (\$${entry.value.toStringAsFixed(0)})',
                                            style: context.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> sales) {
    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.accent,
      Colors.blue,
      Colors.purple,
      Colors.orange,
    ];
    int idx = 0;

    return sales.entries.map((entry) {
      final color = colors[idx % colors.length];
      idx++;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        radius: 20,
        showTitle: false,
      );
    }).toList();
  }

  Color _getCategoryColor(String cat) {
    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.accent,
      Colors.blue,
      Colors.purple,
      Colors.orange,
    ];
    final categories = [
      'Tea',
      'Coffee',
      'Snacks',
      'Sandwiches',
      'Beverages',
      'Desserts',
    ];
    int idx = categories.indexOf(cat);
    if (idx == -1) idx = 0;
    return colors[idx % colors.length];
  }
}
