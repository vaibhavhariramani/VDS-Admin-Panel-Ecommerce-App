import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/Product.dart';
import '../../../../models/storefront/section_config.dart';
import '../../../../models/storefront/storefront_section.dart';
import '../../../../services/data_service.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../controllers/storefront_controller.dart';

/// Renders one section's edit form from its [FieldSpec] list — the same
/// dialog handles all 13 section types, driven entirely by the registry in
/// `section_config.dart`. `testimonials` is the one exception: its `items`
/// are a small repeater widget instead of a flat field.
class StorefrontSectionEditDialog extends StatefulWidget {
  final String sectionId;
  const StorefrontSectionEditDialog({Key? key, required this.sectionId}) : super(key: key);

  @override
  State<StorefrontSectionEditDialog> createState() => _StorefrontSectionEditDialogState();
}

class _StorefrontSectionEditDialogState extends State<StorefrontSectionEditDialog> {
  final StorefrontController controller = Get.find<StorefrontController>();
  final DataService _dataService = DataService.to;
  late StorefrontSection _section;
  late SectionTypeInfo _info;
  late Map<String, dynamic> _values;
  final Map<String, TextEditingController> _textControllers = {};
  List<TestimonialItem> _testimonials = [];
  final RxBool isUploadingImage = false.obs;

