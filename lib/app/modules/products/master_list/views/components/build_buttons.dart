import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../themes/app_theme.dart';
import '../../../../../widgets/components/animated_submit_button.dart';
import '../../controllers/master_list_controller.dart';
import 'custom_material_button.dart';

class buildButtons extends GetResponsiveView {
  buildButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    MasterListController controller = Get.find<MasterListController>();
    if (controller.showProductUploadForm.isTrue) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MaterialButton(
            onPressed: () {
              controller.showProductUploadForm(false);
              controller.showBulkProductUploadForm(false);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: Theme.of(screen.context).primaryColor,
              ),
            ),
            height: 46,
            minWidth: 120,
            child: Text(
              'Cancel',
              textScaleFactor: Get.textScaleFactor,
              style: DefaultTextStyle.of(screen.context).style,
            ),
          ),
          SizedBox(
            width: 150,
            child: Center(
              child: AnimatedSubmitButton(
                onPressed: () async {
                  // await Future.delayed(2.seconds);
                  Get.dialog(Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          borderRadius: BorderRadius.circular(15.0),
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            height: 485,
                            width: 492,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 35),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 245,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Preview',
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 32,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              IconButton(
                                                color: Color(0xff5E5873),
                                                iconSize: 22,
                                                icon: const Icon(Icons.close),
                                                onPressed: () {
                                                  Get.back();
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          width: 145,
                                          height: 142,
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: controller
                                                .productImageUrl0.value,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.productAddForm
                                                  .value["productname"]
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              controller.productAddForm
                                                  .value["productname"]
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 26),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  controller.productAddForm
                                                      .value["actual_price"]
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 26,
                                                      color: Colors.green),
                                                ),
                                                Text(
                                                  controller.productAddForm
                                                      .value["offer_price"]
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16,
                                                      color: Colors.green),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 50),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Best Before ${controller.productAddForm.value["expiry_date"]}',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          controller.Dealtype.toString(),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.green),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      CustomMaterialButton2(
                                        controller: controller,
                                        screen: screen,
                                        text: 'Cancel',
                                        onPressed: () {
                                          controller
                                              .showBulkProductUploadForm(false);
                                        },
                                      ),
                                      AnimatedSubmitButton(
                                          width: 90,
                                          buttonText: 'Confirm',
                                          onPressed: () async {
                                            // controller.createProduct();
                                            Get.back();
                                          }),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
                },
                textColor: AppColors.white,
                radius: 8.0,
                color: AppColors.green,
                width: double.maxFinite,
                buttonText: 'Complete',
              ),
            ),
          ),
        ],
      );
    } else {
      if (screen.isPhone) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // remove controller
            CustomMaterialButton2(
              controller: controller,
              screen: screen,
              text: 'Edit',
              onPressed: () {},
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              child: Center(
                child: AnimatedSubmitButton(
                  onPressed: () async {
                    await Future.delayed(2.seconds);
                  },
                  textColor: AppColors.white,
                  radius: 8.0,
                  color: AppColors.green,
                  width: double.maxFinite,
                  buttonText: 'Complete',
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: Center(
                child: AnimatedSubmitButton(
                  onPressed: () async {
                    await Future.delayed(2.seconds);
                  },
                  textColor: AppColors.white,
                  radius: 8.0,
                  color: AppColors.green,
                  width: double.maxFinite,
                  buttonText: 'Complete & Add to New product',
                ),
              ),
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MaterialButton(
              onPressed: () {
                controller.showBulkProductUploadForm(false);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(
                  color: Theme.of(screen.context).primaryColor,
                ),
              ),
              height: 46,
              minWidth: 120,
              child: Text(
                'Cancel',
                textScaleFactor: Get.textScaleFactor,
                style: DefaultTextStyle.of(screen.context).style,
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Center(
                    child: AnimatedSubmitButton(
                      onPressed: () async {
                        await Future.delayed(2.seconds);
                      },
                      textColor: AppColors.white,
                      radius: 8.0,
                      color: AppColors.green,
                      width: double.maxFinite,
                      buttonText: 'Complete',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 200,
                  child: Center(
                    child: AnimatedSubmitButton(
                      onPressed: () async {
                        await Future.delayed(2.seconds);
                      },
                      textColor: AppColors.white,
                      radius: 8.0,
                      color: AppColors.green,
                      width: double.maxFinite,
                      buttonText: 'Complete & Add to New product',
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
}
