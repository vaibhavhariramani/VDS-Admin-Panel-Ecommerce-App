import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/storefront/storefront_config.dart';
import '../../../../services/data_service.dart';
import '../controllers/storefront_controller.dart';

/// Edits the banner slides consumed by both the client-app hero carousel and
/// the `banners` navigation destination.
class StorefrontBannersView extends StatelessWidget {
  const StorefrontBannersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StorefrontController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Banners'), actions: [
        IconButton(icon: const Icon(Icons.add), tooltip: 'Add banner', onPressed: () => _edit(context, controller)),
      ]),
      body: Obx(() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('These banners appear in the client app hero section and when shoppers choose Banners in the storefront navigation.'),
          const SizedBox(height: 16),
          if (controller.draft.value.banners.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No banners yet.'))),
          ...controller.draft.value.banners.map((banner) => Card(child: ListTile(
            leading: banner.imageUrl.isEmpty ? const Icon(Icons.image_outlined) : ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(banner.imageUrl, width: 64, height: 44, fit: BoxFit.cover)),
            title: Text(banner.title.isEmpty ? 'Untitled banner' : banner.title),
            subtitle: Text('${banner.subtitle}\nDestination: ${banner.action}'),
            isThreeLine: true,
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Switch(value: banner.enabled, onChanged: (value) => controller.saveBanner(banner.copyWith(enabled: value))),
              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context, controller, banner)),
              IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => controller.removeBanner(banner.id)),
            ]),
          ))),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: controller.isSaving.value ? null : controller.saveDraft, child: Text(controller.isSaving.value ? 'Saving...' : 'Save Draft')),
        ],
      )),
    );
  }

  Future<void> _edit(BuildContext context, StorefrontController controller, [StorefrontBanner? existing]) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final subtitle = TextEditingController(text: existing?.subtitle ?? '');
    final action = TextEditingController(text: existing?.action ?? 'products');
    String imageUrl = existing?.imageUrl ?? '';
    bool enabled = existing?.enabled ?? true;
    await Get.dialog(StatefulBuilder(builder: (context, setState) => AlertDialog(
      title: Text(existing == null ? 'Add Banner' : 'Edit Banner'),
      content: SizedBox(width: 440, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
        TextField(controller: subtitle, decoration: const InputDecoration(labelText: 'Subtitle')),
        TextField(controller: action, decoration: const InputDecoration(labelText: 'Destination (for example: products, category id, or URL)')),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text(imageUrl.isEmpty ? 'No banner image selected' : 'Banner image selected', overflow: TextOverflow.ellipsis)),
          TextButton.icon(icon: const Icon(Icons.upload_outlined), label: const Text('Upload'), onPressed: () async {
            final uploaded = await DataService.to.uploadImage('storefront_banner_${DateTime.now().millisecondsSinceEpoch}');
            if (uploaded.isNotEmpty) setState(() => imageUrl = uploaded);
          }),
        ]),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Visible to customers'), value: enabled, onChanged: (value) => setState(() => enabled = value)),
      ]))),
      actions: [TextButton(onPressed: Get.back, child: const Text('Cancel')), ElevatedButton(onPressed: () {
        controller.saveBanner(StorefrontBanner(id: existing?.id ?? 'banner_${DateTime.now().microsecondsSinceEpoch}', title: title.text.trim(), subtitle: subtitle.text.trim(), imageUrl: imageUrl, action: action.text.trim(), enabled: enabled));
        Get.back();
      }, child: const Text('Save'))],
    )));
  }
}
