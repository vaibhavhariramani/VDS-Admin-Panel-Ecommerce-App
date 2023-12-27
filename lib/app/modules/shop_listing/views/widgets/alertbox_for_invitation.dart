import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../widgets/components/animated_submit_button.dart';
import '../../../../widgets/components/form_input_field.dart';
import '../../../../widgets/components/labled_textfield.dart';
import '../../controllers/shop_listing_controller.dart';

class InvitationBox extends GetResponsiveView<ShopListingController> {
  // BuildContext context;
  InvitationBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Invite User',
            style: TextStyle(
                color: Colors.green, fontSize: 32, fontWeight: FontWeight.w600),
          ),
          // GridView.builder(
          //     gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          //         maxCrossAxisExtent: 350,
          //         childAspectRatio: 3,
          //         crossAxisSpacing: 20),
          //     itemCount: controller.allUninvitedShops.length,
          //     itemBuilder: (BuildContext context, int index) {
          //       return Center(
          //         child: ListTile(
          //           tileColor: Colors.white.withOpacity(0.4),
          //           shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(20.0)),
          //           dense: true,
          //           leading: CircleAvatar(
          //             backgroundImage: NetworkImage(
          //               controller.allUninvitedShops[index].img_token![0],
          //             ),
          //             radius: 15,
          //           ),
          //           title: Text(
          //             '${controller.allUninvitedShops[index].email}',
          //             maxLines: 1,
          //           ),
          //           trailing: InkWell(
          //             onTap: () {
          //               controller.addSHOP(controller.allUninvitedShops[index]);
          //             },
          //             child: Container(
          //                 decoration: BoxDecoration(
          //                     color: Colors.white.withOpacity(0.3),
          //                     borderRadius: BorderRadius.circular(20)),
          //                 padding: const EdgeInsets.all(4),
          //                 child: const Text(
          //                   'Add',
          //                   style: TextStyle(
          //                       color: Colors.green,
          //                       fontWeight: FontWeight.bold),
          //                 )),
          //           ),
          //         ),
          //       );
          //     }),
          Column(
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'Inviting User',
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
                  form: () => controller.editForm1,
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
                    // await controller.createProduct();
                  },
                ),
                AnimatedSubmitButton(
                    width: 90,
                    buttonText: 'Add',
                    onPressed: () async {
                      // controller.createProduct();
                      controller.addSHOP2(controller
                          .editForm1.value['invited_email']
                          .toString());
                      controller.editForm1.reset();
                      Get.back();
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
              label: "Enter Email Id",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "invited_email",
                hintText: "Email Id",
                onEditingComplete: () => _form.unfocus(),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
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
                        'Enter Email Id',
                        style: TextStyle(fontSize: 13),
                      ),
                      FormTextInputField<String>(
                        controlName: "invited_email",
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
