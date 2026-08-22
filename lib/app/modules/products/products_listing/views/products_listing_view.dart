import 'package:cached_network_image/cached_network_image.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:iconly/iconly.dart';
import '../../../../../models/ProductDealType.dart';
import '../../../../../themes/app_theme.dart';
import '../../../../widgets/components/animated_submit_button.dart';
import '../../../../widgets/components/common_card.dart';
import '../../../../widgets/components/form_input_field.dart';
import '../../../../widgets/components/import_button.dart';
import '../../../../widgets/components/labled_textfield.dart';
import '../../../../widgets/components/reactive_datetime_picker.dart';
import '../../../../widgets/components/reactive_time_picker.dart';
import '../../../../widgets/components/table_datasrc_bundle.dart';
import '../../../../widgets/components/table_datasrc_productBundle.dart';
import '../../../../widgets/utils/padding_wrapper.dart';
import '../../components/image_viewer_for_product.dart';
import '../../scheduled_products/views/scheduled_products_view.dart';
import '../../published_products/views/published_products_view.dart';
import '../controllers/products_listing_controller.dart';

// DateTime startDate = DateTime(2000);
// DateTime endDate = DateTime(3000);

class ProductsListingView extends GetResponsiveView<ProductsListingController> {
  ProductsListingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return Obx(() => FlutterDashboardListView(
          shrinkWrap: true,
          slivers: [
            _addProductButtons(),
            // _upperbar(),
            _SingleProductCreationButtons(),
            _addGreenDealProductForm(context),
            _addHotDealProductForm(context),
            _addBulkProductForm(context),
            _BulkProductListViewForForm(),
            _BulkProductListView(),
          ],
        ));
  }

  Widget _addProductButtons() {
    return SliverVisibility(
      visible: !controller.showProductUploadForm.value &&
          !controller.showBulkProductUploadForm.value &&
          !controller.showBulkList.value,
      sliver: PaddingWrapper(
        isSliverItem: true,
        topPadding: screen.isDesktop ? 50 : 20,
        horizontalPadding: screen.isDesktop ? 60 : 20,
        child: FlutterDashboardListView.grid(
          isSliverItem: true,
          childCount: 4,
          mainAxisSpacing: screen.isPhone ? 20 : 50,
          crossAxisSpacing: screen.isPhone ? 20 : 50,
          gridDelegate: !screen.isPhone
              ? FlutterDashboardGridDelegates.columns_2(
                  width: screen.width,
                  length: 4,
                )
              : FlutterDashboardGridDelegates.columns_1(
                  width: screen.width,
                  length: 4,
                ),
          buildItem: (BuildContext context, int index) {
            return _cardItems()[index];
          },
          listType: FlutterDashboardListType.Grid,
        ),
      ),
    );
  }

  Widget _SingleProductCreationButtons() {
    return SliverVisibility(
      visible: controller.showProductUploadForm.value &&
          !controller.show_GreenDeal_ProductUploadForm.value &&
          !controller.show_HotDeal_ProductUploadForm.value &&
          !controller.showBulkProductUploadForm.value,
      sliver: PaddingWrapper(
        isSliverItem: true,
        topPadding: screen.isDesktop ? 50 : 20,
        horizontalPadding: screen.isDesktop ? 60 : 20,
        child: SliverToBoxAdapter(
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      onPressed: () {
                        controller.showProductUploadForm.toggle();
                      },
                      icon: Icon(
                        IconlyLight.arrow_left,
                        color: Theme.of(screen.context).primaryColor,
                      ))),
              const SizedBox(
                height: 10,
              ),
              FlutterDashboardListView.grid(
                isSliverItem: false,
                childCount: 2,
                mainAxisSpacing: screen.isPhone ? 20 : 50,
                crossAxisSpacing: screen.isPhone ? 20 : 50,
                gridDelegate: !screen.isPhone
                    ? FlutterDashboardGridDelegates.columns_2(
                        width: screen.width,
                        length: 2,
                      )
                    : FlutterDashboardGridDelegates.columns_1(
                        width: screen.width,
                        length: 2,
                      ),
                buildItem: (BuildContext context, int index) {
                  return _DealcardItems()[index];
                },
                listType: FlutterDashboardListType.Grid,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addGreenDealProductForm(BuildContext context) {
    screen.context = context;
    return SliverVisibility(
      visible: controller.show_GreenDeal_ProductUploadForm.value &&
          controller.showProductUploadForm.value,
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
                "Add new Green Deal Product",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.left,
              ),
              // _typeofdealsRow(context),
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
              // _buildProductImagesRow(),
              _buildImageCard(
                  controller.productImageUrl0, controller.isPicUploading0),
              const SizedBox(
                width: 30,
              ),
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
                    return _buildFormFieldsForGreenDeals(_form, context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addHotDealProductForm(BuildContext context) {
    return SliverVisibility(
      visible: controller.show_HotDeal_ProductUploadForm.value &&
          controller.showProductUploadForm.value,
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
                "Add new Hot Deal Product",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.left,
              ),
              // _typeofdealsRow(context),
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
              // _buildProductImagesRow(),
              _buildImageCard(
                  controller.productImageUrl0, controller.isPicUploading0),
              const SizedBox(
                width: 30,
              ),
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
                    return _buildFormFieldsForHotDeals(_form, context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImagesRow() {
    return Row(
      children: [
        _buildImageCard(
            controller.productImageUrl0, controller.isPicUploading0),
        const SizedBox(
          width: 30,
        ),
        _buildImageCard(
            controller.productImageUrl1, controller.isPicUploading1),
        const SizedBox(
          width: 30,
        ),
        _buildImageCard(
            controller.productImageUrl2, controller.isPicUploading2),
      ],
    );
  }

  Widget _buildImageCard(RxString imageUrl, RxBool loading) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          // decoration: BoxDecoration(),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(
              color: Color.fromARGB(255, 12, 2, 54),
              width: 2,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          color: Theme.of(screen.context).scaffoldBackgroundColor,
          child: InkWell(
            onTap: () {
              controller.pickImage(imageUrl, loading);
            },
            child: PicViewerProductLising(20, imageUrl, loading),
          ),
        ),
      ],
    );
  }

  Widget _addBulkProductForm(BuildContext context) {
    return SliverVisibility(
      visible: controller.showBulkProductUploadForm.value &&
          !controller.showBulkCSVList.value,
      sliver: PaddingWrapper(
        isSliverItem: true,
        topPadding: 10,
        horizontalPadding: screen.isDesktop ? 30 : 20,
        child: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  ImportButton(),
                ],
              ),
              // _typeofdealsRow(context),
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
              // _buildProductImagesRow(),
              _buildImageCard(
                  controller.productImageUrl0, controller.isPicUploading0),
              const SizedBox(
                width: 30,
              ),
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
                    return _buildFormFieldsForBulkUploads(_form, context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _BulkProductListViewForForm() {
    return SliverVisibility(
      visible: controller.showBulkList.value &&
          !controller.showBulkProductUploadForm.value,
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
                "Bulk Upload List View",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.left,
              ),
              // Text('${controller.ListOfValues}'),
              PaginatedDataTable(
                showCheckboxColumn: false,
                rowsPerPage: controller.products!.isEmpty
                    ? 1
                    : controller.products!.length < 10
                        ? controller.products!.length
                        : 10,
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('SKU')),
                  DataColumn(label: Text('price')),
                  DataColumn(label: Text('discount')),
                  DataColumn(label: Text('expires_on')),
                  DataColumn(label: Text('Available')),
                  DataColumn(label: Text('Action')),
                ],
                columnSpacing: 20,
                dataRowHeight: kMinInteractiveDimension + 20,
                source: DSforBundleProduct(controller.products!),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    onPressed: () {
                      controller.showBulkCSVList(false);
                      controller.showBulkList(false);
                      controller.products!.clear();
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
                  MaterialButton(
                    onPressed: () async {
                      // controller.FetchAndReset();
                      await controller.createProductFromList();
                      controller.showBulkCSVList(false);
                      controller.showBulkList(false);
                      controller.products!.clear();
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
                      'Complete',
                      textScaleFactor: Get.textScaleFactor,
                      style: DefaultTextStyle.of(screen.context).style,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _BulkProductListView() {
    return SliverVisibility(
      visible: controller.showBulkCSVList.value,
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
                "Bulk Upload List View",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.left,
              ),
              // Text('${controller.ListOfValues}'),
              Obx(() => PaginatedDataTable(
                    showCheckboxColumn: false,
                    rowsPerPage: controller.products!.isEmpty
                        ? 1
                        : controller.products!.length < 10
                            ? controller.products!.length
                            : 10,
                    columns: const [
                      DataColumn(label: Text('Image')),
                      DataColumn(label: Text('SKU')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('price')),
                      DataColumn(label: Text('discount')),
                      DataColumn(label: Text('created_on')),
                      DataColumn(label: Text('expires_on')),
                      DataColumn(label: Text('Action')),
                    ],
                    columnSpacing: 20,
                    dataRowHeight: kMinInteractiveDimension + 20,
                    source: DSforBundle(controller.products!),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    onPressed: () {
                      controller.showBulkCSVList(false);
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
                  MaterialButton(
                    onPressed: () async {
                      await controller.createProductFromList();
                      controller.showBulkCSVList(false);
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
                      'Complete',
                      textScaleFactor: Get.textScaleFactor,
                      style: DefaultTextStyle.of(screen.context).style,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFieldsForGreenDeals(FormGroup _form, BuildContext context) {
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
                hintText: " 300",
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
              label: "Offer Price",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "offer_price",
                hintText: "Offer Price",
                onEditingComplete: () => _form.focus("expiry_date"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validationMessage: (control) => "offer price can't be empty.",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(controller.shopCurrency.value),
            const SizedBox(
              height: 10,
            ),
            LabeledTextField(
              label: "Fresh Untill",
              isRequired: true,
              textfield: Row(
                children: [
                  ReactiveDatePickerField<DateTime>(
                    controlName: "expiry_date",
                    hintText: "DD/MM/YY",
                    onEditingComplete: () => _form.unfocus(),
                    validationMessage: (error) => "valid date required",
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ReactiveTimePickerField<TimeOfDay>(
                    controlName: "end_time",
                    hintText: "hh:mm",
                    onEditingComplete: () => _form.unfocus(),
                    validationMessage: (error) => "valid date required",
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Obx(() => Checkbox(
                      checkColor: Colors.white,
                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: controller.ScheduleisChecked.value,
                      shape: const CircleBorder(),
                      onChanged: (bool? value) {
                        print(value);
                        controller.PublishedisChecked(value!);
                        controller.ScheduleisChecked(true);
                      },
                    )),
                const Text('Publish Now')
              ],
            ),
            Row(
              children: [
                Obx(() => Checkbox(
                      checkColor: Colors.white,
                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: controller.ScheduleisChecked.value,
                      shape: const CircleBorder(),
                      onChanged: (bool? value) {
                        print(value);
                        controller.ScheduleisChecked(value!);
                        controller.PublishedisChecked(false);
                      },
                    )),
                const Text('Schedule Product ')
              ],
            ),
            Row(
              children: [
                ReactiveDatePickerField<DateTime>(
                  controlName: "visible_date",
                  hintText: "DD/MM/YY",
                  onEditingComplete: () => _form.unfocus(),
                  validationMessage: (error) => "valid date required",
                ),
                const SizedBox(
                  width: 10,
                ),
                ReactiveTimePickerField<TimeOfDay>(
                  controlName: "visible_time",
                  hintText: "hh:mm",
                  onEditingComplete: () => _form.unfocus(),
                  validationMessage: (error) => "valid date required",
                ),
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
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: LabeledTextField(
                    label: "Original Price ",
                    isRequired: true,
                    textfield: FormTextInputField<String>(
                      controlName: "actual_price",
                      hintText: " 300",
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
                    label: "Offer Price",
                    isRequired: true,
                    textfield: FormTextInputField<String>(
                      controlName: "offer_price",
                      hintText: " 200",
                      onEditingComplete: () => _form.focus("expiry_date"),
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
              Obx(() => Text(controller.shopCurrency.value)),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          LabeledTextField(
            label: "Fresh Untill",
            isRequired: true,
            textfield: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 180,
                    child: ReactiveDatePickerField<DateTime>(
                      controlName: "expiry_date",
                      hintText: "DD/MM/YY",
                      onEditingComplete: () => _form.unfocus(),
                      validationMessage: (error) => "valid date required",
                    ),
                  ),
                ),
                const SizedBox(
                  width: 25,
                ),
                Flexible(
                  child: SizedBox(
                    width: 180,
                    child: ReactiveTimePickerField<TimeOfDay>(
                      controlName: "end_time",
                      hintText: "hh:mm",
                      onEditingComplete: () => _form.unfocus(),
                      validationMessage: (error) => "valid date required",
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Obx(() => Checkbox(
                    checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: controller.PublishedisChecked.value,
                    shape: const CircleBorder(),
                    onChanged: (bool? value) {
                      print(value);
                      controller.PublishedisChecked(value);
                      controller.ScheduleisChecked(false);
                    },
                  )),
              const Text('Publish Now')
            ],
          ),
          Row(
            children: [
              Obx(() => Checkbox(
                    checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),

                    onChanged: (bool? value) {
                      print(value);
                      controller.ScheduleisChecked(value);
                      controller.PublishedisChecked(false);
                    },
                    value: controller.ScheduleisChecked.value,
                    shape: const CircleBorder(),
                  )),
              const Text('Schedule Product ')
            ],
          ),
          Row(
            children: [
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: ReactiveDatePickerField<DateTime>(
                    controlName: "visible_date",
                    hintText: "DD/MM/YY",
                    onEditingComplete: () => _form.unfocus(),
                    validationMessage: (error) => "valid date required",
                  ),
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              ReactiveTimePickerField<TimeOfDay>(
                controlName: "visible_time",
                hintText: "hh:mm",
                onEditingComplete: () => _form.unfocus(),
                validationMessage: (error) => "valid date required",
              ),
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

  Widget _buildFormFieldsForHotDeals(FormGroup _form, BuildContext context) {
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
              label: "Offer Price",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "offer_price",
                hintText: "Offer Price",
                onEditingComplete: () => _form.focus("expiry_date"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validationMessage: (control) => "offer price can't be empty.",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(controller.shopCurrency.value),
            const SizedBox(
              height: 10,
            ),
            LabeledTextField(
              label: "Start Date",
              isRequired: true,
              textfield: Row(
                children: [
                  ReactiveDatePickerField<DateTime>(
                    controlName: "start_date",
                    hintText: "DD/MM/YY",
                    onEditingComplete: () => _form.unfocus(),
                    validationMessage: (error) => "valid date required",
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ReactiveTimePickerField<TimeOfDay>(
                    controlName: "start_time",
                    hintText: "hh:mm",
                    onEditingComplete: () => _form.unfocus(),
                    validationMessage: (error) => "valid date required",
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            LabeledTextField(
              label: "End Date",
              isRequired: true,
              textfield: Row(
                children: [
                  ReactiveDatePickerField<DateTime>(
                    controlName: "expiry_date",
                    hintText: "DD/MM/YY",
                    onEditingComplete: () => _form.unfocus(),
                    validationMessage: (error) => "valid date required",
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ReactiveTimePickerField<TimeOfDay>(
                    controlName: "end_time",
                    hintText: "hh:mm",
                    onEditingComplete: () => _form.unfocus(),
                    validationMessage: (error) => "valid date required",
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Obx(() => Checkbox(
                      checkColor: Colors.white,
                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: controller.PublishedisChecked.value,
                      shape: const CircleBorder(),
                      onChanged: (bool? value) {
                        print(value);
                        controller.PublishedisChecked(value);
                        controller.ScheduleisChecked(false);
                      },
                    )),
                const Text('Publish Now')
              ],
            ),
            Row(
              children: [
                Obx(() => Checkbox(
                      checkColor: Colors.white,
                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: controller.ScheduleisChecked.value,
                      shape: const CircleBorder(),
                      onChanged: (bool? value) {
                        print(value);
                        controller.PublishedisChecked(value!);
                        controller.ScheduleisChecked(true);
                      },
                    )),
                const Text('Publish Now')
              ],
            ),
            Row(
              children: [
                Obx(() => Checkbox(
                      checkColor: Colors.white,
                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: controller.ScheduleisChecked.value,
                      shape: const CircleBorder(),
                      onChanged: (bool? value) {
                        print(value);
                        controller.ScheduleisChecked(value!);
                        controller.PublishedisChecked(false);
                      },
                    )),
                const Text('Schedule Product ')
              ],
            ),
            Row(
              children: [
                ReactiveDatePickerField<DateTime>(
                  controlName: "visible_date",
                  hintText: "DD/MM/YY",
                  onEditingComplete: () => _form.unfocus(),
                  validationMessage: (error) => "valid date required",
                ),
                const SizedBox(
                  width: 10,
                ),
                ReactiveTimePickerField<TimeOfDay>(
                  controlName: "visible_time",
                  hintText: "hh:mm",
                  onEditingComplete: () => _form.unfocus(),
                  validationMessage: (error) => "valid date required",
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            _buildHotDealButtons(),
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
                      hintText: " 300",
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
                    label: "Offer Price",
                    isRequired: true,
                    textfield: FormTextInputField<String>(
                      controlName: "offer_price",
                      hintText: " 200",
                      onEditingComplete: () => _form.focus("offer_percentage"),
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
              Obx(() => Text(controller.shopCurrency.value)),
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
                    label: "Start Date",
                    isRequired: true,
                    textfield: Row(
                      children: [
                        ReactiveDatePickerField<DateTime>(
                          controlName: "start_date",
                          hintText: "DD/MM/YY",
                          onEditingComplete: () => _form.unfocus(),
                          validationMessage: (error) => "valid date required",
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        ReactiveTimePickerField<TimeOfDay>(
                          controlName: "start_time",
                          hintText: "hh:mm",
                          onEditingComplete: () => _form.unfocus(),
                          validationMessage: (error) => "valid date required",
                        ),
                      ],
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
                    label: "End Date",
                    isRequired: true,
                    textfield: Row(
                      children: [
                        ReactiveDatePickerField<DateTime>(
                          controlName: "expiry_date",
                          hintText: "DD/MM/YY",
                          onEditingComplete: () => _form.unfocus(),
                          validationMessage: (error) => "valid date required",
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        ReactiveTimePickerField<TimeOfDay>(
                          controlName: "end_time",
                          hintText: "hh:mm",
                          onEditingComplete: () => _form.unfocus(),
                          validationMessage: (error) => "valid date required",
                        ),
                      ],
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
              Obx(() => Checkbox(
                    checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: controller.PublishedisChecked.value,
                    shape: const CircleBorder(),
                    onChanged: (bool? value) {
                      print(value);
                      controller.PublishedisChecked(value);
                      controller.ScheduleisChecked(false);
                    },
                  )),
              const Text('Publish Now')
            ],
          ),
          Row(
            children: [
              Obx(() => Checkbox(
                    checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),

                    onChanged: (bool? value) {
                      print(value);
                      controller.ScheduleisChecked(value);
                      controller.PublishedisChecked(false);
                    },
                    value: controller.ScheduleisChecked.value,
                    shape: const CircleBorder(),
                  )),
              const Text('Schedule Product ')
            ],
          ),
          Row(
            children: [
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: ReactiveDatePickerField<DateTime>(
                    controlName: "visible_date",
                    hintText: "DD/MM/YY",
                    onEditingComplete: () => _form.unfocus(),
                    validationMessage: (error) => "valid date required",
                  ),
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              ReactiveTimePickerField<TimeOfDay>(
                controlName: "visible_time",
                hintText: "hh:mm",
                onEditingComplete: () => _form.unfocus(),
                validationMessage: (error) => "valid date required",
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 850,
            child: _buildHotDealButtons(),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    }
  }

  Widget _buildFormFieldsForBulkUploads(FormGroup _form, BuildContext context) {
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
                hintText: " 300",
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
              label: "Offer Price",
              isRequired: true,
              textfield: FormTextInputField<String>(
                controlName: "offer_price",
                hintText: "Offer Price",
                onEditingComplete: () => _form.focus("expiry_date"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validationMessage: (control) => "offer price can't be empty.",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(controller.shopCurrency.value),
            const SizedBox(
              height: 10,
            ),
            LabeledTextField(
              label: "Fresh Untill",
              isRequired: true,
              textfield: Row(
                children: [
                  ReactiveDatePickerField<DateTime>(
                    controlName: "expiry_date",
                    hintText: "DD/MM/YY",
                    onEditingComplete: () => _form.unfocus(),
                    validationMessage: (error) => "valid date required",
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ReactiveTimePickerField<TimeOfDay>(
                    controlName: "end_time",
                    hintText: "hh:mm",
                    onEditingComplete: () => _form.unfocus(),
                    validationMessage: (error) => "valid date required",
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Obx(() => Checkbox(
                      checkColor: Colors.white,
                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: controller.ScheduleisChecked.value,
                      shape: const CircleBorder(),
                      onChanged: (bool? value) {
                        print(value);
                        controller.PublishedisChecked(value!);
                        controller.ScheduleisChecked(true);
                      },
                    )),
                const Text('Publish Now')
              ],
            ),
            Row(
              children: [
                Obx(() => Checkbox(
                      checkColor: Colors.white,
                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: controller.ScheduleisChecked.value,
                      shape: const CircleBorder(),
                      onChanged: (bool? value) {
                        print(value);
                        controller.ScheduleisChecked(value!);
                        controller.PublishedisChecked(false);
                      },
                    )),
                const Text('Schedule Product ')
              ],
            ),
            Row(
              children: [
                ReactiveDatePickerField<DateTime>(
                  controlName: "visible_date",
                  hintText: "DD/MM/YY",
                  onEditingComplete: () => _form.unfocus(),
                  validationMessage: (error) => "valid date required",
                ),
                const SizedBox(
                  width: 10,
                ),
                ReactiveTimePickerField<TimeOfDay>(
                  controlName: "visible_time",
                  hintText: "hh:mm",
                  onEditingComplete: () => _form.unfocus(),
                  validationMessage: (error) => "valid date required",
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            _buildBulkUploadButtons(),
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
                      hintText: " 300",
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
                    label: "Offer Price",
                    isRequired: true,
                    textfield: FormTextInputField<String>(
                      controlName: "offer_price",
                      hintText: " 200",
                      onEditingComplete: () => _form.focus("offer_percentage"),
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
              Obx(() => Text(controller.shopCurrency.value)),
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
                    label: "Fresh Untill",
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
              const SizedBox(
                width: 25,
              ),
              ReactiveTimePickerField<TimeOfDay>(
                controlName: "end_time",
                hintText: "hh:mm",
                onEditingComplete: () => _form.unfocus(),
                validationMessage: (error) => "valid date required",
              ),
            ],
          ),
          Row(
            children: [
              Obx(() => Checkbox(
                    checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: controller.PublishedisChecked.value,
                    shape: const CircleBorder(),
                    onChanged: (bool? value) {
                      print(value);
                      controller.PublishedisChecked(value);
                      controller.ScheduleisChecked(false);
                    },
                  )),
              const Text('Publish Now')
            ],
          ),
          Row(
            children: [
              Obx(() => Checkbox(
                    checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),
                    onChanged: (bool? value) {
                      print(value);
                      controller.ScheduleisChecked(value);
                      controller.PublishedisChecked(false);
                    },
                    value: controller.ScheduleisChecked.value,
                    shape: const CircleBorder(),
                  )),
              const Text('Schedule Product ')
            ],
          ),
          Row(
            children: [
              Flexible(
                child: SizedBox(
                  width: 180,
                  child: ReactiveDatePickerField<DateTime>(
                    controlName: "visible_date",
                    hintText: "DD/MM/YY",
                    onEditingComplete: () => _form.unfocus(),
                    validationMessage: (error) => "valid date required",
                  ),
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              ReactiveTimePickerField<TimeOfDay>(
                controlName: "visible_time",
                hintText: "hh:mm",
                onEditingComplete: () => _form.unfocus(),
                validationMessage: (error) => "valid date required",
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 850,
            child: _buildBulkUploadButtons(),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    }
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MaterialButton(
          onPressed: () {
            controller.showProductUploadForm(false);
            controller.show_GreenDeal_ProductUploadForm(false);
            controller.show_HotDeal_ProductUploadForm(false);
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
                                children: const [
                                  Text(
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
                                          imageUrl:
                                              controller.productImageUrl0.value,
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
                                        'Best Before ${controller.ExpDate}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Publish to ${controller.Dealtype.value.name.toString()}',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.green),
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
  }

  Widget _buildHotDealButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MaterialButton(
          onPressed: () {
            controller.showProductUploadForm(false);
            controller.show_GreenDeal_ProductUploadForm(false);
            controller.show_HotDeal_ProductUploadForm(false);
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
                                children: const [
                                  Text(
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
                                          imageUrl:
                                              controller.productImageUrl0.value,
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
                                        'Start Date ${controller.StrDate}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        'End Date ${controller.ExpDate}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Scheduled On ${controller.SchDate}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Publish to ${ProductDealType.HOTDEALS.name}',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.green),
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
                                        controller.showProductUploadForm(false);
                                        controller
                                            .show_GreenDeal_ProductUploadForm(
                                                false);
                                        controller
                                            .show_HotDeal_ProductUploadForm(
                                                false);
                                        controller
                                            .showBulkProductUploadForm(false);
                                      },
                                    ),
                                    AnimatedSubmitButton(
                                        width: 90,
                                        buttonText: 'Confirm',
                                        onPressed: () async {
                                          controller.createHotDealProduct();
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
  }

  Widget _buildBulkUploadButtons() {
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
                  await controller.createProductFromList();
                  await controller.FetchAndReset();
                  await controller.uploadBulkProducts();
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
                  controller.FetchAndReset();
                  // controller.createProduct();
                },
                textColor: AppColors.white,
                radius: 8.0,
                color: AppColors.green,
                width: double.maxFinite,
                buttonText: 'Add More',
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
                      await controller.FetchAndReset();
                      await controller.uploadBulkProducts();
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
                      controller.FetchAndReset();
                    },
                    textColor: AppColors.white,
                    radius: 8.0,
                    color: AppColors.green,
                    width: double.maxFinite,
                    buttonText: 'Add More',
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _typeofdealsRow(BuildContext context) {
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
                  Obx(() => Checkbox(
                        checkColor: Colors.white,
                        // fillColor: MaterialStateProperty.resolveWith(getColor),
                        value: controller.GreenDealChecked.value,
                        shape: const CircleBorder(),
                        onChanged: (bool? value) {
                          print("Green Deal ");
                          controller.GreenDealChecked(value);
                          controller.RedDealChecked(false);
                          controller.hotDealChecked(false);
                          controller.Dealtype(ProductDealType.GREENDEALS);
                        },
                      )),
                  const Text('GREENDEAL')
                ],
              ),
              Row(
                children: [
                  Obx(() => Checkbox(
                        checkColor: Colors.white,
                        // fillColor: MaterialStateProperty.resolveWith(getColor),
                        value: controller.RedDealChecked.value,
                        shape: const CircleBorder(),
                        onChanged: (bool? value) {
                          print("Red Deal ");
                          controller.RedDealChecked(value);
                          controller.GreenDealChecked(false);
                          controller.hotDealChecked(false);
                          controller.Dealtype(ProductDealType.REDDEALS);
                        },
                      )),
                  const Text('REDDEALS')
                ],
              ),
              Row(
                children: [
                  Obx(() => Checkbox(
                        checkColor: Colors.white,
                        // fillColor: MaterialStateProperty.resolveWith(getColor),
                        value: controller.hotDealChecked.value,
                        shape: const CircleBorder(),
                        onChanged: (bool? value) {
                          print("Hot Deal ");
                          controller.hotDealChecked(value);
                          controller.GreenDealChecked(false);
                          controller.RedDealChecked(false);
                          controller.Dealtype(ProductDealType.HOTDEALS);
                        },
                      )),
                  const Text('HOTDEALS')
                ],
              ),
            ]),
      ],
    );
  }

  List<Widget> _cardItems() {
    return [
      _buildCard(
        text: 'Add New Product',
        onPressed: () {
          controller.showProductUploadForm(true);
        },
      ),
      _buildCard(
        text: 'Create Bulk products',
        onPressed: () {
          controller.showBulkProductUploadForm(true);
        },
      ),
      _buildCard(
        text: 'Scheduled Products',
        onPressed: () => Navigator.push(
          screen.context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Scheduled Products')),
              body: ScheduledProductsView(),
            ),
          ),
        ),
      ),
      _buildCard(
        text: 'Published Products',
        onPressed: () => Navigator.push(
          screen.context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Published Products')),
              body: PublishedProductsView(),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _DealcardItems() {
    return [
      _buildCard(
        text: 'Green Deal',
        onPressed: () {
          controller.show_GreenDeal_ProductUploadForm(true);
        },
      ),
      _buildCard(
        text: 'HotDeal',
        onPressed: () {
          controller.show_HotDeal_ProductUploadForm(true);
        },
      ),
    ];
  }

  Widget _buildCard({required String text, required VoidCallback onPressed}) {
    return CommonCard(
      onTap: onPressed,
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.plus,
            color: DefaultTextStyle.of(screen.context).style.color,
            size: 50,
          ),
          const Divider(
            color: Colors.transparent,
          ),
          Text(
            text,
            textScaleFactor: Get.textScaleFactor,
            style: DefaultTextStyle.of(screen.context).style.copyWith(
                  fontSize:
                      Theme.of(screen.context).textTheme.titleLarge?.fontSize,
                ),
          ),
        ],
      ),
    );
  }
}

class CustomMaterialButton extends StatelessWidget {
  const CustomMaterialButton({
    Key? key,
    required this.controller,
    required this.screen,
    required this.text,
    required this.onPressed,
    // required this.screen,
  }) : super(key: key);

  final ProductsListingController controller;
  final ResponsiveScreen screen;
  final String text;
  final VoidCallback? onPressed;
  // final ResponsiveScreen screen;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Theme.of(screen.context).primaryColor,
        ),
      ),
      height: 46,
      minWidth: 120,
      child: Text(
        text,
        textScaleFactor: Get.textScaleFactor,
        style: DefaultTextStyle.of(screen.context).style,
      ),
    );
  }
}
