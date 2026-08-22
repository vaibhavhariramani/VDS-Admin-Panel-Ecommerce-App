import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/storefront/storefront_config.dart';
import '../controllers/storefront_controller.dart';

class StoreDetailsView extends StatelessWidget {
  const StoreDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StorefrontController>();
    final details = controller.draft.value.storeDetails;
    final location = TextEditingController(text: details.location);
    final address = TextEditingController(text: details.address);
    final maps = TextEditingController(text: details.googleMapsUrl);
    final opening = TextEditingController(text: details.openingTime);
    final closing = TextEditingController(text: details.closingTime);
    final phone = TextEditingController(text: details.phoneNumber);
    return Scaffold(appBar: AppBar(title: const Text('Store Details')), body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('This information is available to the client app through the Store Information section.'),
      const SizedBox(height: 18),
      TextField(controller: location, decoration: const InputDecoration(labelText: 'Store location')),
      TextField(controller: address, minLines: 2, maxLines: 3, decoration: const InputDecoration(labelText: 'Address')),
      TextField(controller: maps, decoration: const InputDecoration(labelText: 'Google Maps link')),
      Row(children: [Expanded(child: TextField(controller: opening, decoration: const InputDecoration(labelText: 'Opening time'))), const SizedBox(width: 16), Expanded(child: TextField(controller: closing, decoration: const InputDecoration(labelText: 'Closing time')))]),
      TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number')),
      const SizedBox(height: 24),
      Obx(() => ElevatedButton(onPressed: controller.isSaving.value ? null : () async {
        controller.updateStoreDetails(StoreDetails(location: location.text.trim(), address: address.text.trim(), googleMapsUrl: maps.text.trim(), openingTime: opening.text.trim(), closingTime: closing.text.trim(), phoneNumber: phone.text.trim()));
        await controller.saveDraft();
      }, child: Text(controller.isSaving.value ? 'Saving...' : 'Save Draft'))),
    ]))));
  }
}
