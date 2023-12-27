import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../widgets/components/animated_submit_button.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../../home/views/home_view.dart';

class MasterHeader extends GetResponsiveView {
  final String title;
  final RxBool isOpen;
  final String subTitle;
  final int totalCount;
  MasterHeader({
    Key? key,
    required this.title,
    required this.columnlist,
    required this.isOpen,
    required this.subTitle,
    required this.totalCount,
  }) : super(key: key);
  List<String> columnlist = [];
  @override
  Widget build(BuildContext context) {
    screen.context = context;
    Get.log(screen.width.toString());

    return Obx(() => PaddingWrapper(
          isSliverItem: true,
          horizontalPadding: screen.isDesktop ? 50 : 20,
          topPadding: 20,
          bottomPadding: 10,
          child: SliverToBoxAdapter(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RichText(
                      textScaleFactor: Get.textScaleFactor,
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: title,
                            style: DefaultTextStyle.of(screen.context)
                                .style
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  letterSpacing: 0.4,
                                ),
                          ),
                          const TextSpan(
                            text: '\n',
                          ),
                          TextSpan(
                            text: '$totalCount $subTitle',
                            style: DefaultTextStyle.of(screen.context)
                                .style
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.4,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Visibility(
                      visible: isOpen.value,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              isOpen.value = !isOpen.value;
                            },
                            height: 50,
                            minWidth: 120,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                color: Theme.of(screen.context).disabledColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  IconlyLight.filter,
                                  size: 14,
                                  color: Theme.of(screen.context).disabledColor,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Filter',
                                  textScaleFactor: Get.textScaleFactor,
                                  style: DefaultTextStyle.of(screen.context)
                                      .style
                                      .copyWith(
                                        color: Theme.of(screen.context)
                                            .disabledColor,
                                        fontSize: 14,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              // dropdownWidth: 150,
                              customButton: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color:
                                        Theme.of(screen.context).disabledColor,
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
                                        'Green Deal',
                                        textScaleFactor: Get.textScaleFactor,
                                        style:
                                            DefaultTextStyle.of(screen.context)
                                                .style
                                                .copyWith(
                                                  color:
                                                      Theme.of(screen.context)
                                                          .disabledColor,
                                                  fontSize: 14,
                                                ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Icon(
                                        IconlyLight.arrow_down_2,
                                        size: 14,
                                        color: Theme.of(screen.context)
                                            .disabledColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              items: <String>['Green Deal', 'Hot Deal']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                print(value);
                                if (value == 'Green Deal') {
                                  //  controller.isGreenDeal.value = true;
                                } else {
                                  //  controller.isGreenDeal.value = false;
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          // MaterialButton(
                          //   onPressed: () {
                          //     controller.CreatingNewProduct.toggle();
                          //   },
                          //   height: 50,
                          //   minWidth: 120,
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(8.0),
                          //   ),
                          //   color: Theme.of(context).primaryColor,
                          //   child: Text(
                          //     'Add new product'.tr,
                          //     textScaleFactor: Get.textScaleFactor,
                          //     style: DefaultTextStyle.of(screen.context).style.copyWith(
                          //           color: AppColors.white,
                          //           fontSize: 14,
                          //         ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: !isOpen.value,
                  child: screen.width > 1370
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                isOpen.value = !isOpen.value;
                              },
                              child: Text(
                                'Search',
                                style: DefaultTextStyle.of(screen.context)
                                    .style
                                    .copyWith(
                                      color: Theme.of(screen.context)
                                          .disabledColor,
                                      fontSize: 14,
                                    ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 300,
                              height: 50,
                              child: const TextField(
                                textAlign: TextAlign.left,
                                decoration: InputDecoration(
                                    hintText: 'Search',
                                    suffixIcon: Icon(Icons.search)),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            // InkWell(
                            //   onTap: () {
                            //     Get.defaultDialog(
                            //       title: 'Choose Date',
                            //       content: Container(
                            //         width: Get.width * 0.15,
                            //         height: Get.height * 0.3,
                            //         child: SfDateRangePicker(
                            //           minDate: startDate,
                            //           maxDate: endDate,
                            //           showActionButtons: false,
                            //           showTodayButton: false,
                            //           enablePastDates: true,
                            //           view: DateRangePickerView.month,
                            //           viewSpacing: 5,
                            //           showNavigationArrow: true,
                            //           todayHighlightColor: Theme.of(screen.context).primaryColor,
                            //           selectionColor: Theme.of(screen.context).primaryColor,
                            //           // backgroundColor: DarkChatTheme().backgroundColor,
                            //           onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                            //             print(args.value);
                            //           },
                            //         ),
                            //       ),
                            //     );
                            //   },
                            //   child: Container(
                            //     width: 200,
                            //     height: 50,
                            //     child: Padding(
                            //       padding: const EdgeInsets.only(left: 10),
                            //       child: Row(children: [
                            //         Icon(Icons.watch_later_outlined),
                            //         SizedBox(
                            //           width: 10,
                            //         ),
                            //         Text('05/06/2022'),
                            //       ]),
                            //     ),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(8.0),
                            //       border: Border.all(
                            //         color: Colors.white,
                            //       ),
                            //     ),
                            //   ),
                            // ),

                            DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                // dropdownWidth: 180,
                                customButton: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: Theme.of(screen.context)
                                          .disabledColor,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          IconlyLight.calendar,
                                          size: 14,
                                          color: Theme.of(screen.context)
                                              .disabledColor,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          columnlist[0],
                                          textScaleFactor: Get.textScaleFactor,
                                          style: DefaultTextStyle.of(
                                                  screen.context)
                                              .style
                                              .copyWith(
                                                color: Theme.of(screen.context)
                                                    .disabledColor,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          IconlyLight.arrow_down_2,
                                          size: 14,
                                          color: Theme.of(screen.context)
                                              .disabledColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                items: columnlist.map((String value) {
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
                            // DropdownButtonHideUnderline(
                            //   child: DropdownButton2(
                            //     dropdownWidth: 180,
                            //     customButton: DecoratedBox(
                            //       decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(8.0),
                            //         border: Border.all(
                            //           color: Theme.of(screen.context).disabledColor,
                            //         ),
                            //       ),
                            //       child: Padding(
                            //         padding: const EdgeInsets.symmetric(
                            //           horizontal: 20,
                            //           vertical: 10,
                            //         ),
                            //         child: Row(
                            //           children: [
                            //             Icon(
                            //               IconlyLight.calendar,
                            //               size: 14,
                            //               color: Theme.of(screen.context).disabledColor,
                            //             ),
                            //             const SizedBox(
                            //               width: 10,
                            //             ),
                            //             Text(
                            //               columnlist[2],
                            //               textScaleFactor: Get.textScaleFactor,
                            //               style: DefaultTextStyle.of(screen.context).style.copyWith(
                            //                     color: Theme.of(screen.context).disabledColor,
                            //                     fontSize: 14,
                            //                   ),
                            //             ),
                            //             const SizedBox(
                            //               width: 10,
                            //             ),
                            //             Icon(
                            //               IconlyLight.arrow_down_2,
                            //               size: 14,
                            //               color: Theme.of(screen.context).disabledColor,
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //     items: columnlist.map((String value) {
                            //       return DropdownMenuItem<String>(
                            //         value: value,
                            //         child: Text(value),
                            //       );
                            //     }).toList(),
                            //     onChanged: (String? value) {
                            //       print(value);
                            //     },
                            //   ),
                            // ),
                            const SizedBox(
                              width: 10,
                            ),
                            AnimatedSubmitButton(
                                width: 120,
                                buttonText: 'Search',
                                onPressed: () async {}),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        )
                      : screen.width > 1230
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Search',
                                          style: DefaultTextStyle.of(
                                                  screen.context)
                                              .style
                                              .copyWith(
                                                color: Theme.of(screen.context)
                                                    .disabledColor,
                                                fontSize: 14,
                                              ),
                                        ),
                                        Container(
                                          width: Get.size.width * 0.32,
                                          height: 50,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Row(children: const [
                                              Icon(Icons.search),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text('Search'),
                                            ]),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.defaultDialog(
                                          title: 'Choose Date',
                                          content: Container(
                                            width: Get.width * 0.35,
                                            height: Get.height * 0.3,
                                            child: SfDateRangePicker(
                                              minDate: startDate,
                                              maxDate: endDate,
                                              showActionButtons: false,
                                              showTodayButton: false,
                                              enablePastDates: true,
                                              view: DateRangePickerView.month,
                                              viewSpacing: 5,
                                              showNavigationArrow: true,
                                              todayHighlightColor:
                                                  Theme.of(screen.context)
                                                      .primaryColor,
                                              selectionColor:
                                                  Theme.of(screen.context)
                                                      .primaryColor,
                                              // backgroundColor: DarkChatTheme().backgroundColor,
                                              onSelectionChanged:
                                                  (DateRangePickerSelectionChangedArgs
                                                      args) {
                                                print(args.value);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: Get.size.width * 0.32,
                                        height: 50,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Row(children: [
                                            const Icon(
                                                Icons.watch_later_outlined),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Text('05/06/2022'),
                                          ]),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: Get.size.width * 0.32,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton2(
                                            // dropdownWidth: 120,
                                            customButton: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color:
                                                      Theme.of(screen.context)
                                                          .disabledColor,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 10,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      IconlyLight.calendar,
                                                      size: 14,
                                                      color: Theme.of(
                                                              screen.context)
                                                          .disabledColor,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      columnlist[0],
                                                      textScaleFactor:
                                                          Get.textScaleFactor,
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  screen
                                                                      .context)
                                                              .style
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        screen
                                                                            .context)
                                                                    .disabledColor,
                                                                fontSize: 14,
                                                              ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Icon(
                                                      IconlyLight.arrow_down_2,
                                                      size: 14,
                                                      color: Theme.of(
                                                              screen.context)
                                                          .disabledColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            items:
                                                columnlist.map((String value) {
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
                                      ),
                                      SizedBox(
                                        width: Get.size.width * 0.32,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton2(
                                            // dropdownWidth: 120,
                                            customButton: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color:
                                                      Theme.of(screen.context)
                                                          .disabledColor,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 10,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      IconlyLight.calendar,
                                                      size: 14,
                                                      color: Theme.of(
                                                              screen.context)
                                                          .disabledColor,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      columnlist[2],
                                                      textScaleFactor:
                                                          Get.textScaleFactor,
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  screen
                                                                      .context)
                                                              .style
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        screen
                                                                            .context)
                                                                    .disabledColor,
                                                                fontSize: 14,
                                                              ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Icon(
                                                      IconlyLight.arrow_down_2,
                                                      size: 14,
                                                      color: Theme.of(
                                                              screen.context)
                                                          .disabledColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            items:
                                                columnlist.map((String value) {
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
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSubmitButton(
                                    width: Get.size.width * 0.325,
                                    buttonText: 'Search',
                                    onPressed: () async {}),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Search',
                                          style: DefaultTextStyle.of(
                                                  screen.context)
                                              .style
                                              .copyWith(
                                                color: Theme.of(screen.context)
                                                    .disabledColor,
                                                fontSize: 14,
                                              ),
                                        ),
                                        Container(
                                          width: Get.size.width * 0.3,
                                          height: 50,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Row(children: const [
                                              Icon(Icons.search),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text('Search'),
                                            ]),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.defaultDialog(
                                          title: 'Choose Date',
                                          content: Container(
                                            width: Get.width * 0.35,
                                            height: Get.height * 0.3,
                                            child: SfDateRangePicker(
                                              minDate: startDate,
                                              maxDate: endDate,
                                              showActionButtons: false,
                                              showTodayButton: false,
                                              enablePastDates: true,
                                              view: DateRangePickerView.month,
                                              viewSpacing: 5,
                                              showNavigationArrow: true,
                                              todayHighlightColor:
                                                  Theme.of(screen.context)
                                                      .primaryColor,
                                              selectionColor:
                                                  Theme.of(screen.context)
                                                      .primaryColor,
                                              // backgroundColor: DarkChatTheme().backgroundColor,
                                              onSelectionChanged:
                                                  (DateRangePickerSelectionChangedArgs
                                                      args) {
                                                print(args.value);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: Get.size.width * 0.3,
                                        height: 50,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Row(children: [
                                            const Icon(
                                                Icons.watch_later_outlined),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Text('05/06/2022'),
                                          ]),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: Get.size.width * 0.3,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton2(
                                            // dropdownWidth: 120,
                                            customButton: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color:
                                                      Theme.of(screen.context)
                                                          .disabledColor,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 10,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      IconlyLight.calendar,
                                                      size: 14,
                                                      color: Theme.of(
                                                              screen.context)
                                                          .disabledColor,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      columnlist[0],
                                                      textScaleFactor:
                                                          Get.textScaleFactor,
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  screen
                                                                      .context)
                                                              .style
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        screen
                                                                            .context)
                                                                    .disabledColor,
                                                                fontSize: 14,
                                                              ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Icon(
                                                      IconlyLight.arrow_down_2,
                                                      size: 14,
                                                      color: Theme.of(
                                                              screen.context)
                                                          .disabledColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            items:
                                                columnlist.map((String value) {
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
                                      ),
                                      SizedBox(
                                        width: Get.size.width * 0.3,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton2(
                                            // dropdownWidth: 120,
                                            customButton: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color:
                                                      Theme.of(screen.context)
                                                          .disabledColor,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 10,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      IconlyLight.calendar,
                                                      size: 14,
                                                      color: Theme.of(
                                                              screen.context)
                                                          .disabledColor,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      columnlist[2],
                                                      textScaleFactor:
                                                          Get.textScaleFactor,
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  screen
                                                                      .context)
                                                              .style
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        screen
                                                                            .context)
                                                                    .disabledColor,
                                                                fontSize: 14,
                                                              ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Icon(
                                                      IconlyLight.arrow_down_2,
                                                      size: 14,
                                                      color: Theme.of(
                                                              screen.context)
                                                          .disabledColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            items:
                                                columnlist.map((String value) {
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
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSubmitButton(
                                    width: Get.size.width * 0.33,
                                    buttonText: 'Search',
                                    onPressed: () async {}),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ));
  }
}
