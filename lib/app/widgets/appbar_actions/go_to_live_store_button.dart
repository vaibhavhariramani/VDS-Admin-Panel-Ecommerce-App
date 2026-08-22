import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/constants.dart';
import '../../modules/storefront/controllers/storefront_controller.dart';

/// Shown in the dashboard's persistent top app bar, always visible (global
/// action, left of the profile menu), once the signed-in Shop Admin's shop
/// actually has something published — lets the merchant jump straight to
/// their live storefront right after hitting Publish, instead of having to
/// go dig the URL out again. The Client App routes directly by `shopId`
/// (see `storefrontBaseUrl`), so there's nothing to "look up" here.
class GoToLiveStoreButton extends StatelessWidget {
  const GoToLiveStoreButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StorefrontController>()) return const SizedBox.shrink();
    final StorefrontController controller = Get.find<StorefrontController>();
    return Obx(() {
      final String? shopId = controller.shopId;
      final bool isLive = controller.published.value != null &&
          controller.published.value!.homepage.isNotEmpty;
      if (shopId == null || !isLive) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextButton.icon(
          onPressed: () async {
            final Uri uri = Uri.parse('$storefrontBaseUrl/$shopId');
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
          icon: const Icon(Icons.storefront, size: 18),
          label: const Text('Go to Live Store'),
        ),
      );
    });
  }
}
