import 'package:cached_network_image/cached_network_image.dart';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../../../models/Product.dart';
import '../../../../themes/app_theme.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../../../widgets/components/common_card.dart';
import '../scheduled_products/controllers/scheduled_products_controller.dart';
import 'product_edit_dialog.dart';

class ProductCard extends GetResponsiveView<ScheduledProductsController> {
  final bool isMasterListItem;
  final bool isScheduledListItem;
  final bool isPublishedListItem;
  final Product productItem;
  // final VoidCallback? onSchedulePressed;
  // final VoidCallback? onPublishPressed;
  // final VoidCallback? onCancleressed;
  ScheduledProductsController get controller =>
      Get.find<ScheduledProductsController>();
  ProductCard({
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
                    imageUrl: productItem.img_token!,
                    progressIndicatorBuilder: (context, url, progress) =>
                        Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).indicatorColor,
                      ),
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: _buildPopUpMenu(),
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
                      '${productItem.name}',
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
                const Divider(
                  color: Colors.transparent,
                  height: 10,
                ),
                RichText(
                  textScaleFactor: Get.textScaleFactor,
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Available from:  ',
                        style: DefaultTextStyle.of(context).style.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      TextSpan(
                        text: productItem.available_from!
                            .toString()
                            .substring(0, 10),
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
                        text: 'Fresh Untill:  ',
                        style: DefaultTextStyle.of(context).style.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      TextSpan(
                        text:
                            productItem.expires_on!.toString().substring(0, 10),
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
                        text:
                            EnumToString.convertToString(productItem.deal_type),
                        style: DefaultTextStyle.of(context).style.copyWith(
                              fontSize: 12,
                              color: Theme.of(context).disabledColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildScheduleProductsButton()
          // if (isMasterListItem) _buildMasterProductsButton(),
          // if (isPublishedListItem){}
          // _buildCancleButton(
          //   onPressed: () {},
          // ),
          // if (isScheduledListItem){}
          // _buildCancleButton(
          //   onPressed: () {},
          // ),
        ],
      ),
    );
  }

  Widget _buildScheduleProductsButton() {
    DateTime now = DateTime.now();
    DateTime Avdate =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    DateTime? Visibledate = productItem.available_from;
    return Padding(
      padding: EdgeInsets.only(
        left: Get.width * 0.005,
        right: Get.width * 0.005,
        top: 10,
        bottom: 5,
      ),
      child: Avdate.isBefore(Visibledate!)
          ? Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    onPressed: () {
                      Get.defaultDialog(
                        contentPadding: const EdgeInsets.all(16),
                        title: "Publish Product",
                        // onCancel: () {
                        //   Get.back();
                        // },
                        confirm: ElevatedButton(
                          child: const Text('Publish Now'),
                          onPressed: () async {
                            Get.back();
                            await controller.publishNow(
                              productItem.id,
                            );
                          },
                        ),
                        content: Column(
                          children: [
                            SizedBox(
                              height: 75,
                              width: 70,
                              child: CachedNetworkImage(
                                imageUrl: productItem.img_token!,
                                progressIndicatorBuilder:
                                    (context, url, progress) => Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).indicatorColor,
                                  ),
                                ),
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(
                              width: 250,
                              child: Text(
                                  "This product will be available on App from ${productItem.available_from?.toString().substring(0, 10)} to ${DateTime.now().toString().substring(0, 10)}"),
                            ),
                          ],
                        ),
                      );
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
                  ),
                ),
              ],
            )
          : const SizedBox(
              height: 5,
            ),
    );
  }

  Widget _buildPopUpMenu() {
    return PopupMenuButton(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.white,
        size: 24,
      ),
      itemBuilder: ((BuildContext context) {
        return [
          PopupMenuItem(
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
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  const Icon(
                    IconlyLight.edit_square,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Edit',
                    textScaleFactor: Get.textScaleFactor,
                    style: DefaultTextStyle.of(context).style,
                  ),
                ],
              ),
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              await Get.dialog(
                AlertDialog(
                  content: SizedBox(
                    width: Get.width * 0.3,
                    height: Get.height * 0.2,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Are you sure you want to unpublish this product',
                            softWrap: true,
                            textScaleFactor: Get.textScaleFactor,
                            style: Theme.of(screen.context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(screen.context).primaryColor,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
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
                                    width: 110,
                                    buttonText: 'Unpublish',
                                    onPressed: () async {
                                      await controller
                                          .unpublishProduct(productItem.id);

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
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const Icon(
                    IconlyLight.delete,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Unpublish',
                    textScaleFactor: Get.textScaleFactor,
                    style: DefaultTextStyle.of(context).style,
                  ),
                ],
              ),
            ),
          ),
        ];
      }),
    );
  }

  Widget _buildCancleButton({required VoidCallback onPressed}) {
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

  Widget _buildMasterProductsButton() {
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
              onPressed: () {},
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
      ),
    );
  }
}
