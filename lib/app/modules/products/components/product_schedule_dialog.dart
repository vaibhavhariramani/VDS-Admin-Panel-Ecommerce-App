import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/Product.dart';
import '../../../../themes/app_theme.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../../../widgets/components/labled_textfield.dart';
import '../../../widgets/components/reactive_datetime_picker.dart';
import '../master_list/controllers/master_list_controller.dart';

class ProductScheduler extends GetResponsiveView<MasterListController> {
  Product ProductDetails;
  ProductScheduler({required this.ProductDetails, Key? key}) : super(key: key);
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
                  ProductDetails.img_token!,
                ),
                radius: 35,
              ),
              const SizedBox(width: 20),
              const Text(
                'Scheduling Product',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 32,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          // Text(
          //     "This product was available on App from ${ProductDetails.available_from?.getDateTimeInUtc().toString().substring(0, 10)} to ${ProductDetails.expires_on?.getDateTimeInUtc().toString().substring(0, 10)}"),
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
                    color: AppColors.yellow,
                    width: 90,
                    buttonText: 'Schedule',
                    onPressed: () async {
                      Get.back();
                      controller.isEditing(true);
                      await productController.scheduleProduct(
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
                      label: "Visible on App from:",
                      isRequired: true,
                      textfield: ReactiveDatePickerField<DateTime>(
                        controlName: "available_from",
                        hintText: controller.dataSer.DateTimeToString(
                            date: ProductDetails.available_from!),
                        onEditingComplete: () => _form.unfocus(),
                        validationMessage: (error) =>
                            "valid date time required",
                      ),
                    ),
                    LabeledTextField(
                      label: "Fresh untill",
                      isRequired: true,
                      textfield: ReactiveDatePickerField<DateTime>(
                        controlName: "expiry_date",
                        hintText: controller.dataSer
                            .DateTimeToString(date: ProductDetails.expires_on!),
                        onEditingComplete: () => _form.focus("visibility_date"),
                        validationMessage: (error) => "Valid date required",
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
