import '../../../../core/common_imports.dart';

class SnackDetailScreen extends StatefulWidget {
  final SnackModel snack;

  const SnackDetailScreen({super.key, required this.snack});

  @override
  State<SnackDetailScreen> createState() => _SnackDetailScreenState();
}

class _SnackDetailScreenState extends State<SnackDetailScreen> {
  int _quantity = 1;
  late String _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.snack.imageUrl;
  }

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final images = [widget.snack.imageUrl, ...widget.snack.galleryImages];

    return Scaffold(
      body: Stack(
        children: [
          // Scrollable details content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Sliver AppBar with Hero Image
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                stretch: true,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Hero(
                    tag: 'snack-image-${widget.snack.id}',
                    child: Image.network(_selectedImage, fit: BoxFit.cover),
                  ),
                ),
              ),

              // 2. Details body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 24,
                    right: 24,
                    bottom: 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Category
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.snack.name,
                                  style: context.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.snack.category,
                                    style: context.textTheme.labelMedium
                                        ?.copyWith(
                                          color: AppTheme.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${widget.snack.price.toStringAsFixed(2)}',
                                style: context.textTheme.headlineMedium
                                    ?.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppTheme.accent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.snack.rating.toString(),
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Gallery Thumbnails (if available)
                      if (images.length > 1) ...[
                        Text(
                          'Gallery',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, idx) {
                              final img = images[idx];
                              final isSelected = img == _selectedImage;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImage = img),
                                child: Container(
                                  width: 60,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(img),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Description
                      Text(
                        'Description',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.snack.description,
                        style: context.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Ingredients
                      if (widget.snack.ingredients.isNotEmpty) ...[
                        Text(
                          'Ingredients',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.snack.ingredients.map((ingredient) {
                            return Chip(
                              label: Text(ingredient),
                              backgroundColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.grey.shade100,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelStyle: context.textTheme.bodyMedium
                                  ?.copyWith(fontSize: 13),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. Sticky Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Quantity Counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded, size: 18),
                            onPressed: _decrement,
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Text(
                              '$_quantity',
                              key: ValueKey<int>(_quantity),
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 18),
                            onPressed: _increment,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Add to Cart CTA
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.snack.available
                            ? () {
                                context.read<CartBloc>().add(
                                  AddToCart(widget.snack, quantity: _quantity),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added $_quantity x ${widget.snack.name} to cart!',
                                    ),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            : null,
                        child: Text(
                          widget.snack.available
                              ? 'Add to Cart'
                              : 'Temporarily Out of Stock',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
