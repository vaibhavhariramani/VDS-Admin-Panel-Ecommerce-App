import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/constants.dart';
import '../controllers/storefront_controller.dart';

/// The Client App routes directly by a shop's own Firestore doc id
/// (`storefrontBaseUrl/{shopId}`), so every shop already has a working
/// link — nothing to claim or set up. Kept as its own screen (rather than
/// removed) because a custom/vanity store code is a planned follow-up
/// (`StorefrontService.claimStoreCode`/`Shop.storeCode` already exist for
/// that, just not wired to any UI yet); this is where that flow will live.
class StorefrontUrlView extends StatelessWidget {
  const StorefrontUrlView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StorefrontController controller = Get.find<StorefrontController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Store URL'), elevation: 0),
      body: Obx(() {
        final String? shopId = controller.shopId;
        final String url = shopId != null ? '$storefrontBaseUrl/$shopId' : '';
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Store URL', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                SelectableText(url,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: shopId == null
                          ? null
                          : () async {
                              final Uri uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Open'),
                    ),
                    OutlinedButton.icon(
                      onPressed: shopId == null
                          ? null
                          : () {
                              Clipboard.setData(ClipboardData(text: url));
                              Get.snackbar('Copied', 'Store URL copied.',
                                  duration: const Duration(seconds: 3));
                            },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
                const Divider(height: 40),
                const Text(
                  'Custom store links',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your store URL is fixed to your shop ID for now. '
                  'Choosing a custom link (like /store/your-shop-name) is coming in a future update.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
