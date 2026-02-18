import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/money.dart';
import '../../menu/domain/menu_item.dart';
import '../../store/presentation/store_providers.dart';

class MenuItemDetailArgs {
  const MenuItemDetailArgs({required this.item});

  final MenuItem item;

  const MenuItemDetailArgs.empty()
      : item = const MenuItem(
          id: '',
          name: '',
          description: '',
          price: 0,
          currency: 'THB',
          imageUrl: null,
          categoryId: '',
          isAvailable: false,
        );
}

class MenuItemDetailScreen extends ConsumerStatefulWidget {
  const MenuItemDetailScreen({super.key, required this.args});

  final MenuItemDetailArgs args;

  @override
  ConsumerState<MenuItemDetailScreen> createState() =>
      _MenuItemDetailScreenState();
}

class _MenuItemDetailScreenState extends ConsumerState<MenuItemDetailScreen> {
  String _size = 'M';
  bool _liked = false;

  bool _canDecodeImageUrl(String url) {
    final lower = url.trim().toLowerCase();
    if (lower.isEmpty) return false;
    if (lower.startsWith('data:')) return false;
    if (lower.contains('.svg') || lower.endsWith('svg')) return false;
    return true;
  }

  String? _normalizePhoneDigits(String raw) {
    final digits = RegExp(r'\d+').allMatches(raw).map((m) => m.group(0)!).join();
    if (digits.isEmpty) return null;

    // Basic Thailand-friendly normalization: 0XXXXXXXXX -> 66XXXXXXXXX
    if (digits.startsWith('0') && digits.length >= 9) {
      return '66${digits.substring(1)}';
    }
    return digits;
  }

  Future<void> _buyNow(BuildContext context, MenuItem item) async {
    final storeValue = ref.read(storeProvider).valueOrNull;
    final phoneDigits =
        storeValue == null ? null : _normalizePhoneDigits(storeValue.contactInfo);

    final msg =
        'Hi Coffee Affairs, I want to order: ${item.name} (Size: $_size) - ${formatMoney(item.price, currency: item.currency)}.';

    if (phoneDigits != null && phoneDigits.isNotEmpty) {
      final waMe = Uri.parse(
          'https://wa.me/$phoneDigits?text=${Uri.encodeComponent(msg)}');
      final waScheme = Uri.parse(
          'whatsapp://send?phone=$phoneDigits&text=${Uri.encodeComponent(msg)}');
      final tel = Uri(scheme: 'tel', path: phoneDigits);

      try {
        if (await launchUrl(waMe, mode: LaunchMode.externalApplication)) {
          return;
        }
      } catch (_) {}

      try {
        if (await launchUrl(waScheme, mode: LaunchMode.externalApplication)) {
          return;
        }
      } catch (_) {}

      try {
        if (await launchUrl(tel, mode: LaunchMode.externalApplication)) {
          return;
        }
      } catch (_) {}
    }

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buy Now'),
        content: Text(
          phoneDigits == null
              ? 'Store contact is not available right now.\n\n${messagePreview(msg)}'
              : 'Could not open WhatsApp/Phone on this device.\n\n${messagePreview(msg)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String messagePreview(String msg) {
    if (msg.length <= 180) return msg;
    return '${msg.substring(0, 180)}...';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.args.item;

    if (item.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: const Center(child: Text('Item not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _liked = !_liked;
              });
            },
            icon: Icon(_liked ? Icons.favorite_rounded : Icons.favorite_border),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: (item.imageUrl != null &&
                          item.imageUrl!.isNotEmpty &&
                          _canDecodeImageUrl(item.imageUrl!))
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 1440,
                          memCacheHeight: 720,
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                          filterQuality: FilterQuality.low,
                          errorWidget: (_, __, ___) => Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.coffee_rounded, size: 44),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 18, color: Color(0xFFFFB300)),
                          const SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(230)',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.isAvailable ? 'Available' : 'Unavailable',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: item.isAvailable
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                         ),
                       ),
                      const SizedBox(height: 16),
                      Text(
                        'Size',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final s in const ['S', 'M', 'L'])
                            ChoiceChip(
                              label: Text(s),
                              selected: _size == s,
                              onSelected: (_) {
                                setState(() {
                                  _size = s;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatMoney(item.price,
                                      currency: item.currency),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 160,
                            child: FilledButton(
                              onPressed: item.isAvailable
                                  ? () => _buyNow(context, item)
                                  : null,
                              child: const Text('Buy Now'),
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
        ],
      ),
    );
  }
}
