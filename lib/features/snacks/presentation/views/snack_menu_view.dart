import '../../../../core/common_imports.dart';

class SnackMenuView extends StatefulWidget {
  const SnackMenuView({super.key});

  @override
  State<SnackMenuView> createState() => _SnackMenuViewState();
}

class _SnackMenuViewState extends State<SnackMenuView> {
  final _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'Tea',
    'Coffee',
    'Snacks',
    'Sandwiches',
    'Beverages',
    'Desserts',
  ];

  @override
  void initState() {
    super.initState();
    context.read<SnackBloc>().add(LoadSnacks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context, SnackLoaded state) {
    double min = state.minPrice;
    double max = state.maxPrice;
    bool avail = state.onlyAvailable;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Snacks',
                        style: context.textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Price Range',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RangeSlider(
                    values: RangeValues(min, max),
                    min: 0.0,
                    max: 20.0,
                    divisions: 40,
                    activeColor: AppTheme.primary,
                    inactiveColor: AppTheme.primary.withValues(alpha: 0.2),
                    labels: RangeLabels(
                      '\$${min.toStringAsFixed(2)}',
                      '\$${max.toStringAsFixed(2)}',
                    ),
                    onChanged: (values) {
                      setModalState(() {
                        min = values.start;
                        max = values.end;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${min.toStringAsFixed(2)}'),
                      Text('\$${max.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Show Only Available Items',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: avail,
                        activeThumbColor: AppTheme.primary,
                        onChanged: (val) {
                          setModalState(() {
                            avail = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      this.context.read<SnackBloc>().add(
                        FilterApplied(
                          minPrice: min,
                          maxPrice: max,
                          onlyAvailable: avail,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
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
            // Header + Search + Grid Toggle
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: 8,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Snack Catalog 🍔',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      BlocBuilder<SnackBloc, SnackState>(
                        builder: (context, state) {
                          if (state is SnackLoaded) {
                            return IconButton(
                              icon: Icon(
                                state.isGridView
                                    ? Icons.view_list_rounded
                                    : Icons.grid_view_rounded,
                                color: AppTheme.primary,
                              ),
                              onPressed: () {
                                context.read<SnackBloc>().add(ToggleViewMode());
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar with Filter option
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            context.read<SnackBloc>().add(
                              SearchQueryChanged(val),
                            );
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search delicious bites...',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      BlocBuilder<SnackBloc, SnackState>(
                        builder: (context, state) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.tune_rounded,
                                color: AppTheme.primary,
                              ),
                              onPressed: state is SnackLoaded
                                  ? () => _showFilterBottomSheet(context, state)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Category Chips Row
            BlocBuilder<SnackBloc, SnackState>(
              builder: (context, state) {
                final selected = state is SnackLoaded
                    ? state.selectedCategory
                    : 'All';
                return Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected =
                          cat.toLowerCase() == selected.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppTheme.primary,
                          labelStyle: context.textTheme.labelMedium?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            context.read<SnackBloc>().add(
                              CategorySelected(cat),
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Main Product Grid/List
            Expanded(
              child: BlocBuilder<SnackBloc, SnackState>(
                builder: (context, state) {
                  if (state is SnackLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  } else if (state is SnackLoaded) {
                    if (state.filteredSnacks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.no_food_outlined,
                              size: 64,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.24)
                                  : Colors.black.withValues(alpha: 0.24),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No snacks match your filters',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<SnackBloc>().add(LoadSnacks());
                      },
                      color: AppTheme.primary,
                      child: state.isGridView
                          ? GridView.builder(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 8,
                                bottom: 120,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.76,
                                  ),
                              itemCount: state.filteredSnacks.length,
                              itemBuilder: (context, index) {
                                return _buildSnackCard(
                                  context,
                                  state.filteredSnacks[index],
                                  true,
                                );
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 8,
                                bottom: 120,
                              ),
                              itemCount: state.filteredSnacks.length,
                              itemBuilder: (context, index) {
                                return _buildSnackCard(
                                  context,
                                  state.filteredSnacks[index],
                                  false,
                                );
                              },
                            ),
                    );
                  } else if (state is SnackError) {
                    return Center(
                      child: Text('Error loading catalog: ${state.message}'),
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

  Widget _buildSnackCard(BuildContext context, SnackModel snack, bool isGrid) {
    final isDark = context.isDarkMode;

    Widget cardBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Snack Image with Availability Badge
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  snack.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.fastfood, color: AppTheme.primary),
                  ),
                ),
              ),
              if (!snack.available)
                Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Center(
                    child: GlassContainer(
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        'Out of Stock',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Snack details
        Padding(
          padding: const EdgeInsets.all(12.0),
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
              const SizedBox(height: 2),
              Text(
                snack.category,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${snack.price.toStringAsFixed(2)}',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                  snack.available
                      ? Material(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 18,
                              color: AppTheme.primary,
                            ),
                            onPressed: () {
                              context.read<CartBloc>().add(AddToCart(snack));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${snack.name} added to cart!'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppTheme.success,
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (!isGrid) {
      // List Layout
      cardBody = Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  snack.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.fastfood, color: AppTheme.primary),
                  ),
                ),
              ),
              if (!snack.available)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Sold Out',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  snack.name,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(snack.category, style: context.textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(
                  '\$${snack.price.toStringAsFixed(2)}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (snack.available)
            ElevatedButton(
              onPressed: () {
                context.read<CartBloc>().add(AddToCart(snack));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${snack.name} added to cart!'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('Add'),
            ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => context.push('/snack-detail', extra: snack),
      child: Container(
        margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
        padding: isGrid ? EdgeInsets.zero : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: cardBody,
      ),
    );
  }
}
