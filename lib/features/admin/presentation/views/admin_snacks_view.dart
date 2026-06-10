import '../../../../core/common_imports.dart';

class AdminSnacksView extends StatelessWidget {
  const AdminSnacksView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/add-edit-snack'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Add Snack',
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminDashboardLoaded) {
            final snacks = state.snacks;
            if (snacks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cookie_outlined,
                      size: 64,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.24)
                          : Colors.black.withValues(alpha: 0.24),
                    ),
                    const SizedBox(height: 16),
                    const Text('No snacks in the catalog. Add one now!'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                top: 12,
                left: 20,
                right: 20,
                bottom: 90,
              ),
              itemCount: snacks.length,
              itemBuilder: (context, index) {
                final snack = snacks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
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
                          snack.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 60,
                                height: 60,
                                color: AppTheme.primary.withValues(alpha: 0.1),
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
                              snack.name,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${snack.price.toStringAsFixed(2)}',
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Availability Toggle switch
                      Column(
                        children: [
                          Text('Stock', style: context.textTheme.labelSmall),
                          Switch(
                            value: snack.available,
                            activeThumbColor: AppTheme.secondary,
                            onChanged: (val) {
                              context.read<AdminBloc>().add(
                                AdminUpdateSnack(
                                  snack.copyWith(available: val),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      // Actions (Edit/Delete)
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () =>
                            context.push('/admin/add-edit-snack', extra: snack),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.error,
                          size: 20,
                        ),
                        onPressed: () {
                          // Show delete confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Snack?'),
                              content: Text(
                                'Are you sure you want to remove ${snack.name} from catalog?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<AdminBloc>().add(
                                      AdminDeleteSnack(snack.id),
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Delete',
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        },
      ),
    );
  }
}
