import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeletons.dart';
import 'categories_providers.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  bool _activated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _activated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_activated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categoriesValue = ref.watch(categoriesProvider);
    final selectedId = ref.watch(selectedCategoryIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: AsyncValueWidget(
        value: categoriesValue,
        loading: const SkeletonList(itemCount: 7),
        error: (err, st) => EmptyState(
          title: 'Could not load categories',
          message: err.toString(),
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyState(
              title: 'No categories available',
              message: 'Please check back later.',
              icon: Icons.grid_view_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = categories[i];
              final isSelected = c.id == selectedId;

              return Card(
                child: ListTile(
                  title: Text(c.name),
                  trailing: isSelected
                      ? Icon(Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary)
                      : const Icon(Icons.chevron_right),
                  onTap: () {
                    ref.read(selectedCategoryIdProvider.notifier).state = c.id;
                    context.go('/menu');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
