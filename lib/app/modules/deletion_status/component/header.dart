import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../widgets/components/animated_submit_button.dart';
import '../../../widgets/components/export_button.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../../home/views/home_view.dart';

class Header extends GetResponsiveView {
  final String title;
  final RxBool isOpen;
  Header({
    Key? key,
    required this.title,
    required this.columnlist,
    required this.isOpen,
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
                    Text(
                      title,
                      style: DefaultTextStyle.of(screen.context).style.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            letterSpacing: 0.4,
                            color: Theme.of(context).primaryColor,
                          ),
                      textScaleFactor: Get.textScaleFactor,
                      textAlign: TextAlign.left,
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
                          ExportButton(),
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            Container(
                              width: 300,
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(children: const [
                                  Icon(Icons.search),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Search'),
                                ]),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.defaultDialog(
                                  title: 'Choose Date',
                                  content: Container(
                                    width: Get.width * 0.15,
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
                                          Theme.of(screen.context).primaryColor,
                                      selectionColor:
                                          Theme.of(screen.context).primaryColor,
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
                                width: 200,
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(children: [
                                    Icon(Icons.watch_later_outlined),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('05/06/2022'),
                                  ]),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                // dropdownWidth: 120,
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
                            DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                // dropdownWidth: 120,
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
                                          columnlist[2],
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
                            AnimatedSubmitButton(
                                width: 120,
                                buttonText: 'Search',
                                onPressed: () async {}),
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
                                            Icon(Icons.watch_later_outlined),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text('05/06/2022'),
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
                                            Icon(Icons.watch_later_outlined),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text('05/06/2022'),
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
