import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../../../../constants/constants.dart';
import '../../../../../../models/Product.dart';
import '../../../../../../models/ProductDealType.dart';
import '../../../../../../themes/app_theme.dart';
import '../../../../../widgets/components/animated_submit_button.dart';
import '../../../../../widgets/components/form_input_field.dart';
import '../../../../../widgets/components/labled_textfield.dart';
import '../../../../../widgets/components/reactive_datetime_picker.dart';
import '../../controllers/product_management_controller.dart';

/// One create/edit dialog for every product, replacing 3 independent
/// creation forms (products_listing_view.dart's green-deal/hot-deal/bulk
/// field builders, master_list_view.dart's own copy) and 5 near-identical
/// edit dialogs (ProductEditor, BulkProductEditor, HotDeadProductEditor,
/// PublishedProductEditor, SchProductEditor) — see
/// docs/architecture/CURRENT_ARCHITECTURE.md. Bulk CSV upload is
/// deliberately not folded in here; it stays a separate, distinct flow
/// (see the "Bulk upload" entry point on ProductManagementView).
class ProductFormDialog extends StatefulWidget {
  final ProductManagementController controller;

  /// Null = create mode. Non-null = editing this product (SKU becomes
  /// read-only, since it's the Firestore document id).
  final Product? existing;

  const ProductFormDialog({Key? key, required this.controller, this.existing}) : super(key: key);

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  bool get _isEditing => widget.existing != null;

  late final RxString imageUrl = (widget.existing?.img_token ?? '').obs;
  final RxBool isUploadingImage = false.obs;
  late final Rx<ProductDealType> dealType =
      (widget.existing?.deal_type ?? ProductDealType.GREENDEALS).obs;
  final RxBool isSubmitting = false.obs;
  final RxnString errorText = RxnString();

  late final FormGroup form = FormGroup({
    'name': FormControl<String>(
      value: widget.existing?.name,
      validators: [Validators.required],
    ),
    'brand': FormControl<String>(value: widget.existing?.brand),
    'category': FormControl<String>(
      value: widget.existing?.category?.toString(),
      validators: [Validators.required],
    ),
    'sku': FormControl<String>(
      value: widget.existing?.barcode,
      validators: [Validators.required],
    ),
    'currency_type': FormControl<String>(
      value: widget.existing?.currency_type ?? 'INR',
      validators: [Validators.required],
    ),
    'price': FormControl<String>(
      value: widget.existing?.price.toString(),
      validators: [Validators.required],
    ),
    'offer_price': FormControl<String>(
      value: widget.existing?.discount?.toString(),
      validators: [Validators.required],
    ),
    'quantity': FormControl<String>(
      value: (widget.existing?.count ?? 0).toString(),
      validators: [Validators.required],
    ),
    'available_from': FormControl<DateTime>(
      value: widget.existing?.available_from,
      validators: [Validators.required],
    ),
    'expiry_date': FormControl<DateTime>(
      value: widget.existing?.expires_on,
      validators: [Validators.required],
    ),
  });

  Future<void> _pickImage() async {
    isUploadingImage(true);
    final String url = await widget.controller.uploadImage(
      'product_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (url.isNotEmpty) imageUrl(url);
    isUploadingImage(false);
  }

  Future<void> _submit() async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }
    isSubmitting(true);
    errorText.value = null;

    final String name = form.control('name').value.toString();
    final double price = double.tryParse(form.control('price').value.toString()) ?? 0;
    final double offerPrice = double.tryParse(form.control('offer_price').value.toString()) ?? 0;
    final DateTime availableFrom = form.control('available_from').value as DateTime;
    final DateTime expiresOn = form.control('expiry_date').value as DateTime;

    final String? error = _isEditing
        ? await widget.controller.updateProduct(
            product: widget.existing!,
            name: name,
            price: price,
            offerPrice: offerPrice,
            availableFrom: availableFrom,
            expiresOn: expiresOn,
          )
        : await widget.controller.createProduct(
            sku: form.control('sku').value.toString(),
            name: name,
            brand: form.control('brand').value?.toString(),
            category: form.control('category').value.toString(),
            currencyType: form.control('currency_type').value.toString(),
            price: price,
            offerPrice: offerPrice,
            quantity: int.tryParse(form.control('quantity').value.toString()) ?? 0,
            dealType: dealType.value,
            availableFrom: availableFrom,
            expiresOn: expiresOn,
            imageUrl: imageUrl.value,
          );

