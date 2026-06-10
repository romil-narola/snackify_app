import '../../../../core/common_imports.dart';

class AddEditSnackScreen extends StatefulWidget {
  final SnackModel? snack;

  const AddEditSnackScreen({super.key, this.snack});

  @override
  State<AddEditSnackScreen> createState() => _AddEditSnackScreenState();
}

class _AddEditSnackScreenState extends State<AddEditSnackScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imgController;
  String _category = 'Snacks';
  bool _available = true;

  final List<String> _categories = [
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
    final s = widget.snack;
    _nameController = TextEditingController(text: s?.name ?? '');
    _descController = TextEditingController(text: s?.description ?? '');
    _priceController = TextEditingController(text: s?.price.toString() ?? '');
    _imgController = TextEditingController(text: s?.imageUrl ?? '');
    if (s != null) {
      _category = s.category;
      _available = s.available;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imgController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final img = _imgController.text.trim().isNotEmpty
          ? _imgController.text.trim()
          : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=400';

      final snackItem = SnackModel(
        id:
            widget.snack?.id ??
            'snack-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        price: price,
        imageUrl: img,
        available: _available,
        createdAt: widget.snack?.createdAt ?? DateTime.now(),
        rating: widget.snack?.rating ?? 4.5,
        ingredients: widget.snack?.ingredients ?? const ['Premium ingredients'],
        galleryImages: widget.snack?.galleryImages ?? const [],
      );

      if (widget.snack == null) {
        context.read<AdminBloc>().add(AdminAddSnack(snackItem));
      } else {
        context.read<AdminBloc>().add(AdminUpdateSnack(snackItem));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.snack == null
                ? 'Snack added successfully!'
                : 'Snack updated successfully!',
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.snack == null ? 'Add New Snack' : 'Edit Snack Details',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Snack Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Snack Name',
                      prefixIcon: Icon(Icons.abc_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Enter snack name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Description
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price (\$)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter price';
                      if (double.tryParse(val) == null) {
                        return 'Enter a valid decimal number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Image URL
                  TextFormField(
                    controller: _imgController,
                    decoration: const InputDecoration(
                      labelText: 'Image Unsplash URL (Optional)',
                      prefixIcon: Icon(Icons.image_outlined),
                      hintText: 'Leave empty for default food image',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Selector Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _category = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Availability Toggle Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available in stock',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _available,
                        activeThumbColor: AppTheme.secondary,
                        onChanged: (val) {
                          setState(() {
                            _available = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Submit CTA
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      widget.snack == null ? 'Save & Publish' : 'Update Item',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
