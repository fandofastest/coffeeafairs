import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeletons.dart';
import 'promotions_providers.dart';

class PromotionsScreen extends ConsumerWidget {
  const PromotionsScreen({super.key});

  bool _canDecodeImageUrl(String url) {
    final lower = url.trim().toLowerCase();
    if (lower.isEmpty) return false;
    if (lower.startsWith('data:')) return false;
    if (lower.contains('.svg') || lower.endsWith('svg')) return false;
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionsValue = ref.watch(promotionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(promotionsProvider);
        },
        child: AsyncValueWidget(
          value: promotionsValue,
          loading: const SkeletonList(itemCount: 8),
          error: (err, st) => EmptyState(
            title: 'Could not load promotions',
            message: err.toString(),
            onRetry: () => ref.invalidate(promotionsProvider),
          ),
          data: (promos) {
            if (promos.isEmpty) {
              return const EmptyState(
                title: 'No promotions right now',
                message: 'Check back soon for new deals.',
                icon: Icons.local_offer_outlined,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: promos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final p = promos[i];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.imageUrl != null &&
                          p.imageUrl!.isNotEmpty &&
                          _canDecodeImageUrl(p.imageUrl!))
                        SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: p.imageUrl!,
                            fit: BoxFit.cover,
                            memCacheWidth: 1080,
                            memCacheHeight: 480,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            filterQuality: FilterQuality.low,
                            errorWidget: (_, __, ___) => Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 160,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.local_offer_outlined),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
