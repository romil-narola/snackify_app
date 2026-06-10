import '../../../../core/common_imports.dart';

class DashboardView extends StatelessWidget {
  final Function(int) onTabChange;

  const DashboardView({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardBloc>().add(LoadDashboard(user.uid));
        },
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: 120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Personalized Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.name,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(user.profileImage),
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 2. Bento Actions Row
              Row(
                children: [
                  Expanded(
                    child: BentoCard(
                      gradient: const [
                        Color.fromARGB(255, 255, 166, 134),
                        Color.fromRGBO(255, 209, 192, 1),
                      ],
                      icon: const Icon(
                        Icons.flash_on_rounded,
                        color: Colors.white,
                      ),
                      title: 'Quick Order',
                      subtitle: 'Chai & Snacks',
                      onTap: () {
                        // Switch to snack menu tab
                        onTabChange(1);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: BentoCard(
                      gradient: const [
                        Color.fromARGB(255, 131, 213, 255),
                        Color.fromARGB(255, 202, 243, 255),
                      ],
                      icon: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                      ),
                      title: 'Order Status',
                      subtitle: 'Track live orders',
                      onTap: () {
                        // Switch to orders history tab
                        onTabChange(3);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 3. State-driven popular carousel & recommendations
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading || state is DashboardInitial) {
                    return _buildSkeletons();
                  } else if (state is DashboardLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Popular Items Section
                        if (state.popularSnacks.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Popular Today 🔥',
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextButton(
                                onPressed: () => onTabChange(1),
                                child: Text(
                                  'See All',
                                  style: context.textTheme.titleSmall?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.popularSnacks.length,
                              itemBuilder: (context, index) {
                                return _buildPopularCard(
                                  context,
                                  state.popularSnacks[index],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // Quick Reorder Section
                        if (state.recentOrders.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quick Reorder 🔄',
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextButton(
                                onPressed: () => onTabChange(3),
                                child: Text(
                                  'See All',
                                  style: context.textTheme.titleSmall?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.recentOrders.length,
                              itemBuilder: (context, index) {
                                return _buildRecentOrderCard(
                                  context,
                                  state.recentOrders[index],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // Recommendations Section
                        if (state.recommendedSnacks.isNotEmpty) ...[
                          Text(
                            'Recommended for You 🧑‍🍳',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.8,
                                ),
                            itemCount: state.recommendedSnacks.length,
                            itemBuilder: (context, index) {
                              return _buildRecommendedCard(
                                context,
                                state.recommendedSnacks[index],
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  } else if (state is DashboardError) {
                    return Center(
                      child: Text('Error loading dashboard: ${state.message}'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  Widget _buildPopularCard(BuildContext context, SnackModel snack) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: () => context.push('/snack-detail', extra: snack),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Product Image
              Image.network(
                snack.imageUrl,
                height: 180,
                width: 260,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.fastfood, color: AppTheme.primary),
                ),
              ),
              // Fade Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Rating Badge
              Positioned(
                top: 12,
                left: 12,
                child: GlassContainer(
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppTheme.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        snack.rating.toString(),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Description / details
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snack.name,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${snack.price.toStringAsFixed(2)}',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          snack.category,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Widget _buildRecommendedCard(BuildContext context, SnackModel snack) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: () => context.push('/snack-detail', extra: snack),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Hero(
                  tag: 'snack-image-${snack.id}',
                  child: Image.network(
                    snack.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.fastfood, color: AppTheme.primary),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snack.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${snack.price.toStringAsFixed(2)}',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppTheme.accent,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            snack.rating.toString(),
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrderCard(BuildContext context, OrderModel order) {
    final isDark = context.isDarkMode;
    final itemNames = order.items
        .map((item) => '${item.quantity}x ${item.snack.name}')
        .join(', ');

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  itemNames,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                for (var item in order.items) {
                  context.read<CartBloc>().add(
                    AddToCart(item.snack, quantity: item.quantity),
                  );
                }
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Reordered items added to cart!',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.success,
                    action: SnackBarAction(
                      label: 'VIEW CART',
                      textColor: Colors.white,
                      onPressed: () {
                        onTabChange(2);
                      },
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            itemBuilder: (context, index) => Container(
              width: 260,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
