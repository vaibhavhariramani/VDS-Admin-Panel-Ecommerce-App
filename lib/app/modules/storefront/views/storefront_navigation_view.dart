import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/storefront/storefront_config.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../controllers/storefront_controller.dart';

class StorefrontNavigationView extends StatelessWidget {
  const StorefrontNavigationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StorefrontController controller = Get.find<StorefrontController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Menu Item',
            onPressed: () => _showAddDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        final List<NavigationItem> items = controller.draft.value.navigation;
        if (items.isEmpty) {
          return const Center(child: Text('No menu items yet.', style: TextStyle(color: Colors.grey)));
        }
        return Column(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                onReorder: controller.reorderNavigation,
                itemBuilder: (context, index) {
                  final NavigationItem item = items[index];
                  return ListTile(
                    key: ValueKey('${item.label}_$index'),
                    title: Text(item.label),
                    subtitle: Text(
                        '${item.type}${item.referenceId.isNotEmpty ? ' → ${item.referenceId}' : ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.removeNavigationItemAt(index),
                        ),
                        const Icon(Icons.drag_handle),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedSubmitButton(
                buttonText: controller.isSaving.value ? 'Saving...' : 'Save Draft',
                width: 180,
                onPressed: controller.isSaving.value ? null : controller.saveDraft,
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showAddDialog(BuildContext context, StorefrontController controller) {
    final TextEditingController labelController = TextEditingController();
    final TextEditingController referenceController = TextEditingController();
    String type = predefinedNavigationTypes.first;
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Menu Item'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: 'Label'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Destination Type'),
                  items: predefinedNavigationTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => type = v ?? type),
                ),
                if (type == 'category' || type == 'collection' || type == 'page' || type == 'external') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: referenceController,
                    decoration: InputDecoration(
                      labelText: type == 'external' ? 'URL' : 'Reference (category/page/collection id)',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.trim().isEmpty) return;
                controller.addNavigationItem(NavigationItem(
                  label: labelController.text.trim(),
                  type: type,
                  referenceId: referenceController.text.trim(),
                ));
                Get.back();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
