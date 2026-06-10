import '../../../../core/common_imports.dart';

class OrdersHistoryView extends StatefulWidget {
  const OrdersHistoryView({super.key});

  @override
  State<OrdersHistoryView> createState() => _OrdersHistoryViewState();
}

class _OrdersHistoryViewState extends State<OrdersHistoryView>
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

    // Load orders
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<OrderBloc>().add(LoadOrders(authState.user.uid));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTrackingTimeline(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _OrderTrackingPanel(order: order);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Order Tracker ⏳',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppTheme.primary,
              labelColor: AppTheme.primary,
              unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
              tabs: _statuses.map((status) => Tab(text: status)).toList(),
            ),
            const SizedBox(height: 12),

            // Orders list based on states
            Expanded(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  } else if (state is OrdersLoaded) {
                    if (state.orders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 64,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.24)
                                  : Colors.black.withValues(alpha: 0.24),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No snack requests found',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: _statuses.map((status) {
                        final filtered = status == 'All'
                            ? state.orders
                            : state.orders
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
                            bottom: 120,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final order = filtered[index];
                            return _buildOrderCard(context, order);
                          },
                        );
                      }).toList(),
                    );
                  } else if (state is OrderOperationError) {
                    return Center(
                      child: Text('Error loading orders: ${state.message}'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
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
                    horizontal: 10,
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  order.id,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              _formatDate(order.orderDate),
              style: context.textTheme.bodySmall,
            ),
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
                    // Action tracking button
                    ElevatedButton.icon(
                      onPressed: () => _showTrackingTimeline(context, order),
                      icon: const Icon(
                        Icons.location_searching_rounded,
                        size: 18,
                      ),
                      label: const Text('Track Order Live'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        foregroundColor: AppTheme.primary,
                      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Live tracking sub-panel widget
class _OrderTrackingPanel extends StatelessWidget {
  final OrderModel order;

  const _OrderTrackingPanel({required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    // Status timeline sequence definition
    final steps = ['pending', 'approved', 'preparing', 'ready', 'completed'];
    int currentStep = steps.indexOf(order.status.toLowerCase());

    if (order.status.toLowerCase() == 'rejected') {
      currentStep = -1; // Special rejected state
    }

    return GlassContainer(
      borderRadius: 28,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Tracker',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('ID: ${order.id}', style: context.textTheme.bodySmall),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Custom Timeline tracking
          if (order.status.toLowerCase() == 'rejected') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel_rounded, color: AppTheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Snack Request Rejected',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: AppTheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.remarks.isNotEmpty
                              ? order.remarks
                              : 'Please contact admin for kitchen capacity info.',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppTheme.error.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Column(
              children: List.generate(steps.length, (idx) {
                final stepName = steps[idx];
                final isPassed = idx <= currentStep;
                final isCurrent = idx == currentStep;

                return _buildTimelineStep(
                  context,
                  title: _getStepTitle(stepName),
                  subtitle: _getStepSubtitle(stepName, order),
                  isPassed: isPassed,
                  isCurrent: isCurrent,
                  isLast: idx == steps.length - 1,
                );
              }),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isPassed,
    required bool isCurrent,
    required bool isLast,
  }) {
    final color = isPassed
        ? (isCurrent ? AppTheme.primary : AppTheme.success)
        : Colors.grey.withValues(alpha: 0.4);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic node
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? Colors.transparent : color,
                  border: isCurrent ? Border.all(color: color, width: 6) : null,
                ),
                child: isPassed && !isCurrent
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
              if (!isLast) Expanded(child: Container(width: 2.5, color: color)),
            ],
          ),
          const SizedBox(width: 16),
          // Text Node
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isPassed ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: context.textTheme.bodySmall),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(String step) {
    switch (step) {
      case 'pending':
        return 'Request Submitted';
      case 'approved':
        return 'Order Approved';
      case 'preparing':
        return 'In the Kitchen';
      case 'ready':
        return 'Ready for Pickup';
      case 'completed':
        return 'Received';
      default:
        return '';
    }
  }

  String _getStepSubtitle(String step, OrderModel order) {
    switch (step) {
      case 'pending':
        return 'Snack request sent to pantry administrator.';
      case 'approved':
        return order.approvedBy.isNotEmpty
            ? 'Approved by ${order.approvedBy}.'
            : 'Awaiting approval.';
      case 'preparing':
        return 'Chef is preparing your hot bites.';
      case 'ready':
        return 'Order is hot and ready. Collect at pantry counter!';
      case 'completed':
        return 'Successfully picked up.';
      default:
        return '';
    }
  }
}
