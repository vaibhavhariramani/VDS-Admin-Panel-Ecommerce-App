import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/storefront/section_config.dart';
import '../../../../models/storefront/storefront_section.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../controllers/storefront_controller.dart';
import 'storefront_section_edit_dialog.dart';

class StorefrontHomepageView extends StatelessWidget {
  const StorefrontHomepageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StorefrontController controller = Get.find<StorefrontController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage Sections'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Section',
            onPressed: () => _showAddSectionSheet(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        final List<StorefrontSection> sections =
            List.of(controller.draft.value.homepage)..sort((a, b) => a.order.compareTo(b.order));
        if (sections.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No sections yet.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _showAddSectionSheet(context, controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Section'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sections.length,
                onReorder: controller.reorderSections,
                itemBuilder: (context, index) {
                  final StorefrontSection section = sections[index];
                  final SectionTypeInfo? info = sectionTypeRegistry[section.type];
                  return Card(
                    key: ValueKey(section.id),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(info?.icon ?? Icons.widgets_outlined),
                      title: Text(info?.displayName ?? section.type),
                      subtitle: Text(section.enabled ? 'Visible' : 'Hidden'),
                      onTap: () => Get.dialog(StorefrontSectionEditDialog(sectionId: section.id)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: section.enabled,
                            onChanged: (v) => controller.toggleSectionEnabled(section.id, v),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => controller.removeSection(section.id),
                          ),
                          const Icon(Icons.drag_handle),
                        ],
                      ),
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

  void _showAddSectionSheet(BuildContext context, StorefrontController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          childAspectRatio: 3,
          children: SectionType.all.map((type) {
            final SectionTypeInfo info = sectionTypeRegistry[type]!;
            return InkWell(
              onTap: () {
                controller.addSection(type);
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(info.icon, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(info.displayName, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
