import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../../constants/constants.dart';
import '../../../../../../models/Product.dart';
import '../../../../../../models/ProductDealType.dart';
import '../../../../../../themes/app_theme.dart';
import '../../../../../widgets/components/common_card.dart';

/// One card design for every product list in the admin panel. Replaces 5
/// near-identical, independently-maintained cards (MasterCard, ProductCard,
/// ScheduledProductCard, PublishedProductCard, HotDealProductCard) that
/// rendered the same fields with only cosmetic differences — see
/// docs/architecture/CURRENT_ARCHITECTURE.md.
class ProductListCard extends StatelessWidget {
  final Product product;
  final bool isPublishedNow;
  final bool isScheduled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onPublishedChanged;
  final bool isBusy;

  const ProductListCard({
    Key? key,
    required this.product,
    required this.isPublishedNow,
    required this.isScheduled,
    required this.onEdit,
    required this.onDelete,
    required this.onPublishedChanged,
    this.isBusy = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      elevation: 0,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                  child: CachedNetworkImage(
                    imageUrl: (product.img_token?.isNotEmpty ?? false) ? product.img_token! : noImg,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.white,
                      child: const Icon(Icons.image_not_supported_outlined, color: AppColors.grey),
                    ),
                  ),
                ),
                Positioned(top: 8, left: 8, child: _StatusBadge(published: isPublishedNow, scheduled: isScheduled)),
                if (product.deal_type == ProductDealType.HOTDEALS)
                  const Positioned(top: 8, right: 8, child: _HotDealBadge()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if ((product.category ?? '').toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      product.category.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '${product.currency_type ?? ''} ${(product.discount ?? product.price).toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (product.discount != null && product.discount != product.price) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${product.currency_type ?? ''} ${product.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.grey,
                            ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _ActionIcon(icon: Icons.edit_outlined, tooltip: 'Edit', onTap: isBusy ? null : onEdit),
                    _ActionIcon(
                      icon: Icons.delete_outline,
                      tooltip: 'Delete',
                      color: AppSemanticColors.danger,
                      onTap: isBusy ? null : onDelete,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: isBusy ? null : () => onPublishedChanged(!isPublishedNow),
                      child: Text(isPublishedNow ? 'Unpublish' : 'Publish'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool published;
  final bool scheduled;
  const _StatusBadge({required this.published, required this.scheduled});

  @override
  Widget build(BuildContext context) {
    final String label = published ? 'Published' : (scheduled ? 'Scheduled' : 'Draft');
    final Color color = published
        ? AppSemanticColors.success
        : (scheduled ? AppSemanticColors.warning : AppSemanticColors.neutral);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _HotDealBadge extends StatelessWidget {
  const _HotDealBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppSemanticColors.danger,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: Colors.white, size: 12),
          SizedBox(width: 2),
          Text('Hot Deal', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color? color;
  final VoidCallback? onTap;
  const _ActionIcon({required this.icon, required this.tooltip, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, size: 20, color: color ?? AppColors.grey),
      visualDensity: VisualDensity.compact,
    );
  }
}
