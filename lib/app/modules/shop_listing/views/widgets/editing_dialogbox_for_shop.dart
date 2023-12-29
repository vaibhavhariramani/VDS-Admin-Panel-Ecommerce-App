import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';

import '../../../../widgets/components/animated_submit_button.dart';
import '../../../../widgets/components/form_input_field.dart';
import '../../../../widgets/components/labled_textfield.dart';
import '../../controllers/shop_listing_controller.dart';

class EditBox extends GetResponsiveView<ShopListingController> {
  BuildContext context;
  EditBox(this.context, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Editing Shop Details',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 32,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    color: Colors.green,
                    iconSize: 22,
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Get.back();
                    },
                  )
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 145,
                  height: 142,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: controller.shopdetails.value.img_token![0],
                    fit: BoxFit.cover,
                  ),
                ),
                // ReactiveFormBuilder(
                //     form: () => controller.editForm1,
                //     builder:
                //         (BuildContext context, FormGroup _form, Widget? child) {
                //       return Obx(
                //         () => Column(
                //           children: [
                //             LabeledTextField(
                //               label: 'Shop Name',
                //               textfield: FormTextInputField(
                //                 readOnly: controller.isEditing.isFalse,
                //                 controlName: 'shop_name',
                //                 hintText: controller.shopdetails.value.name ??
                //                     "shop name",
                //                 onEditingComplete: () =>
                //                     _form.focus('shop_user_id'),
                //                 keyboardType: TextInputType.text,
                //                 textInputAction: TextInputAction.next,
                //                 validationMessage: (control) => {
                //                   ValidationMessage.required:
                //                       'Shop name not be empty',
                //                 },
                //               ),
                //             ),
                //             const SizedBox(
                //               height: 20,
                //             ),
                //             LabeledTextField(
                //                 label: 'Shop Admin Id',
                //                 textfield: FormTextInputField(
                //                   readOnly: true,
                //                   controlName: 'shop_user_id',
                //                   hintText:
                //                       controller.shopdetails.value.usersID ??
                //                           'Shop User ID',
                //                   onEditingComplete: () => _form.unfocus(),
                //                   keyboardType: TextInputType.text,
                //                   textInputAction: TextInputAction.next,
                //                   validationMessage: (control) => {
                //                     ValidationMessage.required:
                //                         'ID can not be empty',
                //                   },
                //                 )),
                //           ],
                //         ),
                //       );
                //     }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
              bottom: 10,
            ),
            child: ReactiveFormBuilder(
              form: () => controller.editForm1,
              builder: (context, _form, child) {
                return _buildFormFields(_form, context);
              },
            ),
          ),
          // ReactiveForm(
          //   formGroup: controller.editForm1,
          //   child: Column(
          //     children: <Widget>[
          //       Align(
          //         alignment: AlignmentDirectional.centerStart,
          //         child: Text(
          //           'Shop Name',
          //           textScaleFactor: Get.textScaleFactor,
          //           style:
          //               Theme.of(screen.context).textTheme.bodyText2?.copyWith(
          //                     color: Theme.of(screen.context).disabledColor,
          //                   ),
          //         ),
          //       ),
          //       ReactiveTextField(
          //         formControlName: 'shop_name',
          //         validationMessages: (control) =>
          //             {'required': 'The Shop name must not be empty'},
          //         onEditingComplete: () => controller.editForm1.unfocus(),
          //         cursorColor: Theme.of(screen.context).indicatorColor,
          //         cursorHeight: 25,
          //         decoration: InputDecoration(
          //           contentPadding: EdgeInsets.zero,
          //           hintText:
          //               controller.shopdetails.value.name ?? 'Enter Shop Name',
          //           border: UnderlineInputBorder(
          //               borderSide: BorderSide(
          //             color: Theme.of(screen.context).disabledColor,
          //           )),
          //           enabledBorder: UnderlineInputBorder(
          //               borderSide: BorderSide(
          //             color: Theme.of(screen.context).disabledColor,
          //           )),
          //           errorBorder: const UnderlineInputBorder(
          //               borderSide: BorderSide(
          //             color: Colors.green,
          //           )),
          //           focusedBorder: UnderlineInputBorder(
          //               borderSide: BorderSide(
          //             color: Theme.of(screen.context).disabledColor,
          //           )),
          //           disabledBorder: UnderlineInputBorder(
          //               borderSide: BorderSide(
          //             color: Theme.of(screen.context).disabledColor,
          //           )),
          //           focusedErrorBorder: UnderlineInputBorder(
          //               borderSide: BorderSide(
          //             color: Theme.of(screen.context).disabledColor,
          //           )),
          //         ),
          //       ),
          //       ReactiveTextField(
          //         formControlName: 'shop_user_id',
          //         validationMessages: (control) => {
          //           'required': 'The email must not be empty',
          //           'email': 'The email value must be a valid email'
          //         },
          //       ),
          //       // ReactiveTextField(
          //       //   formControlName: 'password',
          //       //   obscureText: true,
          //       //   validationMessages: (control) => {
          //       //     'required': 'The password must not be empty',
          //       //     'minLenght': 'The password must have at least 8 characters'
          //       //   },
          //       // ),
          //     ],
          //   ),
          // ),

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
                      Get.back();
                    }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormFields(FormGroup _form, BuildContext context) {
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
              label: "Shop Name",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "shop_name",
                hintText: controller.shopdetails.value.name ?? "Shop Name",
                onEditingComplete: () => _form.unfocus(),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                validationMessage: (control) => "Shop's Name can't be empty.",
              ),
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            LabeledTextField(
              label: "Shop Address",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "shop_address",
                hintText: controller.shopdetails.value.phy_address ?? "Address",
                onEditingComplete: () => _form.unfocus(),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                validationMessage: (control) =>
                    "Shop's Address can't be empty.",
              ),
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            LabeledTextField(
              label: "Shop User ID",
              textfield: FormTextInputField<String>(
                controlName: "shop_user_id",
                hintText:
                    controller.shopdetails.value.usersID ?? "Shop User ID",
                onEditingComplete: () => _form.unfocus(),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                validationMessage: (control) => "Shop User ID can't be empty.",
              ),
            ),
            const SizedBox(
              height: 10,
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
                        'Add Shop Name',
                        style: TextStyle(fontSize: 13),
                      ),
                      FormTextInputField<String>(
                        controlName: "shop_name",
                        hintText:
                            controller.shopdetails.value.name ?? "Shop Name",
                        onEditingComplete: () => _form.unfocus(),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        validationMessage: (control) =>
                            "Shop's Name can't be empty",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // const SizedBox(
          //   height: 10,
          // ),
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
                        'Shop Address',
                        style: TextStyle(fontSize: 13),
                      ),
                      FormTextInputField<String>(
                        controlName: "shop_address",
                        hintText: controller.shopdetails.value.phy_address ??
                            "Address",
                        onEditingComplete: () => _form.unfocus(),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        validationMessage: (control) =>
                            "Shop's Address can't be empty",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // const SizedBox(
          //   height: 10,
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: 180,
                  child: LabeledTextField(
                    label: "Shop User ID",
                    textfield: FormTextInputField<String>(
                      controlName: "shop_user_id",
                      hintText: controller.shopdetails.value.usersID ??
                          "Shop User ID",
                      onEditingComplete: () => _form.unfocus(),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      validationMessage: (control) =>
                          "Shop User ID can't be empty.",
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 25,
              ),
            ],
          ),
        ],
      );
    }
  }
}
