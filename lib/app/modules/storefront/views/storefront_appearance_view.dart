import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/storefront/storefront_config.dart';
import '../../../../services/data_service.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../controllers/storefront_controller.dart';
import 'storefront_theme_preview.dart';

/// Below this content width, there isn't room for the form and a live
/// preview side by side, so the preview panel is dropped rather than
/// squeezed - matches the desktop-only side panel behavior requested for
/// this screen (mobile/narrow web just gets the form, full width).
const double _previewBreakpoint = 900;

const List<String> _presetColors = [
  '#111827',
  '#2E7D32',
  '#1565C0',
  '#C62828',
  '#EF6C00',
  '#6A1B9A',
  '#00838F',
];

Color _colorFromHex(String hex) {
  final String cleaned = hex.replaceAll('#', '').padLeft(6, '0');
  return Color(int.parse('FF$cleaned', radix: 16));
}

class StorefrontAppearanceView extends StatefulWidget {
  const StorefrontAppearanceView({Key? key}) : super(key: key);

  @override
  State<StorefrontAppearanceView> createState() => _StorefrontAppearanceViewState();
}

class _StorefrontAppearanceViewState extends State<StorefrontAppearanceView> {
  final StorefrontController controller = Get.find<StorefrontController>();
  final DataService _dataService = DataService.to;

  late TextEditingController _storeName;
  late TextEditingController _tagline;
  final RxBool isUploadingLogo = false.obs;
  final RxBool isUploadingFavicon = false.obs;
  final RxBool isUploadingCover = false.obs;

  @override
  void initState() {
    super.initState();
    _storeName = TextEditingController(text: controller.draft.value.branding.storeName);
    _tagline = TextEditingController(text: controller.draft.value.branding.tagline);
  }

  @override
  void dispose() {
    _storeName.dispose();
    _tagline.dispose();
    super.dispose();
  }

  void _pushBranding(StorefrontBranding Function(StorefrontBranding) update) {
    controller.updateBranding(update(controller.draft.value.branding));
  }

  void _pushTheme(StorefrontTheme Function(StorefrontTheme) update) {
    controller.updateTheme(update(controller.draft.value.theme));
  }

  Future<void> _upload(RxBool loading, void Function(String url) onDone) async {
    loading(true);
    final String url = await _dataService.uploadImage(
        'storefront_${controller.shopId}_${DateTime.now().millisecondsSinceEpoch}');
    if (url.isNotEmpty) onDone(url);
    loading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Branding & Theme'), elevation: 0),
      body: Obx(() {
        final StorefrontBranding branding = controller.draft.value.branding;
        final StorefrontTheme theme = controller.draft.value.theme;
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool showPreview = constraints.maxWidth >= _previewBreakpoint;
            final Widget form = _buildForm(branding, theme);
            if (!showPreview) return form;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: form),
                Container(
                  width: 400,
                  height: constraints.maxHeight,
                  padding: const EdgeInsets.all(24),
                  color: Colors.grey.shade100,
                  child: Center(
                    child: SingleChildScrollView(
                      child: StorefrontThemePreview(branding: branding, theme: theme),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildForm(StorefrontBranding branding, StorefrontTheme theme) {
    return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Branding', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(
                  controller: _storeName,
                  decoration: const InputDecoration(labelText: 'Store Name'),
                  onChanged: (v) => _pushBranding((b) => b.copyWith(storeName: v)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tagline,
                  decoration: const InputDecoration(labelText: 'Tagline'),
                  onChanged: (v) => _pushBranding((b) => b.copyWith(tagline: v)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    _imagePicker('Logo', branding.logoUrl, isUploadingLogo,
                        (url) => _pushBranding((b) => b.copyWith(logoUrl: url))),
                    _imagePicker('Favicon', branding.faviconUrl, isUploadingFavicon,
                        (url) => _pushBranding((b) => b.copyWith(faviconUrl: url))),
                    _imagePicker('Cover Image', branding.coverImageUrl, isUploadingCover,
                        (url) => _pushBranding((b) => b.copyWith(coverImageUrl: url))),
                  ],
                ),
                const SizedBox(height: 28),
                const Text('Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _colorField('Primary Color', theme.primaryColor,
                    (hex) => _pushTheme((t) => t.copyWith(primaryColor: hex))),
                _colorField('Secondary Color', theme.secondaryColor,
                    (hex) => _pushTheme((t) => t.copyWith(secondaryColor: hex))),
                _colorField('Accent Color', theme.accentColor,
                    (hex) => _pushTheme((t) => t.copyWith(accentColor: hex))),
                _colorField('Background Color', theme.backgroundColor,
                    (hex) => _pushTheme((t) => t.copyWith(backgroundColor: hex))),
                _colorField('Text Color', theme.textColor,
                    (hex) => _pushTheme((t) => t.copyWith(textColor: hex))),
                const SizedBox(height: 16),
                Text('Border Radius: ${theme.borderRadius}'),
                Slider(
                  value: theme.borderRadius.toDouble(),
                  min: 0,
                  max: 30,
                  divisions: 30,
                  label: theme.borderRadius.toString(),
                  onChanged: (v) => _pushTheme((t) => t.copyWith(borderRadius: v.round())),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: theme.buttonStyle,
                  decoration: const InputDecoration(labelText: 'Button Style'),
                  items: predefinedButtonStyles
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) _pushTheme((t) => t.copyWith(buttonStyle: v));
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: theme.fontFamily,
                  decoration: const InputDecoration(labelText: 'Font Family'),
                  items: predefinedFontFamilies
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) _pushTheme((t) => t.copyWith(fontFamily: v));
                  },
                ),
                const SizedBox(height: 28),
                AnimatedSubmitButton(
                  buttonText: controller.isSaving.value ? 'Saving...' : 'Save Draft',
                  width: 180,
                  onPressed: controller.isSaving.value
                      ? null
                      : () async {
                          final bool success = await controller.saveDraft();
                          if (success && mounted) Navigator.pop(context);
                        },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
  }

  Widget _imagePicker(
      String label, String url, RxBool loading, void Function(String url) onDone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 6),
        Obx(
          () => GestureDetector(
            onTap: loading.value ? null : () => _upload(loading, onDone),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
                image: url.isNotEmpty
                    ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                    : null,
              ),
              child: loading.value
                  ? const Center(child: CircularProgressIndicator())
                  : url.isEmpty
                      ? const Icon(Icons.add_photo_alternate_outlined)
                      : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _colorField(String label, String currentHex, void Function(String hex) onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label)),
          ..._presetColors.map(
            (hex) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onPick(hex),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: _colorFromHex(hex),
                  child: currentHex.toUpperCase() == hex.toUpperCase()
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: currentHex,
              decoration: const InputDecoration(isDense: true),
              onFieldSubmitted: onPick,
            ),
          ),
        ],
      ),
    );
  }
}
