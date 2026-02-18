import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeletons.dart';
import '../../categories/presentation/categories_providers.dart';
import '../../menu/presentation/menu_providers.dart';
import '../../menu/presentation/menu_item_detail_screen.dart';
import '../../promotions/presentation/promotions_providers.dart';
import '../../store/presentation/store_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  bool _canDecodeImageUrl(String url) {
    final lower = url.trim().toLowerCase();
    if (lower.isEmpty) return false;
    if (lower.startsWith('data:')) return false;
    if (lower.contains('.svg') || lower.endsWith('svg')) return false;
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeValue = ref.watch(storeProvider);
    final promotionsValue = ref.watch(promotionsProvider);
    final menuValue = ref.watch(menuProvider);
    final categoriesValue = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Affairs'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(storeProvider);
          ref.invalidate(promotionsProvider);
          ref.invalidate(menuProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search coffee',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: AsyncValueWidget(
                value: categoriesValue,
                loading: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, __) => const SkeletonBox(
                    height: 36,
                    width: 92,
                    radius: 999,
                  ),
                ),
                error: (err, st) => const SizedBox.shrink(),
                data: (categories) {
                  final items = categories.where((c) => c.isActive).toList();
                  if (items.isEmpty) return const SizedBox.shrink();

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return ChoiceChip(
                          label: const Text('All Coffee'),
                          selected: selectedCategoryId == null,
                          onSelected: (_) {
                            ref.read(selectedCategoryIdProvider.notifier).state =
                                null;
                            context.go('/menu');
                          },
                        );
                      }

                      final c = items[i - 1];
                      return ChoiceChip(
                        label: Text(c.name),
                        selected: selectedCategoryId == c.id,
                        onSelected: (_) {
                          ref.read(selectedCategoryIdProvider.notifier).state =
                              c.id;
                          context.go('/menu');
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            AsyncValueWidget(
              value: promotionsValue,
              loading: const SkeletonBox(height: 140),
              error: (err, st) => const SizedBox.shrink(),
              data: (promos) {
                final promo = promos.isNotEmpty ? promos.first : null;
                if (promo == null) return const SizedBox.shrink();

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: (promo.imageUrl != null &&
                                promo.imageUrl!.isNotEmpty &&
                                _canDecodeImageUrl(promo.imageUrl!))
                            ? CachedNetworkImage(
                                imageUrl: promo.imageUrl!,
                                fit: BoxFit.cover,
                                memCacheWidth: 1080,
                                memCacheHeight: 420,
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
                                filterQuality: FilterQuality.low,
                                errorWidget: (_, __, ___) => Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                ),
                              )
                            : Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                              ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.55),
                                Colors.black.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Promo',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              promo.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              promo.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.9)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            AsyncValueWidget(
              value: storeValue,
              loading: const _StoreSkeleton(),
              error: (err, st) => EmptyState(
                title: 'Could not load store info',
                message: err.toString(),
                onRetry: () => ref.invalidate(storeProvider),
              ),
              data: (store) {
                if (store == null) {
                  return const EmptyState(
                    title: 'Store info not available',
                    message: 'Please check back later.',
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        if (store.description.trim().isNotEmpty)
                          Text(
                            store.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                          ),
                        const SizedBox(height: 10),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          text: store.address,
                        ),
                        const SizedBox(height: 6),
                        _InfoRow(
                          icon: Icons.schedule,
                          text: store.openingHours,
                        ),
                        const SizedBox(height: 6),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          text: store.contactInfo,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Featured Menu',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            AsyncValueWidget(
              value: menuValue,
              loading: const SizedBox(height: 340, child: SkeletonList(itemCount: 4)),
              error: (err, st) => EmptyState(
                title: 'Could not load menu',
                message: err.toString(),
                onRetry: () => ref.invalidate(menuProvider),
              ),
              data: (items) {
                final featured = items.where((m) => m.isAvailable).take(4).toList();
                if (featured.isEmpty) {
                  return const EmptyState(
                    title: 'Menu not available',
                    message: 'Please check back later.',
                    icon: Icons.coffee_outlined,
                  );
                }

                return Column(
                  children: [
                    for (final item in featured)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              context.push(
                                '/menu/detail',
                                extra: MenuItemDetailArgs(item: item),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: SizedBox(
                                      height: 72,
                                      width: 72,
                                      child: (item.imageUrl != null &&
                                              item.imageUrl!.isNotEmpty &&
                                              _canDecodeImageUrl(item.imageUrl!))
                                          ? CachedNetworkImage(
                                              imageUrl: item.imageUrl!,
                                              fit: BoxFit.cover,
                                              memCacheWidth: 300,
                                              memCacheHeight: 300,
                                              fadeInDuration: Duration.zero,
                                              fadeOutDuration: Duration.zero,
                                              filterQuality: FilterQuality.low,
                                              errorWidget: (_, __, ___) =>
                                                  Container(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                child: const Icon(
                                                    Icons.image_not_supported),
                                              ),
                                            )
                                          : Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              child: const Icon(
                                                  Icons.coffee_rounded),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          formatMoney(item.price,
                                              currency: item.currency),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _StoreSkeleton extends StatelessWidget {
  const _StoreSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonBox(height: 18, width: 180, radius: 10),
            SizedBox(height: 12),
            SkeletonBox(height: 12, width: double.infinity, radius: 10),
            SizedBox(height: 8),
            SkeletonBox(height: 12, width: 260, radius: 10),
            SizedBox(height: 12),
            SkeletonBox(height: 12, width: double.infinity, radius: 10),
            SizedBox(height: 8),
            SkeletonBox(height: 12, width: double.infinity, radius: 10),
            SizedBox(height: 8),
            SkeletonBox(height: 12, width: 220, radius: 10),
          ],
        ),
      ),
    );
  }
}
