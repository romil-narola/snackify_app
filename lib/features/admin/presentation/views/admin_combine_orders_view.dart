import '../../../../core/common_imports.dart';

class AdminCombineOrdersView extends StatefulWidget {
  final int? initialTabIndex;
  const AdminCombineOrdersView({super.key, this.initialTabIndex});

  @override
  State<AdminCombineOrdersView> createState() => _AdminCombineOrdersViewState();
}

class _AdminCombineOrdersViewState extends State<AdminCombineOrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );
  }

  @override
  void didUpdateWidget(AdminCombineOrdersView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != null &&
        widget.initialTabIndex != oldWidget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper class to hold combined order data
  List<_CombinedSnackGroup> _groupOrders(
    List<OrderModel> orders,
    bool isHistory,
  ) {
    final Map<String, _CombinedSnackGroup> grouped = {};

    // Filter by finality based on whether we are viewing history
    final db = MockDatabase();
    final filteredOrders = orders.where((o) {
      final status = o.status.toLowerCase();
      if (db.isStatusWise) {
        if (status == 'draft') return false;
        if (isHistory) {
          return status == 'completed' || status == 'rejected';
        } else {
          return status != 'completed' && status != 'rejected';
        }
      } else {
        if (isHistory) {
          return status == 'completed' || status == 'rejected';
        } else {
          return status == 'draft';
        }
      }
    }).toList();

    for (var order in filteredOrders) {
      for (var item in order.items) {
        final snackId = item.snack.id;
        if (grouped.containsKey(snackId)) {
          grouped[snackId]!.addOrder(order, item.quantity);
        } else {
          grouped[snackId] = _CombinedSnackGroup(
            snack: item.snack,
            initialOrder: order,
            initialQuantity: item.quantity,
          );
        }
      }
    }

    final list = grouped.values.toList();
    // Sort by total quantity descending
    list.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
    return list;
  }

  void _batchUpdateStatus(
    BuildContext context,
    _CombinedSnackGroup group,
    String nextStatus,
  ) {
    int updatedCount = 0;
    for (var order in group.orders) {
      bool canUpdate = false;
      final currentStatus = order.status.toLowerCase();

      if (MockDatabase().isStatusWise) {
        if (nextStatus == 'approved' || nextStatus == 'rejected') {
          canUpdate = currentStatus == 'pending';
        } else if (nextStatus == 'preparing') {
          canUpdate = currentStatus == 'approved' || currentStatus == 'pending';
        } else if (nextStatus == 'ready') {
          canUpdate = currentStatus == 'preparing';
        } else if (nextStatus == 'completed') {
          canUpdate = currentStatus == 'ready';
        }
      } else {
        if (nextStatus == 'completed') {
          canUpdate = currentStatus == 'draft';
        }
      }

      if (canUpdate) {
        context.read<AdminBloc>().add(
          AdminUpdateOrderStatus(orderId: order.id, status: nextStatus),
        );
        updatedCount++;
      }
    }

    if (updatedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Batch updated $updatedCount orders for ${group.snack.name} to ${nextStatus.toUpperCase()}',
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No orders of suitable state to update to $nextStatus'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final db = MockDatabase();

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: db.isStatusWise
                    ? 'Active Aggregations'
                    : 'Draft Aggregations',
              ),
              Tab(
                text: db.isStatusWise
                    ? 'Combined History'
                    : 'Completed History',
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGroupedList(context, isHistory: false),
                _buildGroupedList(context, isHistory: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList(BuildContext context, {required bool isHistory}) {
    final isDark = context.isDarkMode;
    final db = MockDatabase();

    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminDashboardLoaded) {
          final groupedList = _groupOrders(state.orders, isHistory);

          if (groupedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isHistory
                        ? Icons.history_toggle_off_rounded
                        : Icons.layers_clear_outlined,
                    size: 64,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isHistory
                        ? (db.isStatusWise
                              ? 'No past aggregated history'
                              : 'No completed history')
                        : (db.isStatusWise
                              ? 'No active orders to combine'
                              : 'No draft orders to combine'),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isHistory
                        ? (db.isStatusWise
                              ? 'Completed combined orders will appear here'
                              : 'Completed requests will appear here')
                        : (db.isStatusWise
                              ? 'Aggregated view will populate when orders are placed'
                              : 'Aggregated view of employee drafts will show here'),
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: 40,
            ),
            itemCount: groupedList.length,
            itemBuilder: (context, index) {
              final group = groupedList[index];
              return _buildCombinedCard(context, group, isHistory);
            },
          );
        }

        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        );
      },
    );
  }

  Widget _buildCombinedCard(
    BuildContext context,
    _CombinedSnackGroup group,
    bool isHistory,
  ) {
    final isDark = context.isDarkMode;

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
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                group.snack.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.fastfood,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
            title: Text(
              group.snack.name,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${group.orders.length} staff requests • ${group.snack.category}',
              style: context.textTheme.bodySmall,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Qty: ${group.totalQuantity}',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Text(
                      'Individual Demands:',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isHistory
                            ? (isDark ? Colors.white60 : Colors.black54)
                            : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // List of staff and quantities
                    ...group.orders.map((order) {
                      final quantity = group.orderQuantities[order.id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _getStatusBadge(order.status),
                                    const SizedBox(width: 8),
                                    Text(
                                      order.employeeName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'x$quantity',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (order.remarks.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  top: 2,
                                ),
                                child: Text(
                                  'Remarks: "${order.remarks}"',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    if (isHistory) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Aggregation State:',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final allRejected = group.orders.every(
                                (o) => o.status.toLowerCase() == 'rejected',
                              );
                              final badgeColor = allRejected
                                  ? AppTheme.error
                                  : AppTheme.success;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: badgeColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      allRejected
                                          ? Icons.cancel_outlined
                                          : Icons.check_circle_outline_rounded,
                                      color: badgeColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      allRejected ? 'REJECTED' : 'ARCHIVED',
                                      style: TextStyle(
                                        color: badgeColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        'Batch Processing Operations:',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Action controls row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: () {
                          final hasPending = group.orders.any(
                            (o) => o.status.toLowerCase() == 'pending',
                          );
                          final hasApproved = group.orders.any(
                            (o) => o.status.toLowerCase() == 'approved',
                          );
                          final hasPreparing = group.orders.any(
                            (o) => o.status.toLowerCase() == 'preparing',
                          );
                          final hasReady = group.orders.any(
                            (o) => o.status.toLowerCase() == 'ready',
                          );
                          final List<Widget> actionButtons = [];
                          final db = MockDatabase();

                          if (!db.isStatusWise) {
                            final hasDraft = group.orders.any(
                              (o) => o.status.toLowerCase() == 'draft',
                            );
                            if (hasDraft) {
                              actionButtons.add(
                                _buildCompactButton(
                                  icon: Icons.inventory_rounded,
                                  label: 'Complete Batch',
                                  color: AppTheme.success,
                                  isElevated: true,
                                  onPressed: () => _batchUpdateStatus(
                                    context,
                                    group,
                                    'completed',
                                  ),
                                ),
                              );
                            }
                          } else {
                            if (hasPending) {
                              actionButtons.add(
                                _buildCompactButton(
                                  icon: Icons.close_rounded,
                                  label: 'Reject',
                                  color: AppTheme.error,
                                  isElevated: false,
                                  onPressed: () => _batchUpdateStatus(
                                    context,
                                    group,
                                    'rejected',
                                  ),
                                ),
                              );
                              actionButtons.add(
                                _buildCompactButton(
                                  icon: Icons.check_rounded,
                                  label: 'Approve',
                                  color: Colors.blue,
                                  isElevated: true,
                                  onPressed: () => _batchUpdateStatus(
                                    context,
                                    group,
                                    'approved',
                                  ),
                                ),
                              );
                            }
                            if (hasApproved) {
                              actionButtons.add(
                                _buildCompactButton(
                                  icon: Icons.soup_kitchen_rounded,
                                  label: 'Prepare',
                                  color: Colors.purple,
                                  isElevated: true,
                                  onPressed: () => _batchUpdateStatus(
                                    context,
                                    group,
                                    'preparing',
                                  ),
                                ),
                              );
                            }
                            if (hasPreparing) {
                              actionButtons.add(
                                _buildCompactButton(
                                  icon: Icons.done_all_rounded,
                                  label: 'Ready',
                                  color: AppTheme.secondary,
                                  isElevated: true,
                                  onPressed: () => _batchUpdateStatus(
                                    context,
                                    group,
                                    'ready',
                                  ),
                                ),
                              );
                            }
                            if (hasReady) {
                              actionButtons.add(
                                _buildCompactButton(
                                  icon: Icons.inventory_rounded,
                                  label: 'Complete',
                                  color: AppTheme.success,
                                  isElevated: true,
                                  onPressed: () => _batchUpdateStatus(
                                    context,
                                    group,
                                    'completed',
                                  ),
                                ),
                              );
                            }
                          }

                          return actionButtons;
                        }(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'draft':
        color = Colors.blueGrey;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'approved':
        color = Colors.blue;
        break;
      case 'preparing':
        color = Colors.purple;
        break;
      case 'ready':
        color = AppTheme.secondary;
        break;
      case 'completed':
        color = AppTheme.success;
        break;
      case 'rejected':
        color = AppTheme.error;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompactButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isElevated,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: isElevated ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isElevated ? Colors.white : color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isElevated ? Colors.white : color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CombinedSnackGroup {
  final SnackModel snack;
  int totalQuantity;
  final List<OrderModel> orders;
  final Map<String, int> orderQuantities;

  _CombinedSnackGroup({
    required this.snack,
    required OrderModel initialOrder,
    required int initialQuantity,
  }) : totalQuantity = initialQuantity,
       orders = [initialOrder],
       orderQuantities = {initialOrder.id: initialQuantity};

  void addOrder(OrderModel order, int quantity) {
    totalQuantity += quantity;
    if (!orders.any((o) => o.id == order.id)) {
      orders.add(order);
    }
    orderQuantities[order.id] = (orderQuantities[order.id] ?? 0) + quantity;
  }
}
