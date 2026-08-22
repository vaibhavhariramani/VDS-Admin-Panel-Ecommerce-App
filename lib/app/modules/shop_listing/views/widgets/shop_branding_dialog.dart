import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../constants/constants.dart';
import '../../../../../models/Shop.dart';
import '../../../../../services/data_service.dart';
import '../../../../../services/update_data.dart';
import '../../../../widgets/components/animated_submit_button.dart';

/// Lets an admin edit a shop's name/contact info and storefront branding
/// (logo, banner images, accent color). Everything saved here writes to
/// the same `Shops` doc the client app reads, so once the client app is
/// updated to read `imgToken` / `bannerUrls` / `brandColor` these changes
/// show up there automatically.
class ShopBrandingDialog extends StatefulWidget {
  final Shop shop;
  final VoidCallback onSaved;

  const ShopBrandingDialog({
    Key? key,
    required this.shop,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<ShopBrandingDialog> createState() => _ShopBrandingDialogState();
}

const List<String> _presetBrandColors = [
  '#2E7D32',
  '#1565C0',
  '#C62828',
  '#EF6C00',
  '#6A1B9A',
  '#00838F',
  '#37474F',
];

class _ShopBrandingDialogState extends State<ShopBrandingDialog> {
  final DataService _dataService = DataService.to;
  final RxBool isUploadingLogo = false.obs;
  final RxBool isUploadingBanner = false.obs;
  final RxBool isSaving = false.obs;
  late final RxString logoUrl = (widget.shop.img_token ?? '').obs;
  late final RxList<String> bannerUrls =
      RxList<String>(List<String>.from(widget.shop.bannerUrls ?? const []));
  late final RxString brandColor =
      (widget.shop.brandColor ?? _presetBrandColors.first).obs;

  late final TextEditingController _nameController =
      TextEditingController(text: widget.shop.name ?? '');
  late final TextEditingController _aboutController =
      TextEditingController(text: widget.shop.about ?? '');
  late final TextEditingController _phoneController =
      TextEditingController(text: widget.shop.phn_number ?? '');
  late final TextEditingController _addressController =
      TextEditingController(text: widget.shop.phy_address ?? '');

  Color _colorFromHex(String hex) {
    final String cleaned = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  Future<void> _pickLogo() async {
    isUploadingLogo(true);
    final String url = await _dataService.uploadImage(
      'shop_logo_${widget.shop.id}_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (url.isNotEmpty) logoUrl(url);
    isUploadingLogo(false);
  }

  Future<void> _addBanner() async {
    isUploadingBanner(true);
    final String url = await _dataService.uploadImage(
      'shop_banner_${widget.shop.id}_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (url.isNotEmpty) bannerUrls.add(url);
    isUploadingBanner(false);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Shop name required', 'Please enter a shop name.',
          duration: const Duration(seconds: 4));
      return;
    }
    isSaving(true);
    final bool success = await UpdateService.to.updateShopBranding(
      shopId: widget.shop.id!,
      name: _nameController.text.trim(),
      about: _aboutController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      imgToken: logoUrl.value.isEmpty ? null : logoUrl.value,
      bannerUrls: bannerUrls.toList(),
      brandColor: brandColor.value,
    );
    isSaving(false);

    if (success) {
      Get.back();
      widget.onSaved();
      Get.snackbar(
        'Shop Updated',
        'Branding changes saved.',
        duration: const Duration(seconds: 5),
      );
    } else {
      Get.snackbar(
        'Failed to save',
        'Please try again.',
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Shop Branding',
              style: TextStyle(
                color: Colors.green,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _labeled('Shop Name', TextField(controller: _nameController)),
            _labeled('About', TextField(controller: _aboutController, maxLines: 3)),
            _labeled('Phone Number', TextField(controller: _phoneController)),
            _labeled('Address', TextField(controller: _addressController)),
            const SizedBox(height: 10),
            const Text('Logo', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Obx(
              () => GestureDetector(
                onTap: isUploadingLogo.value ? null : _pickLogo,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    logoUrl.value.isNotEmpty ? logoUrl.value : noImg,
                  ),
                  child: isUploadingLogo.value
                      ? const CircularProgressIndicator()
                      : const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.camera_alt, size: 18),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Banner Images', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...bannerUrls.map(
                    (url) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => bannerUrls.remove(url),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: isUploadingBanner.value ? null : _addBanner,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: isUploadingBanner.value
                          ? const Center(child: CircularProgressIndicator())
                          : const Icon(Icons.add_photo_alternate_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Accent Color', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presetBrandColors.map((hex) {
                  final bool selected = brandColor.value.toUpperCase() == hex.toUpperCase();
                  return GestureDetector(
                    onTap: () => brandColor(hex),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: _colorFromHex(hex),
                      child: selected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),
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
                  width: 140,
                  buttonText: 'Save Changes',
                  onPressed: _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeled(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 6),
          field,
        ],
      ),
    );
  }
}
