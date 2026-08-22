import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../../constants/constants.dart';
import '../../../../models/ProductDealType.dart';
import '../../../../services/data_service.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../../../widgets/components/form_input_field.dart';
import '../../../widgets/components/labled_textfield.dart';
import '../../../widgets/components/reactive_datetime_picker.dart';

/// Pop-up "add product" form shared by the Scheduled and Published
/// products pages. A product's `availableFrom` date is what decides which
/// list it shows up in (future date -> Scheduled, today/past -> Published),
/// so this dialog is deal-type/list agnostic; the caller only needs to
/// refresh its own controller via [onCreated] once the product is saved.
class ProductCreateDialog extends StatefulWidget {
  final String shopId;
  final VoidCallback onCreated;

  const ProductCreateDialog({
    Key? key,
    required this.shopId,
    required this.onCreated,
  }) : super(key: key);

  @override
  State<ProductCreateDialog> createState() => _ProductCreateDialogState();
}

class _ProductCreateDialogState extends State<ProductCreateDialog> {
  final DataService _dataService = DataService.to;
  final RxBool isUploadingImage = false.obs;
  final RxString imageUrl = ''.obs;
  final Rx<ProductDealType> dealType = ProductDealType.GREENDEALS.obs;
  final RxBool isSubmitting = false.obs;

  final FormGroup form = FormGroup({
    'productname': FormControl<String>(validators: [Validators.required]),
    'brand': FormControl<String>(),
    'category': FormControl<String>(validators: [Validators.required]),
    'sku': FormControl<String>(validators: [Validators.required]),
    'currency_type': FormControl<String>(
      validators: [Validators.required],
      value: 'INR',
    ),
    'actual_price': FormControl<String>(validators: [Validators.required]),
    'offer_price': FormControl<String>(validators: [Validators.required]),
    'available_from': FormControl<DateTime>(validators: [Validators.required]),
    'expiry_date': FormControl<DateTime>(validators: [Validators.required]),
  });

  Future<void> _pickImage() async {
    isUploadingImage(true);
    final String url = await _dataService.uploadImage(
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
    final double price =
        double.tryParse(form.control('actual_price').value.toString()) ?? 0;
    final double offerPrice =
        double.tryParse(form.control('offer_price').value.toString()) ?? 0;
    final DateTime availableFrom =
        form.control('available_from').value as DateTime;
    final DateTime expiresOn = form.control('expiry_date').value as DateTime;

    final bool success = await _dataService.CreateNewHotProduct(
      img_token: imageUrl.value,
      product_name: form.control('productname').value.toString(),
      shopid: widget.shopId,
      currency_type: form.control('currency_type').value.toString(),
      price: price,
      offer_price: offerPrice,
      offer_ends_on: expiresOn,
      offer_starts_on: availableFrom,
      offer_available_from: availableFrom,
      sku: form.control('sku').value.toString(),
      deal_type: dealType.value,
    );
    isSubmitting(false);

    if (success) {
      Get.back();
      widget.onCreated();
      Get.snackbar(
        'Product Created',
        'New product added successfully',
        duration: const Duration(seconds: 5),
      );
    } else {
      Get.snackbar(
        'Failed to create product',
        'Please double check the details and try again',
        duration: const Duration(seconds: 5),
      );
    }
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
            Row(
              children: [
                Obx(
                  () => GestureDetector(
                    onTap: isUploadingImage.value ? null : _pickImage,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        imageUrl.value.isNotEmpty ? imageUrl.value : noImg,
                      ),
                      child: isUploadingImage.value
                          ? const CircularProgressIndicator()
                          : const Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.camera_alt, size: 18),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  'Add New Product',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ReactiveFormBuilder(
              form: () => form,
              builder: (context, form, child) => _buildFields(form, context),
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
                  buttonText: 'Create',
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFields(FormGroup _form, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Wrap(
            spacing: 10,
            children: ProductDealType.values.map((ProductDealType type) {
              return ChoiceChip(
                label: Text(type.name),
                selected: dealType.value == type,
                onSelected: (_) => dealType(type),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 15),
        LabeledTextField(
          label: 'Product Name',
          isRequired: true,
          textfield: FormTextInputField<String>(
            controlName: 'productname',
            hintText: 'e.g. Fresh Apples',
            onEditingComplete: () => _form.focus('brand'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            validationMessage: (control) => "Product name can't be empty.",
          ),
        ),
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
        LabeledTextField(
          label: 'Barcode / SKU',
          isRequired: true,
          textfield: FormTextInputField<String>(
            controlName: 'sku',
            hintText: 'Unique barcode',
            onEditingComplete: () => _form.focus('currency_type'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            validationMessage: (control) => "Barcode can't be empty.",
          ),
        ),
        LabeledTextField(
          label: 'Currency',
          isRequired: true,
          textfield: FormTextInputField<String>(
            controlName: 'currency_type',
            hintText: 'e.g. INR',
            onEditingComplete: () => _form.focus('actual_price'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            validationMessage: (control) => "Currency can't be empty.",
          ),
        ),
        LabeledTextField(
          label: 'Price',
          isRequired: true,
          textfield: FormTextInputField<String>(
            controlName: 'actual_price',
            hintText: '0.00',
            onEditingComplete: () => _form.focus('offer_price'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            validationMessage: (control) => "Price can't be empty.",
          ),
        ),
        LabeledTextField(
          label: 'Offer Price',
          isRequired: true,
          textfield: FormTextInputField<String>(
            controlName: 'offer_price',
            hintText: '0.00',
            onEditingComplete: () => _form.unfocus(),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            validationMessage: (control) => "Offer price can't be empty.",
          ),
        ),
        LabeledTextField(
          label: 'Available From',
          isRequired: true,
          textfield: ReactiveDatePickerField<DateTime>(
            controlName: 'available_from',
            hintText: 'Future date = Scheduled, today/past = Published',
            onEditingComplete: () {},
            validationMessage: (error) => 'valid date required',
          ),
        ),
        LabeledTextField(
          label: 'Expires On',
          isRequired: true,
          textfield: ReactiveDatePickerField<DateTime>(
            controlName: 'expiry_date',
            hintText: 'Pick a date',
            onEditingComplete: () {},
            validationMessage: (error) => 'valid date required',
          ),
        ),
      ],
    );
  }
}
