import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/storefront/storefront_config.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../controllers/storefront_controller.dart';

class StorefrontPagesView extends StatelessWidget {
  const StorefrontPagesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StorefrontController controller = Get.find<StorefrontController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pages'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Page',
            onPressed: () => Get.dialog(const _PageEditDialog()),
          ),
        ],
      ),
      body: Obx(() {
        final List<CustomPage> pages = controller.draft.value.pages;
        if (pages.isEmpty) {
          return const Center(child: Text('No custom pages yet.', style: TextStyle(color: Colors.grey)));
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final CustomPage page = pages[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(page.title),
                      subtitle: Text('/${page.slug} — ${page.content.length} block(s)'),
                      onTap: () =>
                          Get.dialog(_PageEditDialog(page: page, replaceIndex: index)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => controller.removePageAt(index),
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
}

class _PageEditDialog extends StatefulWidget {
  final CustomPage? page;
  final int? replaceIndex;
  const _PageEditDialog({this.page, this.replaceIndex});

  @override
  State<_PageEditDialog> createState() => _PageEditDialogState();
}

class _PageEditDialogState extends State<_PageEditDialog> {
  late TextEditingController _title;
  late TextEditingController _slug;
  late List<PageBlock> _blocks;
  bool _slugEdited = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.page?.title ?? '');
    _slug = TextEditingController(text: widget.page?.slug ?? '');
    _blocks = List.of(widget.page?.content ?? const []);
    _slugEdited = widget.page != null;
  }

  String _slugify(String input) => input
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  @override
  Widget build(BuildContext context) {
    final StorefrontController controller = Get.find<StorefrontController>();
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.page == null ? 'Add Page' : 'Edit Page',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: StatefulBuilder(
                    builder: (context, setLocal) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _title,
                          decoration: const InputDecoration(labelText: 'Title'),
                          onChanged: (v) {
                            if (!_slugEdited) {
                              setLocal(() => _slug.text = _slugify(v));
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _slug,
                          decoration: const InputDecoration(labelText: 'Slug'),
                          onChanged: (_) => _slugEdited = true,
                        ),
                        const SizedBox(height: 16),
                        const Text('Content Blocks', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        ..._blocks.asMap().entries.map((entry) {
                          final int i = entry.key;
                          final PageBlock b = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  DropdownButton<String>(
                                    value: b.type,
                                    items: const ['heading', 'paragraph', 'image']
                                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                        .toList(),
                                    onChanged: (t) => setLocal(
                                        () => _blocks[i] = PageBlock(type: t ?? b.type, value: b.value)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: b.value,
                                      maxLines: b.type == 'paragraph' ? 3 : 1,
                                      decoration: InputDecoration(
                                        hintText: b.type == 'image' ? 'Image URL' : b.type,
                                      ),
                                      onChanged: (v) =>
                                          setLocal(() => _blocks[i] = PageBlock(type: b.type, value: v)),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => setLocal(() => _blocks.removeAt(i)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        TextButton.icon(
                          onPressed: () => setLocal(
                              () => _blocks.add(const PageBlock(type: 'paragraph', value: ''))),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Block'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      if (_title.text.trim().isEmpty || _slug.text.trim().isEmpty) return;
                      controller.savePage(
                        CustomPage(slug: _slug.text.trim(), title: _title.text.trim(), content: _blocks),
                        replaceIndex: widget.replaceIndex,
                      );
                      Get.back();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
