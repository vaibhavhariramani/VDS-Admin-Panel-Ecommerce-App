import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:iconly/iconly.dart';

import '../../../models/UserType.dart';
import '../../../services/auth_service.dart';
import '../../../services/data_service.dart';

class AppBarUserButton extends GetResponsiveView {
  AppBarUserButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;

    final AuthService _authService = AuthService.to;
    // return MaterialButton(
    //   onPressed: () {
    //     if (screen.isPhone) {
    //       Navigator.pop(context);
    //     }
    //   },
    //   color: Colors.transparent,
    //   focusColor: Colors.transparent,
    //   hoverColor: Colors.transparent,
    //   splashColor: Colors.transparent,
    //   disabledColor: Colors.transparent,
    //   highlightColor: Colors.transparent,
    //   elevation: 0,
    //   focusElevation: 0,
    //   hoverElevation: 0,
    //   disabledElevation: 0,
    //   highlightElevation: 0,
    //   child: Row(
    //     children: screen.isPhone
    //         ? [
    //             SizedBox.square(
    //               dimension: 40,
    //               child: Stack(
    //                 fit: StackFit.expand,
    //                 children: [
    //                   Positioned(
    //                     top: 0,
    //                     bottom: 0,
    //                     left: 0,
    //                     right: 0,
    //                     child: CircleAvatar(
    //                       backgroundColor:
    //                           Theme.of(context).scaffoldBackgroundColor,
    //                       foregroundImage: const CachedNetworkImageProvider(
    //                         "https://images.unsplash.com/photo-1458071103673-6a6e4c4a3413?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80",
    //                       ),
    //                       child: Icon(
    //                         IconlyLight.profile,
    //                         color: Theme.of(context).iconTheme.color,
    //                       ),
    //                     ),
    //                   ),
    //                   Positioned(
    //                     bottom: -1,
    //                     right: -1,
    //                     child: Image.asset(
    //                       'assets/online.png',
    //                       scale: 1,
    //                       width: 14,
    //                       height: 14,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             const SizedBox(
    //               width: 15,
    //             ),
    //             RichText(
    //               textAlign: TextAlign.left,
    //               textScaleFactor: Get.textScaleFactor,
    //               text: TextSpan(
    //                 children: [
    //                   TextSpan(
    //                     text: 'John Doe'.capitalize,
    //                     style: DefaultTextStyle.of(context).style.copyWith(
    //                           fontFamily: GoogleFonts.montserrat().fontFamily,
    //                           fontSize: 14,
    //                           fontWeight: FontWeight.w400,
    //                         ),
    //                   ),
    //                   const TextSpan(
    //                     text: '\n',
    //                   ),
    //                   TextSpan(
    //                     text: 'Shop Owner',
    //                     style: DefaultTextStyle.of(context).style.copyWith(
    //                           fontFamily: GoogleFonts.montserrat().fontFamily,
    //                           fontSize: 12,
    //                           fontWeight: FontWeight.w400,
    //                           color: Theme.of(context).disabledColor,
    //                         ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ]
    //         : [
    //             RichText(
    //               textAlign: TextAlign.right,
    //               textScaleFactor: Get.textScaleFactor,
    //               text: TextSpan(
    //                 children: [
    //                   TextSpan(
    //                     text: 'John Doe'.capitalize,
    //                     style: DefaultTextStyle.of(context).style.copyWith(
    //                           fontFamily: GoogleFonts.montserrat().fontFamily,
    //                           fontSize: 14,
    //                           fontWeight: FontWeight.w400,
    //                         ),
    //                   ),
    //                   const TextSpan(
    //                     text: '\n',
    //                   ),
    //                   TextSpan(
    //                     text: 'Shop Owner',
    //                     style: DefaultTextStyle.of(context).style.copyWith(
    //                           fontFamily: GoogleFonts.montserrat().fontFamily,
    //                           fontSize: 12,
    //                           fontWeight: FontWeight.w400,
    //                           color: Theme.of(context).disabledColor,
    //                         ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             const SizedBox(
    //               width: 15,
    //             ),
    //             SizedBox.square(
    //               dimension: 40,
    //               child: Stack(
    //                 fit: StackFit.expand,
    //                 children: [
    //                   Positioned(
    //                     top: 0,
    //                     bottom: 0,
    //                     left: 0,
    //                     right: 0,
    //                     child: CircleAvatar(
    //                       backgroundColor:
    //                           Theme.of(context).scaffoldBackgroundColor,
    //                       foregroundImage: const CachedNetworkImageProvider(
    //                         "https://images.unsplash.com/photo-1458071103673-6a6e4c4a3413?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80",
    //                       ),
    //                       child: Icon(
    //                         IconlyLight.profile,
    //                         color: Theme.of(context).iconTheme.color,
    //                       ),
    //                     ),
    //                   ),
    //                   Positioned(
    //                     bottom: -1,
    //                     right: -1,
    //                     child: Image.asset(
    //                       'assets/online.png',
    //                       scale: 1,
    //                       width: 14,
    //                       height: 14,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             const SizedBox(
    //               width: 15,
    //             ),
    //           ],
    //   ),
    // );
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        // dropdownWidth: 120,
        customButton: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Obx(
            () => Row(
              children: screen.isPhone
                  ? [
                      SizedBox.square(
                        dimension: 40,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                foregroundImage:
                                    const CachedNetworkImageProvider(
                                  "https://images.unsplash.com/photo-1458071103673-6a6e4c4a3413?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80",
                                ),
                                child: Icon(
                                  IconlyLight.profile,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -1,
                              right: -1,
                              child: Image.asset(
                                'assets/online.png',
                                scale: 1,
                                width: 14,
                                height: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      RichText(
                        textAlign: TextAlign.left,
                        textScaleFactor: Get.textScaleFactor,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${_authService.user.value?.fullname}'
                                  .capitalize,
                              style:
                                  DefaultTextStyle.of(context).style.copyWith(
                                        fontFamily:
                                            GoogleFonts.montserrat().fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                            ),
                            const TextSpan(
                              text: '\n',
                            ),
                            TextSpan(
                              text: 'Shop Owner',
                              style:
                                  DefaultTextStyle.of(context).style.copyWith(
                                        fontFamily:
                                            GoogleFonts.montserrat().fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context).disabledColor,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  : [
                      RichText(
                        textAlign: TextAlign.right,
                        textScaleFactor: Get.textScaleFactor,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _authService.user.value?.fullname ??
                                  "".capitalize,
                              style:
                                  DefaultTextStyle.of(context).style.copyWith(
                                        fontFamily:
                                            GoogleFonts.montserrat().fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                            ),
                            const TextSpan(
                              text: '\n',
                            ),
                            TextSpan(
                              text: EnumToString.convertToString(
                                  _authService.user.value?.user_type ??
                                      UserType.ADMIN),
                              // '${_authService.user.value?.user_type ?? ""}',
                              style:
                                  DefaultTextStyle.of(context).style.copyWith(
                                        fontFamily:
                                            GoogleFonts.montserrat().fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context).disabledColor,
                                      ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      SizedBox.square(
                        dimension: 40,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                foregroundImage: CachedNetworkImageProvider(
                                  _authService.user.value?.img_token ??
                                      "https://images.unsplash.com/photo-1458071103673-6a6e4c4a3413?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80",
                                ),
                                child: Icon(
                                  IconlyLight.profile,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -1,
                              right: -1,
                              child: Image.asset(
                                'assets/online.png',
                                scale: 1,
                                width: 14,
                                height: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                    ],
            ),
          ),
        ),
        items: [
          DropdownMenuItem<String>(
            value: "Logout".tr,
            child: Text(
              "Logout".tr,
              textScaleFactor: Get.textScaleFactor,
              style: DefaultTextStyle.of(context).style,
            ),
          ),
        ],
        onChanged: (String? value) async {
          // print(value);
          if ((value ?? '') == "Logout".tr) {
            print('Logout');
            FlutterDashboardController.to.isScreenLoading(true);
            await DataService.to.CreateLogs(action: "User Logged out");
            await AuthService.to.logout();
            FlutterDashboardController.to.isScreenLoading(false);
          }
        },
      ),
    );
  }
}
