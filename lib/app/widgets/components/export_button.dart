import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:iconly/iconly.dart';

class ExportButton extends GetResponsiveView {
  ExportButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        // dropdownWidth: 120,
        customButton: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Theme.of(screen.context).primaryColor,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Row(
              children: [
                // Icon(
                //   IconlyLight.upload,
                //   size: 14,
                //   color: Theme.of(screen.context).primaryColor,
                // ),
                SizedBox.square(
                  dimension: 14,
                  child: Image.asset(
                    "assets/external-link.png",
                    scale: 1,
                    color: Theme.of(screen.context).primaryColor,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'Export',
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
          ),
        ),
        items: <String>["CSV", 'PDF'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value) {
          print(value);
        },
      ),
    );
  }
}
