import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:vdsadmin/app/modules/shop_listing/views/widgets/shop_details_table.dart';
import 'package:vdsadmin/app/modules/shop_listing/views/widgets/shop_header.dart';
import '../../../widgets/components/export_button.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../../../widgets/utils/shimmer_helper.dart';
import '../../deletion_status/controllers/deletion_status_controller.dart';
import '../../deletion_status/views/deletion_status_view.dart';
import '../../merchants/controllers/merchants_controller.dart';
import '../controllers/shop_listing_controller.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import 'components/shop_card.dart';
import 'components/shop_detailscard.dart';
import 'components/shop_image.dart';
import 'invite_shop.dart';

class ShopListingForSuperadmin
    extends GetResponsiveView<ShopListingController> {
  ShopListingForSuperadmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MerchantsController merchantsController = Get.find<MerchantsController>();
    screen.context = context;
    DeletionStatusController deletionStatusController =
        Get.find<DeletionStatusController>();

    return Obx(
      () => FlutterDashboardListView(
        shrinkWrap: true,
        // scrollController: ScrollController(),
        slivers: [
          SliverVisibility(
            visible: deletionStatusController.isVisible.value,
            sliver: SliverToBoxAdapter(
              child: DeletionStatusView(),
            ),
          ),
          SliverVisibility(
            visible: !controller.isLoading.value &&
                controller.allShops1.isNotEmpty &&
                !controller.showShopDetails.value &&
                controller.createNewShop.value &&
                !deletionStatusController.isVisible.value,
            sliver: ShopListingHeader(
              title: "We are in List Of shops",
              subTitle: "Shops Listed",
              totalCount: controller.allShops.length,
              onCreateNew: () {
                print('created new shop');
                controller.createNewShop(true);
              },
              actions: [],
            ),
          ),
          SliverVisibility(
            visible: !controller.isLoading.value &&
                controller.allShops.isNotEmpty &&
                !controller.showShopDetails.value &&
                controller.createNewShop.value,
            sliver: SliverToBoxAdapter(
              child: AddShopView(),
            ),
          ),
          SliverVisibility(
            visible: controller.isLoading.value &&
                controller.allShops.isEmpty &&
                !controller.showShopDetails.value &&
                !controller.createNewShop.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              topPadding: 5,
              horizontalPadding: screen.isDesktop ? 40 : 10,
              child: ShimmerHelper.buildGridShimmer(
                sliverItem: true,
                screen: screen,
                showIcon: true,
              ),
            ),
          ),
          SliverVisibility(
            visible: controller.showShopDetails.value &&
                !controller.createNewShop.value,
            sliver: PaddingWrapper(
                isSliverItem: true,
                topPadding: 20,
                horizontalPadding: screen.isDesktop ? 30 : 20,
                child: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      screen.isPhone
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          controller.showShopDetails(false);
                                        },
                                        icon: const Icon(Icons.arrow_back)),
                                    const Text("Back"),
                                  ],
                                ),
                                Center(child: _buildButtons(context)),
                              ],
                            )
                          : Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      controller.showShopDetails(false);
                                    },
                                    icon: const Icon(Icons.arrow_back)),
                                const Text("Back"),
                                const Spacer(),
                                _buildButtons(context),
                              ],
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      screen.isPhone
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ShopImageCard(controller.shopdetails),
                                ShopDetailsCard(controller.shopdetails),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShopImageCard(controller.shopdetails),
                                Center(
                                    child: ShopDetailsCard(
                                        controller.shopdetails)),
                              ],
                            ),
                      ShopDetailTable(),
                    ],
                  ),
                )),
          ),
          SliverVisibility(
            visible: !controller.isLoading.value &&
                controller.allShops.isNotEmpty &&
                !controller.showShopDetails.value &&
                !controller.createNewShop.value,
            sliver: ShopListingHeader(
              title: "Shops",
              subTitle: "Shops Listed",
              totalCount: controller.allShops.length,
              onCreateNew: () {
                controller.createNewShop(true);
                print('pressed from shop l');
              },
              actions: [
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    // dropdownWidth: 120,
                    customButton: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Theme.of(screen.context).disabledColor,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Today',
                              textScaleFactor: Get.textScaleFactor,
                              style: DefaultTextStyle.of(screen.context)
                                  .style
                                  .copyWith(
                                    color:
                                        Theme.of(screen.context).disabledColor,
                                    fontSize: 14,
                                  ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Icon(
                              IconlyLight.arrow_down_2,
                              size: 14,
                              color: Theme.of(screen.context).disabledColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    items: <String>[
                      '01/12/2020',
                      '01/12/2021',
                      '01/12/2022',
                      '01/12/2023'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      print(value);
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ExportButton(),
              ],
            ),
          ),
          SliverVisibility(
            visible: !controller.isLoading.value &&
                controller.allShops.isNotEmpty &&
                !controller.showShopDetails.value &&
                !controller.createNewShop.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              topPadding: 5,
              horizontalPadding: screen.isDesktop ? 40 : 10,
              child: FlutterDashboardListView.grid(
                isSliverItem: true,
                childCount: controller.allShops.length,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                gridDelegate: !screen.isDesktop
                    ? screen.width <= 756
                        ? FlutterDashboardGridDelegates.columns_1(
                            width: screen.width,
                            length: controller.allShops.length,
                          )
                        : FlutterDashboardGridDelegates.columns_2(
                            width: screen.width,
                            length: controller.allShops.length,
                          )
                    : screen.width <= 1700
                        ? screen.width <= 1450
                            ? screen.width <= 1240
                                ? FlutterDashboardGridDelegates.columns_2(
                                    width: screen.width,
                                    length: controller.allShops.length,
                                  )
                                : FlutterDashboardGridDelegates.columns_3(
                                    width: screen.width,
                                    length: controller.allShops.length,
                                  )
                            : FlutterDashboardGridDelegates.columns_3(
                                width: screen.width,
                                length: controller.allShops.length,
                              )
                        : FlutterDashboardGridDelegates.columns_5(
                            width: screen.width,
                            length: controller.allShops.length,
                          ),
                // gridDelegate:
                buildItem: (BuildContext context, int index) {
                  return ShopCard(
                    isMasterListItem: true,
                    shopItem: controller.allShops1[index],
                    index: index,
                  );
                },
                listType: FlutterDashboardListType.Grid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // MaterialButton(
        //   onPressed: () async {
        //     // await Future.delayed(2.seconds);
        //     Get.dialog(Center(
        //       child: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Material(
        //             borderRadius: BorderRadius.circular(15.0),
        //             clipBehavior: Clip.hardEdge,
        //             child: SizedBox(
        //               height: 485,
        //               width: 492,
        //               child: Column(
        //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                 children: [
        //                   Padding(
        //                     padding: const EdgeInsets.only(top: 15),
        //                     child: Padding(
        //                       padding: const EdgeInsets.only(right: 35),
        //                       child: Row(
        //                         mainAxisAlignment: MainAxisAlignment.end,
        //                         children: [
        //                           SizedBox(
        //                             width: 245,
        //                             child: Row(
        //                               mainAxisAlignment:
        //                                   MainAxisAlignment.spaceBetween,
        //                               children: [
        //                                 const Text(
        //                                   'Preview',
        //                                   style: TextStyle(
        //                                       color: Colors.green,
        //                                       fontSize: 32,
        //                                       fontWeight: FontWeight.w600),
        //                                 ),
        //                                 const SizedBox(
        //                                   width: 10,
        //                                 ),
        //                                 IconButton(
        //                                   color: Colors.green,
        //                                   iconSize: 22,
        //                                   icon: const Icon(Icons.edit),
        //                                   onPressed: () {
        //                                     Get.back();
        //                                   },
        //                                 )
        //                               ],
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                   ),
        //                   SizedBox(
        //                     child: Padding(
        //                       padding:
        //                           const EdgeInsets.symmetric(horizontal: 15),
        //                       child: Row(
        //                         mainAxisAlignment:
        //                             MainAxisAlignment.spaceAround,
        //                         children: [
        //                           Container(
        //                             width: 145,
        //                             height: 142,
        //                             clipBehavior: Clip.hardEdge,
        //                             decoration: BoxDecoration(
        //                               borderRadius: BorderRadius.circular(5),
        //                             ),
        //                             child: CachedNetworkImage(
        //                               imageUrl: controller
        //                                   .shopdetails.value.img_token![0],
        //                               fit: BoxFit.cover,
        //                             ),
        //                           ),
        //                           ReactiveFormBuilder(
        //                               form: () => controller.editForm1,
        //                               builder: (BuildContext context,
        //                                   FormGroup _form, Widget? child) {
        //                                 return Obx(
        //                                   () => Column(
        //                                     children: [
        //                                       Expanded(
        //                                         flex: 55,
        //                                         child: LabeledTextField(
        //                                           label: 'Shop Name',
        //                                           textfield: FormTextInputField(
        //                                             readOnly: controller
        //                                                 .isEditing.isFalse,
        //                                             controlName: 'shop_name',
        //                                             hintText: controller
        //                                                     .shopdetails
        //                                                     .value
        //                                                     .name ??
        //                                                 "shop name",
        //                                             onEditingComplete: () =>
        //                                                 _form.focus(
        //                                                     'shop_user_id'),
        //                                             keyboardType:
        //                                                 TextInputType.text,
        //                                             textInputAction:
        //                                                 TextInputAction.next,
        //                                             validationMessage:
        //                                                 (control) => {
        //                                               ValidationMessage
        //                                                       .required:
        //                                                   'Shop name not be empty',
        //                                             },
        //                                           ),
        //                                         ),
        //                                       ),
        //                                       const SizedBox(
        //                                         width: 20,
        //                                       ),
        //                                       // Expanded(
        //                                       //   flex: 45,
        //                                       //   child: LabeledTextField(
        //                                       //       label: 'Shop Admin Id',
        //                                       //       textfield: FormTextInputField(
        //                                       //         readOnly: true,
        //                                       //         controlName: 'shop_user_id',
        //                                       //         hintText: controller.shopdetails.value.usersID ?? 'Shop User ID',
        //                                       //         onEditingComplete: () => _form.unfocus(),
        //                                       //         keyboardType: TextInputType.text,
        //                                       //         textInputAction: TextInputAction.next,
        //                                       //         validationMessage: (control) => {
        //                                       //           ValidationMessage.required: 'ID can not be empty',
        //                                       //         },
        //                                       //       )),
        //                                       // ),
        //                                     ],
        //                                   ),
        //                                 );
        //                               }),
        //                         ],
        //                       ),
        //                     ),
        //                   ),
        //                   Padding(
        //                     padding: const EdgeInsets.only(left: 50),
        //                     child: SizedBox(
        //                       width: double.infinity,
        //                       child: Column(
        //                         crossAxisAlignment: CrossAxisAlignment.start,
        //                         children: [
        //                           Text(
        //                             'Address ${controller.shopdetails.value.phy_address ?? "Address"}',
        //                             style: const TextStyle(fontSize: 20),
        //                           ),
        //                           const SizedBox(
        //                             height: 20,
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                   ),
        //                   Padding(
        //                     padding: const EdgeInsets.only(bottom: 20),
        //                     child: Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceAround,
        //                       children: [
        //                         AnimatedSubmitButton(
        //                             width: 90,
        //                             buttonText: 'Cancel',
        //                             onPressed: () {
        //                               // controller.createProduct();
        //                               Get.back();
        //                             }),
        //                         AnimatedSubmitButton(
        //                             width: 90,
        //                             buttonText: 'Confirm',
        //                             onPressed: () {
        //                               // controller.createProduct();
        //                               Get.back();
        //                             }),
        //                       ],
        //                     ),
        //                   )
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ));
        //   },
        //   height: 50,
        //   minWidth: 120,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(8.0),
        //     side: const BorderSide(
        //       color: Colors.green,
        //     ),
        //   ),
        //   child: Row(
        //     children: [
        //       const Icon(
        //         IconlyLight.edit_square,
        //         size: 14,
        //         color: Colors.green,
        //       ),
        //       const SizedBox(
        //         width: 10,
        //       ),
        //       Text(
        //         'Edit Shop',
        //         textScaleFactor: Get.textScaleFactor,
        //         style: DefaultTextStyle.of(screen.context).style.copyWith(
        //               color: Colors.green,
        //               fontSize: 14,
        //             ),
        //       ),
        //     ],
        //   ),
        // ),
        // const SizedBox(
        //   width: 10,
        // ),
        // MaterialButton(
        //   onPressed: () {},
        //   height: 50,
        //   minWidth: 120,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(8.0),
        //     side: const BorderSide(
        //       color: Colors.red,
        //     ),
        //   ),
        //   child: Row(
        //     children: [
        //       const Icon(
        //         IconlyLight.delete,
        //         size: 14,
        //         color: Colors.red,
        //       ),
        //       const SizedBox(
        //         width: 10,
        //       ),
        //       Text(
        //         'Delete Shop',
        //         textScaleFactor: Get.textScaleFactor,
        //         style: DefaultTextStyle.of(screen.context).style.copyWith(
        //               color: Colors.red,
        //               fontSize: 14,
        //             ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
