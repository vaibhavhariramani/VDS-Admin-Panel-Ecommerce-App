import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../../../themes/app_theme.dart';
import '../../../../../widgets/components/animated_submit_button.dart';
import '../../../../../widgets/components/form_input_field.dart';
import '../../../../../widgets/components/labled_textfield.dart';
import '../../../../../widgets/components/reactive_datetime_picker.dart';
import '../../../../../widgets/utils/padding_wrapper.dart';
import '../../../../home/views/home_view.dart';
import '../../controllers/products_listing_controller.dart';
import '../components/image_row.dart';
import '../products_listing_view.dart';

class GreenDealProductForm
    extends GetResponsiveView<ProductsListingController> {
  GreenDealProductForm({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverVisibility(
      visible: controller.show_GreenDeal_ProductUploadForm.value,
      sliver: PaddingWrapper(
        isSliverItem: true,
        topPadding: 10,
        horizontalPadding: screen.isDesktop ? 30 : 20,
        child: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Add new Product",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.left,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 20,
                ),
                child: Text(
                  'Product Image'.tr,
                  textScaleFactor: Get.textScaleFactor,
                  style: DefaultTextStyle.of(screen.context).style.copyWith(
                        fontSize: 18,
                      ),
                ),
              ),
              const Divider(
                color: Colors.transparent,
                height: 20,
              ),
              buildProductImagesRow(),
              const Divider(
                color: Colors.transparent,
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                  bottom: 10,
                ),
                child: ReactiveFormBuilder(
                  form: () => controller.productAddForm,
                  builder:
                      (BuildContext context, FormGroup _form, Widget? child) {
                    return _buildFormFields(_form, context);
                  },
                ),
              ),
            ],
          ),
        ),
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
                onEditingComplete: () => _form.focus("actual_price"),
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
                onEditingComplete: () => _form.focus("actual_price"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                validationMessage: (control) => "Product Name can't be empty.",
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
                onEditingComplete: () => _form.focus("offer_price"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validationMessage: (control) => "Actual Price can't be empty.",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            LabeledTextField(
              label: "Offer percentage/Price",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "offer_price",
                hintText: "Offer Price",
                onEditingComplete: () => _form.focus("category"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validationMessage: (control) => "Brand can't be empty.",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            LabeledTextField(
              label: "Schedule Date",
              isRequired: true,
              textfield: ReactiveDatePickerField<DateTime>(
                controlName: "schedule_date",
                hintText: "DD/MM/YY",
                onEditingComplete: () => _form.unfocus(),
                validationMessage: (error) => "valid date time required",
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
                onEditingComplete: () => _form.unfocus(),
                validationMessage: (error) => "valid date time required",
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
            _buildButtons(),
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
                      onEditingComplete: () => _form.focus("actual_price"),
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
                      onEditingComplete: () => _form.focus("brand"),
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
                      onEditingComplete: () => _form.focus("offer_price"),
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
                    label: "Offer Percentage/Price",
                    isRequired: true,
                    textfield: FormTextInputField<String>(
                      controlName: "offer_price",
                      hintText: "\$ 200",
                      onEditingComplete: () => _form.focus("offer_percentage"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validationMessage: (control) =>
                          "offer price can't be empty.",
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
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: LabeledTextField(
                    label: "Schedule Date",
                    isRequired: true,
                    textfield: ReactiveDatePickerField<DateTime>(
                      controlName: "schedule_date",
                      hintText: "DD/MM/YY",
                      onEditingComplete: () => _form.unfocus(),
                      validationMessage: (error) => "valid date required",
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
                    textfield: ReactiveDatePickerField<DateTime>(
                      controlName: "expiry_date",
                      hintText: "DD/MM/YY",
                      onEditingComplete: () => _form.unfocus(),
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
          // Flexible(
          //   child: SizedBox(
          //     width: 180,
          //     child: LabeledTextField(
          //       label: "Schedule Date",
          //       isRequired: true,
          //       textfield: ReactiveDatePickerField<DateTime>(
          //         controlName: "schedule_date",
          //         hintText: "DD/MM/YY",
          //         onEditingComplete: () => _form.unfocus(),
          //       ),
          //     ),
          //   ),
          // ),
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
                  controller.Dealtype;
                },
              ),
              const Text('GreenDeals')
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 850,
            child: _buildButtons(),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    }
  }

  Widget _buildButtons() {
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Preview',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
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
                                                  fontSize: 26),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'Actual Price: ${controller.productAddForm.value["actual_price"].toString()}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  color: Colors.green),
                                            ),
                                            Text(
                                              'Offer Price: ${controller.productAddForm.value["offer_price"].toString()}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  color: Colors.green),
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
                                          'Best Before ${controller.productAddForm.value["expiry_date"].toString().substring(0, 10)}',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'Scheduled On ${controller.productAddForm.value["schedule_date"].toString().substring(0, 10)}',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'Publish to ${controller.Dealtype.value.name.toString()}',
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
                                      CustomMaterialButton(
                                        controller: controller,
                                        screen: screen,
                                        text: 'Cancel',
                                        onPressed: () {
                                          controller
                                              .showBulkProductUploadForm(false);
                                          Get.back();
                                        },
                                      ),
                                      AnimatedSubmitButton(
                                          width: 90,
                                          buttonText: 'Confirm',
                                          onPressed: () async {
                                            controller.createProduct();
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
            CustomMaterialButton(
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
