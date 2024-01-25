import 'package:cached_network_image/cached_network_image.dart';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../../../models/Product.dart';
import '../../../../themes/app_theme.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../../../widgets/components/common_card.dart';
import '../master_list/controllers/master_list_controller.dart';
import 'product_edit_dialog.dart';
import 'product_schedule_dialog.dart';

class MasterCard extends GetResponsiveView<MasterListController> {
  final bool isMasterListItem;
  final bool isScheduledListItem;
  final bool isPublishedListItem;
  final Product productItem;
  // final VoidCallback? onSchedulePressed;
  // final VoidCallback? onPublishPressed;
  // final VoidCallback? onCancleressed;

  MasterCard({
    Key? key,
    this.isMasterListItem = false,
    this.isScheduledListItem = false,
    this.isPublishedListItem = false,
    // this.onSchedulePressed,
    // this.onPublishPressed,
    // this.onCancleressed,
    required this.productItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;

    return CommonCard(
      height: screen.isPhone ? 260 : 320,
      width: 420,
      radius: 10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: CachedNetworkImage(
                    imageUrl: productItem.img_token ?? "",
                    progressIndicatorBuilder: (context, url, progress) =>
                        Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).indicatorColor,
                      ),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: _buildEditDelButton(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 12,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${productItem.name}'.capitalize!,
                      textScaleFactor: Get.textScaleFactor,
                      style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: 14,
                            color: Theme.of(context).disabledColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            // '\$${productItem.price} ;',
                            '${productItem.currency_type} ${productItem.price}',
                            textScaleFactor: Get.textScaleFactor,
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context).disabledColor,
                                  fontWeight: FontWeight.w200,
                                  decoration: TextDecoration.lineThrough,
                                ),
                          ),
                          Text(
                            // '\$${productItem.price} ;',
                            '${productItem.currency_type} ${productItem.discount}',
                            textScaleFactor: Get.textScaleFactor,
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                RichText(
                  textScaleFactor: Get.textScaleFactor,
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'SKU: ',
                        style: DefaultTextStyle.of(context).style.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      TextSpan(
                        text: '${productItem.barcode}',
                        style: DefaultTextStyle.of(context).style.copyWith(
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  textScaleFactor: Get.textScaleFactor,
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Status: ',
                        style: DefaultTextStyle.of(context).style.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      TextSpan(
                        text: productItem.is_published.toString() == "true"
                            ? 'Published'
                            : 'Unpublished',
                        style: DefaultTextStyle.of(context).style.copyWith(
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: RichText(
                //     textScaleFactor: Get.textScaleFactor,
                //     textAlign: TextAlign.left,
                //     text: TextSpan(
                //       children: [
                //         TextSpan(
                //           text: EnumToString.convertToString(
                //               productItem.deal_type),
                //           style: productItem.deal_type?.name == "GREENDEALS"
                //               ? DefaultTextStyle.of(context).style.copyWith(
                //                   fontSize: 12,
                //                   color: Colors.green,
                //                   fontWeight: FontWeight.bold)
                //               : DefaultTextStyle.of(context).style.copyWith(
                //                   fontSize: 12,
                //                   color: Colors.red[300],
                //                   fontWeight: FontWeight.bold),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          if (isMasterListItem) _buildMasterProductsButton(context),
          if (isPublishedListItem)
            _buildCancelButton(
              onPressed: () {},
            ),
          if (isScheduledListItem)
            _buildCancelButton(
              onPressed: () {},
            ),
          const SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }

  Widget _buildEditDelButton() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
              onTap: () async {
                await Get.dialog(
                  AlertDialog(
                    content: SizedBox(
                      width: Get.width * 0.4,
                      height: Get.height * 0.5,
                      child: ProductEditor(ProductDetails: productItem),
                    ),
                  ),
                );
                Get.back();
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: Icon(IconlyLight.edit_square, color: Colors.white)),
              )),
          InkWell(
            onTap: () async {
              await Get.dialog(
                AlertDialog(
                  content: SizedBox(
                    width: Get.width * 0.15,
                    // height: Get.height * 0.2,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Are you sure you want to delete this product?',
                            softWrap: true,
                            textScaleFactor: Get.textScaleFactor,
                            style: Theme.of(screen.context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(screen.context).primaryColor,
                                ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AnimatedSubmitButton(
                                    textColor: Colors.white,
                                    width: 90,
                                    buttonText: 'Cancel',
                                    onPressed: () async {
                                      Get.back();
                                    }),
                                AnimatedSubmitButton(
                                    textColor: Colors.white,
                                    color: Colors.red,
                                    width: 90,
                                    buttonText: 'Delete',
                                    onPressed: () async {
                                      Get.back();
                                      controller.isEditing(true);
                                      await controller
                                          .deleteproduct(productItem.id!);
                                      Get.back();
                                    }),
                              ],
                            ),
                          )
                        ]),
                  ),
                ),
              );
              Get.back();
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: CircleAvatar(
                  backgroundColor: Colors.black38,
                  child: Icon(IconlyLight.delete, color: Colors.white)),
            ),
          ),
        ]);
  }
  // Widget _buildPopUpMenu() {
  //   return PopupMenuButton(
  //     icon: const Icon(
  //       Icons.more_vert_rounded,
  //       color: AppColors.white,
  //       size: 24,
  //     ),
  //     itemBuilder: ((BuildContext context) {
  //       return [
  //         PopupMenuItem(
  //             onTap: () async {
  //               await Get.dialog(
  //                 AlertDialog(
  //                   content: SizedBox(
  //                     width: Get.width * 0.4,
  //                     height: Get.height * 0.5,
  //                     child: ProductEditor(ProductDetails: productItem),
  //                   ),
  //                 ),
  //               );
  //               Get.back();
  //             },
  //             child: Padding(
  //               padding: const EdgeInsets.only(left: 10),
  //               child: Row(
  //                 children: [
  //                   const Icon(
  //                     IconlyLight.editSquare,
  //                   ),
  //                   const SizedBox(
  //                     width: 10,
  //                   ),
  //                   Text(
  //                     'Edit',
  //                     textScaleFactor: Get.textScaleFactor,
  //                     style: DefaultTextStyle.of(context).style,
  //                   ),
  //                 ],
  //               ),
  //             )),
  //         PopupMenuItem(
  //           onTap: () async {
  //             await Get.dialog(
  //               AlertDialog(
  //                 content: SizedBox(
  //                   width: Get.width * 0.3,
  //                   height: Get.height * 0.2,
  //                   child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
  //                     Text(
  //                       'Are you sure you want to delete this product',
  //                       softWrap: true,
  //                       textScaleFactor: Get.textScaleFactor,
  //                       style: Theme.of(screen.context).textTheme.titleLarge?.copyWith(
  //                             color: Theme.of(screen.context).primaryColor,
  //                           ),
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.only(bottom: 20),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                         children: [
  //                           AnimatedSubmitButton(
  //                               textColor: Colors.white,
  //                               width: 90,
  //                               buttonText: 'Cancel',
  //                               onPressed: () {
  //                                 Get.back();
  //                               }),
  //                           AnimatedSubmitButton(
  //                               textColor: Colors.white,
  //                               color: Colors.red,
  //                               width: 90,
  //                               buttonText: 'Delete',
  //                               onPressed: () async {
  //                                 await controller.deleteproduct(productItem.id);
  //                                 Get.back();
  //                               }),
  //                         ],
  //                       ),
  //                     )
  //                   ]),
  //                 ),
  //               ),
  //             );
  //             Get.back();
  //           },
  //           child: Padding(
  //             padding: const EdgeInsets.only(left: 10),
  //             child: Row(
  //               children: [
  //                 const Icon(
  //                   IconlyLight.delete,
  //                 ),
  //                 const SizedBox(
  //                   width: 10,
  //                 ),
  //                 Text(
  //                   'Delete',
  //                   textScaleFactor: Get.textScaleFactor,
  //                   style: DefaultTextStyle.of(context).style,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ];
  //     }),
  //   );
  // }

  Widget _buildCancelButton({required VoidCallback onPressed}) {
    return Padding(
      padding: EdgeInsets.only(
        left: Get.width * 0.005,
        right: Get.width * 0.005,
        top: 10,
        bottom: 5,
      ),
      child: MaterialButton(
        // style: ElevatedButton.styleFrom(
        //   primary: Color(0xFFFFB946),
        // ),
        onPressed: () {
          // Get.defaultDialog(
          //   contentPadding: const EdgeInsets.all(16),
          //   title: "Schedule Product",
          //   confirm: ElevatedButton(
          //     child: const Text('Schedule'),
          //     onPressed: () {
          //       Get.back();
          //     },
          //   ),
          //   content: const DateRangePickerWidget(),
          // );
        },
        color: Theme.of(screen.context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        height: 46,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.clear,
              size: 16,
              color: AppColors.white,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "Cancel",
              textScaleFactor: Get.textScaleFactor,
              style: DefaultTextStyle.of(screen.context).style.copyWith(
                    fontSize:
                        Theme.of(screen.context).textTheme.button?.fontSize,
                    color: AppColors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterProductsButton(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime Avdate =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    DateTime? Exdate = productItem.expires_on;
    return Padding(
        padding: EdgeInsets.only(
          left: Get.width * 0.005,
          right: Get.width * 0.005,
          top: 10,
          bottom: 5,
        ),
        child: Row(
          children: [
            Expanded(
              child: MaterialButton(
                onPressed: () async {
                  await Get.dialog(
                    AlertDialog(
                      content: SizedBox(
                        width: Get.width * 0.4,
                        height: Get.height * 0.5,
                        child: ProductScheduler(ProductDetails: productItem),
                      ),
                    ),
                  );
                  Get.back();
                },
                color: AppColors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                height: 46,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      IconlyLight.time_circle,
                      size: 16,
                      color: AppColors.white,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Text(
                      "Schedule",
                      textScaleFactor: Get.textScaleFactor,
                      style: DefaultTextStyle.of(screen.context).style.copyWith(
                            fontSize: Theme.of(screen.context)
                                .textTheme
                                .button
                                ?.fontSize,
                            color: AppColors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: MaterialButton(
                onPressed: productItem.is_published?.toString() == "true"
                    ? null
                    : () {
                        Get.defaultDialog(
                          contentPadding: const EdgeInsets.all(8),
                          title: "Publish Product",
                          // onCancel: () {
                          //   Get.back();
                          // },
                          confirm: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            height: 46,
                            color: Theme.of(context).primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  IconlyBold.arrow_up,
                                  size: 16,
                                  color: AppColors.white,
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  "Publish Now",
                                  textScaleFactor: Get.textScaleFactor,
                                  style: DefaultTextStyle.of(screen.context)
                                      .style
                                      .copyWith(
                                        fontSize: Theme.of(screen.context)
                                            .textTheme
                                            .button
                                            ?.fontSize,
                                        color: AppColors.white,
                                      ),
                                ),
                              ],
                            ),
                            onPressed: () async {
                              await controller.publishNow(productItem.id!);
                              Get.back();
                            },
                          ),

                          content: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox.square(
                                  dimension: 100,
                                  child: CachedNetworkImage(
                                    imageUrl: productItem.img_token ?? "",
                                    progressIndicatorBuilder:
                                        (context, url, progress) => Center(
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).indicatorColor,
                                      ),
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  "Product going live on ${DateTime.now().toString().substring(0, 10)}",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                disabledColor: AppColors.grey,
                disabledTextColor: AppColors.grey2,
                disabledElevation: 0,
                color: Theme.of(screen.context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                height: 46,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      IconlyBold.arrow_up,
                      size: 16,
                      color: AppColors.white,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Text(
                      "Publish",
                      textScaleFactor: Get.textScaleFactor,
                      style: DefaultTextStyle.of(screen.context).style.copyWith(
                            fontSize: Theme.of(screen.context)
                                .textTheme
                                .button
                                ?.fontSize,
                            color: AppColors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
