import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../modules/products/products_listing/controllers/products_listing_controller.dart';

class ImportButton extends GetResponsiveView {
  // Future<void> ontap;
  ImportButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProductsListingController controller = Get.find();
    screen.context = context;
    return MaterialButton(
      onPressed: () {
        Get.dialog(
          AlertDialog(
            content: SizedBox(
              width: Get.width * 0.3,
              height: Get.height * 0.45,
              child: Card(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          'Bulk Upload Products',
                          textScaleFactor: Get.textScaleFactor,
                          style: Theme.of(screen.context)
                              .textTheme
                              .bodyText2
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: Get.textScaleFactor * 20,
                                color: Theme.of(screen.context).disabledColor,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: Get.height * 0.10,
                        width: Get.width * 0.10,
                        child: LoadingButton(
                          onPressed: () async {
                            const url =
                                "https://firebasestorage.googleapis.com/v0/b/cucumia-369c1.appspot.com/o/csv%2Fsample.csv?alt=media&token=abb6cd47-65fd-4731-b62c-dbdbb310d50d";

                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw "Could not launch $url";
                            }
                          },
                          defaultWidget: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Download sample CSV',
                              softWrap: true,
                              textScaleFactor: Get.textScaleFactor,
                              style: DefaultTextStyle.of(screen.context)
                                  .style
                                  .copyWith(
                                    color:
                                        Theme.of(screen.context).disabledColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ),
                          loadingWidget: CircularProgressIndicator(
                            color: Theme.of(context).indicatorColor,
                          ),
                          color: Theme.of(context).primaryColor,
                          type: LoadingButtonType.Elevated,
                          borderRadius: 10,
                          height: 15,
                        ),
                      ),
                      SizedBox(
                        height: Get.height * 0.05,
                      ),
                      SizedBox(
                        height: Get.height * 0.10,
                        width: Get.width * 0.10,
                        child: LoadingButton(
                          onPressed: () async {
                            print('"CSV".tr');
                            // ontap;
                            await controller.importCSV();
                            Get.back();
                          },
                          defaultWidget: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Upload CSV',
                              softWrap: true,
                              textScaleFactor: Get.textScaleFactor,
                              style: DefaultTextStyle.of(screen.context)
                                  .style
                                  .copyWith(
                                    color:
                                        Theme.of(screen.context).disabledColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ),
                          loadingWidget: CircularProgressIndicator(
                            color: Theme.of(context).indicatorColor,
                          ),
                          color: Theme.of(context).primaryColor,
                          type: LoadingButtonType.Elevated,
                          borderRadius: 10,
                          height: 56,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      },
      color: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      disabledColor: Colors.transparent,
      highlightColor: Colors.transparent,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      disabledElevation: 0,
      highlightElevation: 0,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 14,
            child: Image.asset(
              "assets/Vector.png",
              scale: 1,
              color: Theme.of(screen.context).primaryColor,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            'Import',
            textScaleFactor: Get.textScaleFactor,
            style: DefaultTextStyle.of(screen.context).style.copyWith(
                  color: Theme.of(screen.context).primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
          ),
          const SizedBox(
            width: 10,
          ),
          Icon(
            IconlyLight.arrow_down_2,
            size: 14,
            color: Theme.of(screen.context).primaryColor,
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Theme.of(screen.context).primaryColor,
        ),
      ),
    );

    // DropdownButtonHideUnderline(
    //   child: DropdownButton2(
    //     dropdownWidth: 120,
    //     customButton: DecoratedBox(
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(8.0),
    //         border: Border.all(
    //           color: Theme.of(screen.context).primaryColor,
    //         ),
    //       ),
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(
    //           horizontal: 10,
    //           vertical: 10,
    //         ),
    //         child: Row(
    //           children: [
    //             // Icon(
    //             //   IconlyLight.upload,
    //             //   size: 14,
    //             //   color: Theme.of(screen.context).primaryColor,
    //             // ),
    //             SizedBox.square(
    //               dimension: 14,
    //               child: Image.asset(
    //                 "assets/Vector.png",
    //                 scale: 1,
    //                 color: Theme.of(screen.context).primaryColor,
    //               ),
    //             ),
    //             const SizedBox(
    //               width: 10,
    //             ),
    //             Text(
    //               'Import',
    //               textScaleFactor: Get.textScaleFactor,
    //               style: DefaultTextStyle.of(screen.context).style.copyWith(
    //                     color: Theme.of(screen.context).primaryColor,
    //                     fontSize: 14,
    //                     fontWeight: FontWeight.w400,
    //                   ),
    //             ),
    //             const SizedBox(
    //               width: 10,
    //             ),
    //             Icon(
    //               IconlyLight.arrow_down_2,
    //               size: 14,
    //               color: Theme.of(screen.context).primaryColor,
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //     items: <String>["CSV", 'PDF'].map((String value) {
    //       return DropdownMenuItem<String>(
    //         value: value,
    //         child: Text(value),
    //       );
    //     }).toList(),
    //     onChanged: (String? value) async {
    //       if ((value ?? '') == "CSV".tr) {
    //         print('"CSV".tr');
    //         // ontap;
    //         controller.importCSV();
    //       }
    //       print(value);
    //     },
    //   ),
    // );
  }
}
