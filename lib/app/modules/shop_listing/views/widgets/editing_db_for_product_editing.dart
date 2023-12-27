import 'package:emart/app/modules/shop_listing/controllers/shop_listing_controller.dart';
import 'package:emart/app/widgets/components/animated_submit_button.dart';
import 'package:emart/app/widgets/components/form_input_field.dart';
import 'package:emart/app/widgets/components/labled_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../../models/Product.dart';

class ProductEditingBox extends GetResponsiveView<ShopListingController> {
  Product ProductDetails;
  ProductEditingBox({required this.ProductDetails, Key? key}) : super(key: key);
  ShopListingController shopController = Get.put(ShopListingController());
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
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'Edit Product Details',
                  textScaleFactor: Get.textScaleFactor,
                  style: Theme.of(screen.context).textTheme.bodyText2?.copyWith(
                        color: Theme.of(screen.context).disabledColor,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                  bottom: 10,
                ),
                child: ReactiveFormBuilder(
                  form: () => shopController.productEditForm,
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
                      // controller.createProduct();
                      Get.back();
                    }),
                AnimatedSubmitButton(
                    width: 90,
                    buttonText: 'Edit',
                    onPressed: () async {
                      // controller.createProduct();
                      shopController.editProduct();
                    }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildFormFields(FormGroup _form, BuildContext context) {
    if (screen.isPhone) {
      return Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // const SizedBox(
            //   height: 10,
            // ),
            LabeledTextField(
              label: "Enter Product Name",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "product_name",
                hintText: "Full Name",
                onEditingComplete: () => _form.unfocus(),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                validationMessage: (control) => "Name can't be empty.",
              ),
            ),
            LabeledTextField(
              label: "Enter Email Id",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "product_email",
                hintText: "Email Id",
                onEditingComplete: () => _form.unfocus(),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                validationMessage: (control) => "Email Id can't be empty.",
              ),
            ),
          ],
        ),
      );
    } else {
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
                      const Text(
                        'Enter Full Name',
                        style: TextStyle(fontSize: 13),
                      ),
                      FormTextInputField<String>(
                        controlName: "product_name",
                        hintText: "Full Name",
                        onEditingComplete: () => _form.unfocus(),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        validationMessage: (control) =>
                            "Full Name can't be empty",
                      ),
                      const Text(
                        'Enter Email Id',
                        style: TextStyle(fontSize: 13),
                      ),
                      FormTextInputField<String>(
                        controlName: "product_email",
                        hintText: "Email Id",
                        onEditingComplete: () => _form.unfocus(),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        validationMessage: (control) =>
                            "Email ID can't be empty",
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
}