  @override
  void initState() {
    super.initState();
    _section = controller.draft.value.homepage.firstWhere((s) => s.id == widget.sectionId);
    _info = sectionTypeRegistry[_section.type]!;
    _values = Map<String, dynamic>.from(_section.config.toJson());
    if (_section.type == SectionType.testimonials) {
      _testimonials = (_section.config as TestimonialsSectionConfig).items.toList();
    }
    for (final FieldSpec spec in _info.fieldSpecs) {
      if (spec.kind == FieldKind.text || spec.kind == FieldKind.multiline) {
        _textControllers[spec.key] = TextEditingController(text: _values[spec.key]?.toString());
      }
    }
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_section.type == SectionType.testimonials) {
      _values['items'] = _testimonials.map((t) => t.toJson()).toList();
    }
    final config = _info.fromJson(_values);
    controller.updateSection(_section.id, config);
    Get.back();
  }

  Future<void> _pickImage(String key) async {
    isUploadingImage(true);
    final String url = await _dataService.uploadImage(
        'section_${_section.id}_${DateTime.now().millisecondsSinceEpoch}');
    if (url.isNotEmpty) setState(() => _values[key] = url);
    isUploadingImage(false);
  }

  Future<void> _pickProducts(String key) async {
    final List<Product> products = await controller.fetchPickableProducts();
    final List<String> current =
        (_values[key] as List<dynamic>? ?? const []).map((e) => e.toString()).toList();
    final List<String>? result = await Get.dialog<List<String>>(
      _MultiSelectDialog(
        title: 'Select Products',
        options: {for (final Product p in products) (p.barcode ?? p.id ?? p.name): p.name},
        initiallySelected: current,
      ),
    );
    if (result != null) setState(() => _values[key] = result);
  }

  Future<void> _pickCategories(String key) async {
    final List<String> categories = await controller.fetchDistinctCategories();
    final List<String> current =
        (_values[key] as List<dynamic>? ?? const []).map((e) => e.toString()).toList();
    final List<String>? result = await Get.dialog<List<String>>(
      _MultiSelectDialog(
        title: 'Select Categories',
        options: {for (final String c in categories) c: c},
        initiallySelected: current,
      ),
    );
    if (result != null) setState(() => _values[key] = result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit ${_info.displayName}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._info.fieldSpecs.map(_buildField),
                      if (_section.type == SectionType.testimonials) _buildTestimonialsRepeater(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AnimatedSubmitButton(
                    color: Colors.red,
                    width: 90,
                    buttonText: 'Cancel',
                    onPressed: () async => Get.back(),
                  ),
                  AnimatedSubmitButton(
                    width: 120,
                    buttonText: 'Save',
                    onPressed: () async => _save(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(FieldSpec spec) {
    switch (spec.kind) {
      case FieldKind.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextField(
            controller: _textControllers[spec.key],
            decoration: InputDecoration(labelText: spec.label),
            onChanged: (v) => _values[spec.key] = v,
          ),
        );
      case FieldKind.multiline:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextField(
            controller: _textControllers[spec.key],
            maxLines: 3,
            decoration: InputDecoration(labelText: spec.label),
            onChanged: (v) => _values[spec.key] = v,
          ),
        );
      case FieldKind.number:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
            initialValue: _values[spec.key]?.toString() ?? '0',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: spec.label),
            onChanged: (v) => _values[spec.key] = int.tryParse(v) ?? 0,
          ),
        );
      case FieldKind.boolean:
        return StatefulBuilder(
          builder: (context, setLocal) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(spec.label),
            value: _values[spec.key] == true,
            onChanged: (v) => setLocal(() => _values[spec.key] = v),
          ),
        );
      case FieldKind.image:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(spec.label, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              Obx(
                () => GestureDetector(
                  onTap: isUploadingImage.value ? null : () => _pickImage(spec.key),
                  child: Container(
                    width: 120,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                      image: (_values[spec.key]?.toString().isNotEmpty ?? false)
                          ? DecorationImage(
                              image: NetworkImage(_values[spec.key].toString()),
                              fit: BoxFit.cover)
                          : null,
                    ),
                    child: isUploadingImage.value
                        ? const Center(child: CircularProgressIndicator())
                        : (_values[spec.key]?.toString().isEmpty ?? true)
                            ? const Icon(Icons.add_photo_alternate_outlined)
                            : null,
                  ),
                ),
              ),
            ],
          ),
        );
      case FieldKind.productPicker:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: OutlinedButton.icon(
            onPressed: () => _pickProducts(spec.key),
            icon: const Icon(Icons.inventory_2_outlined, size: 16),
            label: Text(
                '${spec.label} (${(_values[spec.key] as List<dynamic>? ?? const []).length} selected)'),
          ),
        );
      case FieldKind.categoryPicker:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: OutlinedButton.icon(
            onPressed: () => _pickCategories(spec.key),
            icon: const Icon(Icons.category_outlined, size: 16),
            label: Text(
                '${spec.label} (${(_values[spec.key] as List<dynamic>? ?? const []).length} selected)'),
          ),
        );
    }
  }

  Widget _buildTestimonialsRepeater() {
    return StatefulBuilder(
      builder: (context, setLocal) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Testimonials', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          ..._testimonials.asMap().entries.map((entry) {
            final int i = entry.key;
            final TestimonialItem t = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: t.name,
                            decoration: const InputDecoration(labelText: 'Name'),
                            onChanged: (v) => setLocal(() => _testimonials[i] =
                                TestimonialItem(name: v, message: t.message, rating: t.rating)),
                          ),
                          TextFormField(
                            initialValue: t.message,
                            decoration: const InputDecoration(labelText: 'Message'),
                            onChanged: (v) => setLocal(() => _testimonials[i] =
                                TestimonialItem(name: t.name, message: v, rating: t.rating)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setLocal(() => _testimonials.removeAt(i)),
                    ),
                  ],
                ),
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => setLocal(
                () => _testimonials.add(const TestimonialItem(name: '', message: ''))),
            icon: const Icon(Icons.add),
            label: const Text('Add Testimonial'),
          ),
        ],
      ),
    );
  }
}

class _MultiSelectDialog extends StatefulWidget {
  final String title;
  final Map<String, String> options;
  final List<String> initiallySelected;
  const _MultiSelectDialog({
    required this.title,
    required this.options,
    required this.initiallySelected,
  });

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initiallySelected.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        height: 400,
        child: widget.options.isEmpty
            ? const Center(child: Text('Nothing available yet.'))
            : ListView(
                children: widget.options.entries
                    .map(
                      (e) => CheckboxListTile(
                        value: _selected.contains(e.key),
                        title: Text(e.value),
                        onChanged: (checked) => setState(() {
                          if (checked == true) {
                            _selected.add(e.key);
                          } else {
                            _selected.remove(e.key);
                          }
                        }),
                      ),
                    )
                    .toList(),
              ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Get.back(result: _selected.toList()),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
