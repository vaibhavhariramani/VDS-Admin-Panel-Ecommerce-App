import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../../widgets/components/form_input_field.dart';
import '../../../../../widgets/components/labled_textfield.dart';
import '../../../../../widgets/components/reactive_datetime_picker.dart';
import '../../../../home/views/home_view.dart';
import '../../../products_listing/views/products_listing_view.dart';
import 'build_buttons.dart';

class buildFormFields extends GetResponsiveView {
  final FormGroup form;
  buildFormFields({required this.form, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    if (screen.isPhone) {
      return Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 5,
                bottom: 10,
              ),
              child: Text(
                'Product Details'.tr,
                textScaleFactor: Get.textScaleFactor,
                style: DefaultTextStyle.of(screen.context).style.copyWith(
                      fontSize: 18,
                    ),
              ),
            ),
            LabeledTextField(
              label: "SKU  ",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "sku",
                hintText: "#28282828",
                onEditingComplete: () => form.focus("actual_price"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                validationMessage: (control) => "SKU can't be empty.",
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            LabeledTextField(
              label: "Name of Product",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "productname",
                hintText: "Product Name",
                onEditingComplete: () => form.focus("brand"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                validationMessage: (control) => "Product Name can't be empty.",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            LabeledTextField(
              label: "Brand",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "brand",
                hintText: "Brand",
                onEditingComplete: () => form.focus("sku"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                validationMessage: (control) => "Brand can't be empty.",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 5,
                bottom: 10,
              ),
              child: Text(
                'Product Details'.tr,
                textScaleFactor: Get.textScaleFactor,
                style: DefaultTextStyle.of(screen.context).style.copyWith(
                      fontSize: 18,
                    ),
              ),
            ),
            LabeledTextField(
              label: "Original Price ",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "actual_price",
                hintText: "\$ 300",
                onEditingComplete: () => form.focus("offer_price"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validationMessage: (control) => "Actual Price can't be empty.",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            LabeledTextField(
              label: "Offer Price",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "offer_price",
                hintText: "Offer Price",
                onEditingComplete: () => form.focus("category"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validationMessage: (control) => "Brand can't be empty.",
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text('or'),
            const SizedBox(
              height: 5,
            ),
            LabeledTextField(
              label: "Offer Percentage",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "offer_percentage",
                hintText: "Offer Price",
                onEditingComplete: () => form.focus("category"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validationMessage: (control) => "Brand can't be empty.",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            LabeledTextField(
              label: "Best before",
              isRequired: true,
              textfield: ReactiveDatePickerField<DateTime>(
                controlName: "expiry_date",
                hintText: "DD/MM/YY",
                onEditingComplete: () => form.unfocus(),
                validationMessage: (error) => "valid required",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Checkbox(
                  checkColor: Colors.white,
                  // fillColor: MaterialStateProperty.resolveWith(getColor),
                  value: controller.ScheduleisChecked.value,
                  shape: const CircleBorder(),
                  onChanged: (bool? value) {
                    print(value);
                    controller.ScheduleisChecked.value = value!;
                  },
                ),
                const Text('Schedule Product ')
              ],
            ),
            SizedBox(
              height: 250,
              width: 250,
              child: SfDateRangePicker(
                minDate: startDate,
                maxDate: endDate,
                showActionButtons: false,
                showTodayButton: false,
                enablePastDates: true,
                view: DateRangePickerView.month,
                viewSpacing: 5,
                showNavigationArrow: true,
                todayHighlightColor: Theme.of(screen.context).primaryColor,
                selectionColor: Theme.of(screen.context).primaryColor,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  print(args.value);
                },
              ),
            ),
            Row(
              children: [
                Checkbox(
                  checkColor: Colors.white,
                  // fillColor: MaterialStateProperty.resolveWith(getColor),
                  value: controller.ScheduleisChecked.value,
                  shape: const CircleBorder(),
                  onChanged: (bool? value) {
                    print(value);
                    controller.PublishedisChecked.value = value!;
                  },
                ),
                const Text('Publish Now')
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            buildButtons(),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 5,
              bottom: 10,
            ),
            child: Text(
              'Product Details'.tr,
              textScaleFactor: Get.textScaleFactor,
              style: DefaultTextStyle.of(screen.context).style.copyWith(
                    fontSize: 18,
                  ),
            ),
          ),
          Row(
            children: [],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: LabeledTextField(
                    label: "SKU  ",
                    isRequired: true,
                    textfield: FormTextInputField<String>(
                      controlName: "sku",
                      hintText: "#28282828",
                      onEditingComplete: () => form.focus("actual_price"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validationMessage: (control) => "sku can't be empty.",
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: LabeledTextField(
                    label: "Product Name",
                    isRequired: true,
                    textfield: FormTextInputField<String>(
                      controlName: "productname",
                      hintText: "Product Name",
                      onEditingComplete: () => form.focus("brand"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      validationMessage: (control) =>
                          "Product Name can't be empty.",
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: LabeledTextField(
                    label: "Brand",
                    isRequired: true,
                    textfield: FormTextInputField<String>(
                      controlName: "brand",
                      hintText: "Brand",
                      onEditingComplete: () => form.focus("sku"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      validationMessage: (control) => "Brand can't be empty.",
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 25,
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 5,
              bottom: 10,
            ),
            child: Text(
              'Product Pricing'.tr,
              textScaleFactor: Get.textScaleFactor,
              style: DefaultTextStyle.of(screen.context).style.copyWith(
                    fontSize: 18,
                  ),
            ),
          ),
          Row(
            children: [
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: LabeledTextField(
                    label: "Original Price ",
                    isRequired: true,
                    textfield: FormTextInputField<String>(
                      controlName: "actual_price",
                      hintText: "\$ 300",
                      onEditingComplete: () => form.focus("offer_price"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validationMessage: (control) =>
                          "Original Price can't be empty.",
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: LabeledTextField(
                    label: "Offer Price",
                    isRequired: true,
                    textfield: FormTextInputField<String>(
                      controlName: "offer_price",
                      hintText: "\$ 200",
                      onEditingComplete: () => form.focus("offer_percentage"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validationMessage: (control) =>
                          "offer price can't be empty.",
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: LabeledTextField(
                    label: "Offer Percentage",
                    isRequired: true,
                    textfield: FormTextInputField<String>(
                      controlName: "offer_percentage",
                      hintText: "% 50",
                      onEditingComplete: () => form.focus("expiry_date"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validationMessage: (control) =>
                          "offer percentage can't be empty.",
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: LabeledTextField(
                    label: "Best before",
                    isRequired: true,
                    // textfield: FormTextInputField<DateTime>(
                    //   controlName: "expiry_date",
                    //   hintText: "DD/MM/YY",
                    //   onEditingComplete: () => _form.unfocus(),
                    //   textInputAction: TextInputAction.done,
                    //   keyboardType: TextInputType.datetime,
                    //   validationMessage: (control) => {
                    //     ValidationMessage.required: "Brand can't be empty.",
                    //   },
                    // ),
                    textfield: ReactiveDatePickerField<DateTime>(
                      controlName: "expiry_date",
                      hintText: "DD/MM/YY",
                      onEditingComplete: () => form.unfocus(),
                      validationMessage: (error) => "valid date required",
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Checkbox(
                checkColor: Colors.white,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: controller.ScheduleisChecked.value,
                shape: const CircleBorder(),
                onChanged: (bool? value) {
                  print(value);
                  controller.ScheduleisChecked.value = value!;
                },
              ),
              const Text('Schedule Product ')
            ],
          ),
          SizedBox(
            height: 250,
            width: 250,
            child: SfDateRangePicker(
              minDate: startDate,
              maxDate: endDate,
              showActionButtons: false,
              showTodayButton: false,
              enablePastDates: true,
              view: DateRangePickerView.month,
              viewSpacing: 5,
              showNavigationArrow: true,
              todayHighlightColor: Theme.of(screen.context).primaryColor,
              selectionColor: Theme.of(screen.context).primaryColor,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                print(args.value);
              },
            ),
          ),
          Row(
            children: [
              Checkbox(
                checkColor: Colors.white,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: controller.ScheduleisChecked.value,
                shape: const CircleBorder(),
                onChanged: (bool? value) {
                  print(value);
                  controller.PublishedisChecked.value = value!;
                },
              ),
              const Text('Publish Now')
            ],
          ),
          Row(
            children: [
              Checkbox(
                checkColor: Colors.white,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: controller.ScheduleisChecked.value,
                shape: const CircleBorder(),
                onChanged: (bool? value) {
                  print(value);
                  controller.hotdealisChecked.value = value!;
                },
              ),
              const Text('Hot Deal ')
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 850,
            child: buildButtons(),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    }
  }
}