    isSubmitting(false);
    if (error != null) {
      errorText.value = error;
      return;
    }
    Get.back();
    Get.snackbar(
      _isEditing ? 'Product updated' : 'Product created',
      _isEditing ? '$name has been updated.' : '$name has been added.',
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Obx(
                    () => GestureDetector(
                      onTap: isUploadingImage.value ? null : _pickImage,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.white,
                        backgroundImage: NetworkImage(imageUrl.value.isNotEmpty ? imageUrl.value : noImg),
                        child: isUploadingImage.value
                            ? const CircularProgressIndicator()
                            : const Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(Icons.camera_alt, size: 16),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Text(
                    _isEditing ? 'Edit product' : 'Add product',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ReactiveFormBuilder(
                form: () => form,
                builder: (context, form, child) => _buildFields(form, context),
              ),
              Obx(() => errorText.value == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Text(errorText.value!, style: const TextStyle(color: AppSemanticColors.danger)),
                    )),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedSubmitButton(color: AppColors.grey, width: 90, buttonText: 'Cancel', onPressed: () async => Get.back()),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedSubmitButton(
                    width: 130,
                    buttonText: _isEditing ? 'Save' : 'Create',
                    onPressed: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFields(FormGroup _form, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Basic info'),
        LabeledTextField(
          label: 'Product name',
          isRequired: true,
          textfield: FormTextInputField<String>(
            controlName: 'name',
            hintText: 'e.g. Fresh Apples',
            onEditingComplete: () => _form.focus('brand'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            validationMessage: (control) => "Product name can't be empty.",
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        LabeledTextField(
          label: 'Brand',
          textfield: FormTextInputField<String>(
            controlName: 'brand',
            hintText: 'e.g. Local Farms',
            onEditingComplete: () => _form.focus('category'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            validationMessage: (control) => '',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        LabeledTextField(
          label: 'Category',
          isRequired: true,
          textfield: FormTextInputField<String>(
            controlName: 'category',
            hintText: 'e.g. Groceries',
            onEditingComplete: () => _form.focus('sku'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            validationMessage: (control) => "Category can't be empty.",
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        LabeledTextField(
          label: 'Barcode / SKU',
          isRequired: true,
          textfield: FormTextInputField<String>(
            controlName: 'sku',
            hintText: 'Unique barcode',
            readOnly: _isEditing,
            onEditingComplete: () => _form.focus('currency_type'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            validationMessage: (control) => "Barcode can't be empty.",
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionLabel('Pricing & inventory'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabeledTextField(
                label: 'Price',
                isRequired: true,
                textfield: FormTextInputField<String>(
                  controlName: 'price',
                  hintText: '0.00',
                  onEditingComplete: () => _form.focus('offer_price'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validationMessage: (control) => "Price can't be empty.",
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: LabeledTextField(
                label: 'Offer price',
                isRequired: true,
                textfield: FormTextInputField<String>(
                  controlName: 'offer_price',
                  hintText: '0.00',
                  onEditingComplete: () => _form.focus('quantity'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validationMessage: (control) => "Offer price can't be empty.",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabeledTextField(
                label: 'Currency',
                isRequired: true,
                textfield: FormTextInputField<String>(
                  controlName: 'currency_type',
                  hintText: 'e.g. INR',
                  readOnly: _isEditing,
                  onEditingComplete: () => _form.focus('quantity'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  validationMessage: (control) => "Currency can't be empty.",
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: LabeledTextField(
                label: 'Stock quantity',
                isRequired: true,
                textfield: FormTextInputField<String>(
                  controlName: 'quantity',
                  hintText: '0',
                  readOnly: _isEditing,
                  onEditingComplete: () => _form.unfocus(),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  validationMessage: (control) => "Stock quantity can't be empty.",
                ),
              ),
            ),
          ],
        ),
        if (_isEditing)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'Stock quantity is managed from inventory, not this form.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        _SectionLabel('Availability & deal type'),
        Obx(
          () => Wrap(
            spacing: 8,
            children: ProductDealType.values.map((ProductDealType type) {
              return ChoiceChip(
                label: Text(_dealTypeLabel(type)),
                selected: dealType.value == type,
                onSelected: (_) => dealType(type),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabeledTextField(
                label: 'Available from',
                isRequired: true,
                textfield: ReactiveDatePickerField<DateTime>(
                  controlName: 'available_from',
                  hintText: 'Future = Scheduled, today/past = Published',
                  onEditingComplete: () {},
                  validationMessage: (error) => 'Valid date required',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: LabeledTextField(
                label: 'Expires on',
                isRequired: true,
                textfield: ReactiveDatePickerField<DateTime>(
                  controlName: 'expiry_date',
                  hintText: 'Pick a date',
                  onEditingComplete: () {},
                  validationMessage: (error) => 'Valid date required',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _dealTypeLabel(ProductDealType type) {
    switch (type) {
      case ProductDealType.GREENDEALS:
        return 'Standard';
      case ProductDealType.REDDEALS:
        return 'Clearance';
      case ProductDealType.HOTDEALS:
        return 'Hot Deal';
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.grey,
            ),
      ),
    );
  }
}
