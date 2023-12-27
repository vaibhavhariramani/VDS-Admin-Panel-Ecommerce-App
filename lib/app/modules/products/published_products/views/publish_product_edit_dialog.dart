import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../../models/Product.dart';
import '../../../../../models/ProductDealType.dart';
import '../../../../widgets/components/animated_submit_button.dart';
import '../../../../widgets/components/form_input_field.dart';
import '../../../../widgets/components/labled_textfield.dart';
import '../../../../widgets/components/reactive_datetime_picker.dart';
import '../controllers/published_products_controller.dart';

class PublishedProductEditor
    extends GetResponsiveView<PublishedProductsController> {
  Product ProductDetails;
  PublishedProductEditor({required this.ProductDetails, Key? key})
      : super(key: key);
  PublishedProductsController productController =
      Get.put(PublishedProductsController());
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
                  ProductDetails.img_token!,
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
                        hintText:
                            "${ProductDetails.currency_type} ${ProductDetails.price} ",
                        onEditingComplete: () => _form.focus("discount"),
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
                        hintText:
                            "${ProductDetails.currency_type} ${ProductDetails.discount} ",
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
                          hintText:
                              " ${ProductDetails.available_from.toString().substring(0, 10)} ",
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
                        hintText:
                            " ${ProductDetails.expires_on.toString().substring(0, 10)} ",
                        onEditingComplete: () => _form.focus("visibility_date"),
                        validationMessage: (error) => "valid date required",
                      ),
                    ),
                    LabeledTextField(
                      label: "available_from",
                      isRequired: true,
                      textfield: ReactiveDatePickerField<DateTime>(
                        controlName: "available_from",
                        hintText: ProductDetails.available_from
                            .toString()
                            .substring(0, 10),
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
}
