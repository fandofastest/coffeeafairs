import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeletons.dart';
import '../../categories/presentation/categories_providers.dart';
import 'menu_item_detail_screen.dart';
import 'menu_providers.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final _scrollController = ScrollController();

  bool _activated = false;

  int _limit = 20;
  int _lastTotal = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _activated = true;
      });
    });
  }

  bool _canDecodeImageUrl(String url) {
    final lower = url.trim().toLowerCase();
    if (lower.isEmpty) return false;
    if (lower.startsWith('data:')) return false;
    if (lower.contains('.svg') || lower.endsWith('svg')) return false;
    return true;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;

    final nearBottom = position.pixels >= position.maxScrollExtent - 600;
    if (!nearBottom) return;

    if (_limit >= _lastTotal) return;

    setState(() {
      _limit = (_limit + 20).clamp(0, _lastTotal);
    });
  }

  void _resetLimit() {
    setState(() {
      _limit = 20;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_activated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final menuValue = ref.watch(menuProvider);
    final categoriesValue = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final query = ref.watch(menuSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search coffee',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                ref.read(menuSearchQueryProvider.notifier).state = v;
                _resetLimit();
              },
            ),
          ),
          SizedBox(
            height: 56,
            child: AsyncValueWidget(
              value: categoriesValue,
              loading: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, __) => const SkeletonBox(height: 36, width: 92, radius: 999),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: 4,
              ),
              error: (err, st) => const SizedBox.shrink(),
              data: (categories) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      final selected = selectedCategoryId == null;
                      return ChoiceChip(
                        label: const Text('All'),
                        selected: selected,
                        onSelected: (_) {
                          ref.read(selectedCategoryIdProvider.notifier).state = null;
                          _resetLimit();
                        },
                      );
                    }

                    final c = categories[i - 1];
                    final selected = selectedCategoryId == c.id;
                    return ChoiceChip(
                      label: Text(c.name),
                      selected: selected,
                      onSelected: (_) {
                        ref.read(selectedCategoryIdProvider.notifier).state = c.id;
                        _resetLimit();
                      },
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(menuProvider);
                _resetLimit();
              },
              child: AsyncValueWidget(
                value: menuValue,
                loading: const Center(child: CircularProgressIndicator()),
                error: (err, st) => EmptyState(
                  title: 'Could not load menu',
                  message: err.toString(),
                  onRetry: () => ref.invalidate(menuProvider),
                ),
                data: (items) {
                  final filtered = selectedCategoryId == null
                      ? items
                      : items.where((m) => m.categoryId == selectedCategoryId).toList();

                  final q = query.trim().toLowerCase();
                  final searched = q.isEmpty
                      ? filtered
                      : filtered
                          .where((m) =>
                              m.name.toLowerCase().contains(q) ||
                              m.description.toLowerCase().contains(q))
                          .toList();

                  final visible = searched.where((m) => m.isAvailable).toList();

                  _lastTotal = visible.length;
                  final shown = visible.take(_limit.clamp(0, _lastTotal)).toList();
                  final hasMore = shown.length < _lastTotal;

                  if (visible.isEmpty) {
                    return EmptyState(
                      title: 'No items found',
                      message: selectedCategoryId == null
                          ? 'Please check back later.'
                          : 'Try another category.',
                      icon: Icons.search_off,
                      onRetry: () => ref.invalidate(menuProvider),
                    );
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: shown.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (hasMore && i == shown.length) {
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                _limit = (_limit + 40).clamp(0, _lastTotal);
                              });
                            },
                            child: Center(
                              child: Text(
                                'Load more',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ),
                        );
                      }

                      final item = shown[i];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            context.push(
                              '/menu/detail',
                              extra: MenuItemDetailArgs(item: item),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 1.25,
                                child: (item.imageUrl != null &&
                                        item.imageUrl!.isNotEmpty &&
                                        _canDecodeImageUrl(item.imageUrl!))
                                    ? Image.network(
                                        item.imageUrl!,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.low,
                                        cacheWidth: 600,
                                        cacheHeight: 480,
                                        errorBuilder: (context, error, stack) {
                                          return Container(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            child: const Icon(
                                                Icons.image_not_supported_outlined),
                                          );
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Container(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        child: const Center(
                                          child: Icon(Icons.coffee_rounded),
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const SizedBox(height: 6),
                                    Flexible(
                                      child: Text(
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
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
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
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
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
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
