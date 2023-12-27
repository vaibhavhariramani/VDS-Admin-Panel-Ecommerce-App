import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../themes/app_theme.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../../../widgets/components/form_input_field.dart';
import '../../../widgets/components/labled_textfield.dart';
import '../controllers/merchants_controller.dart';
import 'invite_merchant_datasrc.dart';

class AddMerchantView extends GetResponsiveView<MerchantsController> {
  MerchantsController addMerchantController = Get.put(MerchantsController());
  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return FlutterDashboardListView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20,
          ),
          sliver: SliverToBoxAdapter(child: _buildInviteMerchantsBox()),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20,
          ),
          sliver: SliverToBoxAdapter(
              child: addMerchantController.allInvitedMerchants.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(right: 2, top: 12),
                      child: Obx(
                        () => PaginatedDataTable(
                          showCheckboxColumn: false,
                          rowsPerPage:
                              addMerchantController.allInvitedMerchants.isEmpty
                                  ? 1
                                  : addMerchantController
                                              .allInvitedMerchants.length <
                                          10
                                      ? addMerchantController
                                          .allInvitedMerchants.length
                                      : 10,
                          columns: const [
                            // DataColumn(label: Text('Icon')),
                            DataColumn(label: Text('User')),
                            DataColumn(label: Text('Stats')),
                            // DataColumn(label: Text('Created Date')),
                            DataColumn(label: Text('Invitation ID')),
                          ],
                          columnSpacing: 10,
                          source: InviteDataSource(context,
                              addMerchantController.allInvitedMerchants),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator())),
        )
      ],
    );
  }

  Widget _buildInviteMerchantsBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                    "${addMerchantController.addedMerchants.length} Invites Generated")),
                Obx(
                  () => FlutterDashboardListView.grid(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    gridDelegate: screen.isPhone
                        ? FlutterDashboardGridDelegates.columns_2(
                            width: screen.width,
                            length: addMerchantController.addedMerchants.length)
                        : FlutterDashboardGridDelegates.fit(
                            addMerchantController.addedMerchants.length, 4, 1),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    isSliverItem: false,
                    childCount: addMerchantController.addedMerchants.length,
                    listType: FlutterDashboardListType.Grid,
                    buildItem: (BuildContext context, int index) {
                      return Center(
                        child: ListTile(
                          tileColor: Colors.white.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          dense: true,
                          leading: const CircleAvatar(
                            // backgroundImage: NetworkImage(
                            //   addMerchantController
                            //       .addedMerchants[index].imageurl!,
                            // ),
                            child: Icon(Icons.person),
                            radius: 15,
                          ),
                          title: Text(
                            addMerchantController.addedMerchants[index],
                            maxLines: 1,
                          ),
                          trailing: CircleAvatar(
                              maxRadius: 15,
                              backgroundColor: AppColors.green,
                              child: IconButton(
                                color: Colors.white,
                                icon: const Icon(Icons.close),
                                padding: EdgeInsets.zero,
                                iconSize: 15,
                                onPressed: () {
                                  addMerchantController.removeMerchant2(
                                      addMerchantController
                                          .addedMerchants[index]
                                          .toString());
                                },
                              )),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 210,
                  child: ListTile(
                    dense: true,
                    tileColor: Colors.white.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    leading: CircleAvatar(
                        maxRadius: 15,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(Icons.add),
                          padding: EdgeInsets.zero,
                          iconSize: 15,
                          onPressed: () {
                            _buildAddMerchantDialog();
                          },
                        )),
                    title: const Text("Add Merchants"),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () async {
            Get.defaultDialog(
              // barrierDismissible: false,
              title: "Sending Invitation",
              content: const CircularProgressIndicator(),
              // cancel: Icon(Icons.close),
            );
            await controller.sendInvitation();
            Get.back();
          },
          child: const Text("Send Invitation"),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(AppColors.green)),
        )
      ],
    );
  }

  _buildAddMerchantDialog() {
    return Get.defaultDialog(
        title: "Add Merchants",
        titleStyle: const TextStyle(
            color: Colors.green, fontSize: 32, fontWeight: FontWeight.w600),
        content: SizedBox(
          width: Get.width * 0.6,
          // height: Get.height * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: <Widget>[
                  // Align(
                  //   alignment: AlignmentDirectional.centerStart,
                  //   child: Text(
                  //     'Inviting User',
                  //     textScaleFactor: Get.textScaleFactor,
                  //     style: Theme.of(screen.context)
                  //         .textTheme
                  //         .bodyText2
                  //         ?.copyWith(
                  //           color: Theme.of(screen.context).disabledColor,
                  //         ),
                  //   ),
                  // ),
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
                          // controller.createProduct();
                          Get.back();
                        }),
                    AnimatedSubmitButton(
                        width: 90,
                        buttonText: 'Add',
                        onPressed: () async {
                          // controller.createProduct();
                          addMerchantController.addMerchant2(
                              addMerchantController
                                  .editForm1.value['invited_email']
                                  .toString());
                          addMerchantController.editForm1.reset();
                          Get.back();
                        }),
                  ],
                ),
              )
            ],
          ),
        ));
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
            LabeledTextField(
              label: "Enter Email Id",
              isRequired: true,
              textfield: FormTextInputField<String>(
                  controlName: "invited_email",
                  hintText: "Email Id",
                  onEditingComplete: () => _form.unfocus(),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  validationMessage: (control) => "Email Id can't be empty."),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("Enter comma separated emails in the invitation box"),
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
                        'Enter Email Id',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(
                        height: 10,
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
                      const SizedBox(
                        height: 10,
                      ),
                      const Center(
                        child: Text(
                            "Enter comma separated emails in the invitation box"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
      //  GridView.builder(
      //     gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 350, childAspectRatio: 3, crossAxisSpacing: 20),
      //     itemCount: addMerchantController.allUninvitedMerchants.length,
      //     itemBuilder: (BuildContext context, int index) {
      //       return Center(
      //         child: ListTile(
      //           tileColor: const Color(0xff000000).withOpacity(0.3),
      //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      //           dense: true,
      //           leading: CircleAvatar(
      //             backgroundImage: NetworkImage(
      //               addMerchantController.allUninvitedMerchants[index].imageurl!,
      //             ),
      //             radius: 15,
      //           ),
      //           title: Text(
      //             '${addMerchantController.allUninvitedMerchants[index].merchantEmail}',
      //             maxLines: 1,
      //           ),
      //           trailing: InkWell(
      //             onTap: () {
      //               addMerchantController.addMerchant(addMerchantController.allUninvitedMerchants[index]);
      //             },
      //             child: Container(
      //                 decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
      //                 padding: const EdgeInsets.all(4),
      //                 child: const Text(
      //                   'Add',
      //                   style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      //                 )),
      //           ),
      //         ),
      //       );
      //     }),
    }
  }
}
