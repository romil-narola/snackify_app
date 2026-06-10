import '../../../../core/common_imports.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = [
    'All',
    'Pending',
    'Approved',
    'Preparing',
    'Ready',
    'Completed',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateStatus(BuildContext context, String orderId, String nextStatus) {
    context.read<AdminBloc>().add(
      AdminUpdateOrderStatus(orderId: orderId, status: nextStatus),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order $orderId updated to $nextStatus'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: isDark
                ? Colors.white.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.54),
            tabs: _statuses.map((status) => Tab(text: status)).toList(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminDashboardLoaded) {
                  final orders = state.orders;
                  if (orders.isEmpty) {
                    return const Center(child: Text('No orders received yet.'));
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: _statuses.map((status) {
                      final filtered = status == 'All'
                          ? orders
                          : orders
                                .where(
                                  (o) =>
                                      o.status.toLowerCase() ==
                                      status.toLowerCase(),
                                )
                                .toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            'No $status requests',
                            style: context.textTheme.bodyMedium,
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 40,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final order = filtered[index];
                          return _buildAdminOrderCard(context, order);
                        },
                      );
                    }).toList(),
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

  Widget _buildAdminOrderCard(BuildContext context, OrderModel order) {
    final isDark = context.isDarkMode;
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: context.theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    order.employeeName,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            subtitle: Text(order.id, style: context.textTheme.bodySmall),
            trailing: Text(
              '\$${order.totalAmount.toStringAsFixed(2)}',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Item list details
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.quantity}x  ${item.snack.name}',
                              style: context.textTheme.bodyLarge,
                            ),
                            Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: context.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (order.remarks.isNotEmpty) ...[
                      Text(
                        'Remarks: "${order.remarks}"',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Operations action control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: _buildActionButtons(context, order),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context, OrderModel order) {
    final status = order.status.toLowerCase();

    if (status == 'completed' || status == 'rejected') {
      return [
        Text(
          'Processing Completed',
          style: context.textTheme.labelLarge?.copyWith(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ];
    }

    List<Widget> buttons = [];

    // Reject Button (Available for Pending & Approved)
    if (status == 'pending' || status == 'approved') {
      buttons.add(
        OutlinedButton(
          onPressed: () => _updateStatus(context, order.id, 'rejected'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.error,
            side: const BorderSide(color: AppTheme.error, width: 1.5),
          ),
          child: const Text('Reject'),
        ),
      );
      buttons.add(const SizedBox(width: 12));
    }

    // Main action buttons sequence
    if (status == 'pending') {
      buttons.add(
        ElevatedButton(
          onPressed: () => _updateStatus(context, order.id, 'approved'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Approve'),
        ),
      );
    } else if (status == 'approved') {
      buttons.add(
        ElevatedButton(
          onPressed: () => _updateStatus(context, order.id, 'preparing'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Prepare'),
        ),
      );
    } else if (status == 'preparing') {
      buttons.add(
        ElevatedButton(
          onPressed: () => _updateStatus(context, order.id, 'ready'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Mark Ready'),
        ),
      );
    } else if (status == 'ready') {
      buttons.add(
        ElevatedButton(
          onPressed: () => _updateStatus(context, order.id, 'completed'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.success,
            foregroundColor: Colors.white,
          ),
          child: const Text('Mark Complete'),
        ),
      );
    }

    return buttons;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return AppTheme.secondary;
      case 'completed':
        return AppTheme.success;
      case 'rejected':
        return AppTheme.error;
      default:
        return Colors.grey;
    }
  }
}
