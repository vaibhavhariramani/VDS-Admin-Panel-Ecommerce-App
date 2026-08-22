import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../constants/constants.dart';
import '../../../../models/Product.dart';
import '../../../../models/ProductDealType.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../../../widgets/components/form_input_field.dart';
import '../../../widgets/components/labled_textfield.dart';
import '../../../widgets/components/reactive_datetime_picker.dart';
import '../master_list/controllers/master_list_controller.dart';

class ProductEditor extends GetResponsiveView<MasterListController> {
  Product ProductDetails;
  ProductEditor({required this.ProductDetails, Key? key}) : super(key: key);
  MasterListController productController = Get.put(MasterListController());
  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  (ProductDetails.img_token?.isNotEmpty ?? false)
                      ? ProductDetails.img_token!
                      : noImg,
                ),
                radius: 35,
              ),
              const SizedBox(width: 20),
              const Text(
                'Editing Product',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 32,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                  bottom: 10,
                ),
                child: ReactiveFormBuilder(
                  form: () => productController.productEditForm,
                  builder: (context, form, child) {
                    return buildFormFields(form, context);
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AnimatedSubmitButton(
                    color: Colors.red,
                    width: 90,
                    buttonText: 'Cancel',
                    onPressed: () async {
                      Get.back();
                    }),
                AnimatedSubmitButton(
                    width: 90,
                    buttonText: 'Edit',
                    onPressed: () async {
                      Get.back();
                      controller.isEditing(true);
                      await productController.editProduct(
                        ProductDetails: ProductDetails,
                      );
                    }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildFormFields(FormGroup _form, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledTextField(
                      label: "Product Name",
                      isRequired: true,
                      textfield: FormTextInputField<String>(
                        controlName: "product_name",
                        hintText: "${ProductDetails.name} ",
                        onEditingComplete: () => _form.focus("product_price"),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        validationMessage: (control) =>
                            "Product Name can't be empty.",
                      ),
                    ),
                    LabeledTextField(
                      label: "Product's Price",
                      isRequired: true,
                      textfield: FormTextInputField<String>(
                        controlName: "product_price",
                        hintText: _priceHint(
                            ProductDetails.currency_type, ProductDetails.price),
                        onEditingComplete: () => _form.focus("offer_price"),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        validationMessage: (control) =>
                            "Product Price can't be empty.",
                      ),
                    ),
                    LabeledTextField(
                      label: "Offer Price",
                      isRequired: true,
                      textfield: FormTextInputField<String>(
                        controlName: "offer_price",
                        hintText: _priceHint(ProductDetails.currency_type,
                            ProductDetails.discount),
                        onEditingComplete: () => _form.focus("expiry_date"),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        validationMessage: (control) =>
                            "Product Price can't be empty.",
                      ),
                    ),
                    Visibility(
                      visible:
                          ProductDetails.deal_type == ProductDealType.HOTDEALS,
                      child: LabeledTextField(
                        label: "Starting Details",
                        isRequired: true,
                        textfield: ReactiveDatePickerField<DateTime>(
                          controlName: "start_date",
                          hintText: " ${_dateHint(ProductDetails.available_from)} ",
                          onEditingComplete: () =>
                              _form.focus("visibility_date"),
                          validationMessage: (error) => "valid date required",
                        ),
                      ),
                    ),
                    LabeledTextField(
                      label: "Fresh untill",
                      isRequired: true,
                      textfield: ReactiveDatePickerField<DateTime>(
                        controlName: "expiry_date",
                        hintText: " ${_dateHint(ProductDetails.expires_on)} ",
                        onEditingComplete: () => _form.focus("visibility_date"),
                        validationMessage: (error) => "valid date required",
                      ),
                    ),
                    LabeledTextField(
                      label: "available_from",
                      isRequired: true,
                      textfield: ReactiveDatePickerField<DateTime>(
                        controlName: "available_from",
                        hintText: _dateHint(ProductDetails.available_from),
                        onEditingComplete: () => _form.unfocus(),
                        validationMessage: (error) => "valid date required",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _dateHint(DateTime? date) {
    if (date == null) return 'Not set';
    return date.toString().substring(0, 10);
  }

  /// `currency_type`/`price`/`discount` can each individually be null on a
  /// product doc — interpolating them straight into the hint text (as this
  /// used to) rendered the literal word "null" in the field, which read as
  /// if the value itself had gone missing.
  String _priceHint(String? currencyType, double? amount) {
    final String currency = currencyType ?? '';
    final String value = amount == null ? 'Not set' : amount.toString();
    return currency.isEmpty ? value : '$currency $value';
  }
}
