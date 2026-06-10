import '../../../../core/common_imports.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final _remarksController = TextEditingController();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _checkout(BuildContext context, CartState state) {
    if (state.items.isEmpty) return;

    // Dispatch place order event
    context.read<OrderBloc>().add(
      PlaceOrder(
        items: state.items,
        totalAmount: state.finalAmount,
        remarks: _remarksController.text.trim(),
      ),
    );

    // Clear cart
    context.read<CartBloc>().add(ClearCart());
    _remarksController.clear();

    // Show dynamic success dialogue
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppTheme.success,
                  size: 54,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Order Placed!',
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your snack request has been queued. You will be notified once the kitchen updates the status.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Back to Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 72,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.24)
                          : Colors.black.withValues(alpha: 0.24),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse menu items and select your bites',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Checkout Cart 🛒',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${state.items.length} items',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Items list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Dismissible(
                        key: Key('cart-${item.snack.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppTheme.error,
                            size: 28,
                          ),
                        ),
                        onDismissed: (dir) {
                          context.read<CartBloc>().add(
                            RemoveFromCart(item.snack.id),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.04),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.snack.imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 70,
                                        height: 70,
                                        color: AppTheme.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        child: const Icon(
                                          Icons.fastfood,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.snack.name,
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '\$${item.snack.price.toStringAsFixed(2)}',
                                      style: context.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // Counter Controls
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F172A)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_rounded,
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        context.read<CartBloc>().add(
                                          UpdateQuantity(
                                            item.snack.id,
                                            item.quantity - 1,
                                          ),
                                        );
                                      },
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        context.read<CartBloc>().add(
                                          UpdateQuantity(
                                            item.snack.id,
                                            item.quantity + 1,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Order checkout billing detail sticky section
                GlassContainer(
                  borderRadius: 28,
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 24,
                    right: 24,
                    bottom: 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Special Instructions / Remarks input
                      TextField(
                        controller: _remarksController,
                        decoration: const InputDecoration(
                          hintText:
                              'Any special instructions (e.g. extra spicy)...',
                          prefixIcon: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bill receipt list
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: context.textTheme.bodyMedium),
                          Text(
                            '\$${state.totalAmount.toStringAsFixed(2)}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (state.discount > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Office Subsidy Discount',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '-\$${state.discount.toStringAsFixed(2)}',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Service Charge / Tax (5%)',
                            style: context.textTheme.bodyMedium,
                          ),
                          Text(
                            '\$${state.tax.toStringAsFixed(2)}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '\$${state.finalAmount.toStringAsFixed(2)}',
                            style: context.textTheme.titleLarge?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _checkout(context, state),
                        child: const Text('Place Request'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
