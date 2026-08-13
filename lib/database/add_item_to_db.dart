import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:vdsadmin/models/data_provider.dart';
import 'package:vdsadmin/models/firebase.service.dart';
import 'package:vdsadmin/theme/app_theme.dart';
import 'package:vdsadmin/widgets/image_upload_field.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ShopRegister extends StatefulWidget {
  const ShopRegister({Key? key}) : super(key: key);

  @override
  _ShopRegisterState createState() => _ShopRegisterState();
}

class _ShopRegisterState extends State<ShopRegister> {
  final name = TextEditingController();
  final description = TextEditingController();
  final mrp = TextEditingController();
  final price = TextEditingController();
  final selling = TextEditingController();
  final quantity = TextEditingController();

  var category1;
  String? _dataSetUrl;
  String? _barcode;
  bool _visible = true;

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    mrp.dispose();
    price.dispose();
    selling.dispose();
    quantity.dispose();
    super.dispose();
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() => _barcode = barcodeScanRes);
  }

  void _submit() {
    if (_dataSetUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload a product image first.')),
      );
      return;
    }
    if (_barcode == null || _barcode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan or enter a barcode first.')),
      );
      return;
    }
    InsertDatainFirebase().upload(
      _barcode,
      name.text,
      description.text,
      mrp.text,
      price.text,
      quantity.text,
      selling.text,
      _dataSetUrl,
      category1,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added.')),
    );
    setState(() {
      name.clear();
      description.clear();
      mrp.clear();
      price.clear();
      selling.clear();
      quantity.clear();
      _barcode = null;
      _dataSetUrl = null;
      category1 = null;
    });
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mutedText = isDarkMode(context) ? Colors.white60 : AppColors.shade50;

    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.qr_code_2, size: 20, color: AppColors.primaryDark),
                        const SizedBox(width: 8),
                        Text('Barcode',
                            style: AppText.heading(context).copyWith(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    VisibilityDetector(
                      key: const Key('add-item-visible-detector'),
                      onVisibilityChanged: (info) =>
                          _visible = info.visibleFraction > 0,
                      child: BarcodeKeyboardListener(
                        bufferDuration: const Duration(milliseconds: 200),
                        onBarcodeScanned: (barcode) {
                          if (!_visible) return;
                          setState(() => _barcode = barcode);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: appHairline(context)),
                          ),
                          child: Text(
                            _barcode == null
                                ? 'Scan with a barcode reader, or use the button below'
                                : 'Barcode: $_barcode',
                            style: AppText.body(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PillButton(
                      label: 'Scan Barcode',
                      icon: Icons.camera_alt_outlined,
                      onPressed: scanBarcodeNormal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 20, color: AppColors.primaryDark),
                        const SizedBox(width: 8),
                        Text('Product details',
                            style: AppText.heading(context).copyWith(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ImageUploadField(
                      label: 'Product image',
                      storagePathPrefix: 'shops',
                      initialImageUrl: _dataSetUrl,
                      onUploaded: (url) => setState(() => _dataSetUrl = url),
                    ),
                    const SizedBox(height: 16),
                    _field('Product name', name),
                    _field('Description', description),
                    Text('Category', style: AppText.caption(context)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: appHairline(context)),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: dataProvider.category(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: LinearProgressIndicator(),
                              );
                            }
                            return DropdownButton(
                              value: category1,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              isExpanded: true,
                              underline: const SizedBox(),
                              hint: Text('Select a category',
                                  style: TextStyle(color: mutedText)),
                              onChanged: (v) => setState(() => category1 = v),
                              items: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                final data =
                                    document.data()! as Map<String, dynamic>;
                                return DropdownMenuItem(
                                  value: data['tag'],
                                  child: Text(data['tag']),
                                );
                              }).toList(),
                            );
                          }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sell_outlined,
                            size: 20, color: AppColors.primaryDark),
                        const SizedBox(width: 8),
                        Text('Pricing & stock',
                            style: AppText.heading(context).copyWith(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _field('M.R.P.', mrp,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true)),
                    _field('Cost price', price,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true)),
                    _field('Selling price', selling,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true)),
                    _field('Stock quantity', quantity,
                        keyboardType: TextInputType.number),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: PillButton(
                  label: 'Add to Database',
                  icon: Icons.check,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
