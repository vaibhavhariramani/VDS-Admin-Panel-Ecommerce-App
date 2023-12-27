import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../models/ProductDealType.dart';
import '../../controllers/master_list_controller.dart';

class typeofdealsRow extends GetResponsiveView<MasterListController> {
  // Future<void> ontap;
  typeofdealsRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 0,
            bottom: 10,
          ),
          child: Text(
            'Select Category'.tr,
            textAlign: TextAlign.left,
            textScaleFactor: Get.textScaleFactor,
            style: DefaultTextStyle.of(screen.context).style.copyWith(
                  fontSize: 18,
                ),
          ),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: controller.GreenDealChecked.value,
                    shape: const CircleBorder(),
                    onChanged: (bool? value) {
                      print("Green Deal $value");
                      controller.GreenDealChecked(value);
                      controller.RedDealChecked(false);
                      controller.hotDealChecked(false);
                      controller.Dealtype(ProductDealType.GREENDEALS);
                    },
                  ),
                  const Text('GREENDEAL')
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: controller.RedDealChecked.value,
                    shape: const CircleBorder(),
                    onChanged: (bool? value) {
                      print("Red Deal $value");
                      controller.RedDealChecked(value);
                      controller.GreenDealChecked(false);
                      controller.hotDealChecked(false);
                      controller.Dealtype(ProductDealType.REDDEALS);
                    },
                  ),
                  const Text('REDDEALS')
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: controller.hotDealChecked.value,
                    shape: const CircleBorder(),
                    onChanged: (bool? value) {
                      print("Hot Deal $value");
                      controller.hotDealChecked(value);
                      controller.GreenDealChecked(false);
                      controller.RedDealChecked(false);
                      controller.Dealtype(ProductDealType.HOTDEALS);
                    },
                  ),
                  const Text('HOTDEALS')
                ],
              ),
            ]),
      ],
    );
  }
}
