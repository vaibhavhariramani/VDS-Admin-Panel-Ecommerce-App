import 'package:flutter/material.dart';

import '../../../../models/storefront/storefront_config.dart';

Color colorFromHex(String hex, {Color fallback = Colors.black}) {
  final String cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return fallback;
  return Color(int.parse('FF$cleaned', radix: 16));
}

double _radiusFor(StorefrontTheme theme) {
  switch (theme.buttonStyle) {
    case 'pill':
      return 999;
    case 'square':
      return 0;
    default:
      return theme.borderRadius.toDouble();
  }
}

/// Small device-frame mock showing the branding header plus a couple of
/// themed sample elements (a product card, primary/secondary buttons) so a
/// color/font/radius change is visible immediately, without needing the
/// full homepage section list from `StorefrontPreviewView`.
class StorefrontThemePreview extends StatelessWidget {
  final StorefrontBranding branding;
  final StorefrontTheme theme;
  const StorefrontThemePreview({Key? key, required this.branding, required this.theme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bg = colorFromHex(theme.backgroundColor, fallback: Colors.white);
    final Color text = colorFromHex(theme.textColor);
    final Color primary = colorFromHex(theme.primaryColor);
    final Color secondary = colorFromHex(theme.secondaryColor);
    final double buttonRadius = _radiusFor(theme);
    final double cardRadius = theme.borderRadius.toDouble();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 6),
        color: bg,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            color: primary.withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: primary,
                  backgroundImage:
                      branding.logoUrl.isNotEmpty ? NetworkImage(branding.logoUrl) : null,
                  child: branding.logoUrl.isEmpty
                      ? Text(
                          branding.storeName.isNotEmpty ? branding.storeName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branding.storeName.isEmpty ? 'Your Store' : branding.storeName,
                        style: TextStyle(fontWeight: FontWeight.bold, color: text),
                      ),
                      if (branding.tagline.isNotEmpty)
                        Text(
                          branding.tagline,
                          style: TextStyle(fontSize: 12, color: text.withOpacity(0.7)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (branding.coverImageUrl.isNotEmpty)
            Image.network(
              branding.coverImageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sample Product',
                  style: TextStyle(color: text, fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(cardRadius),
                  ),
                  child: Icon(Icons.image_outlined, color: secondary.withOpacity(0.6), size: 32),
                  alignment: Alignment.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Shop Now'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Learn More'),
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
