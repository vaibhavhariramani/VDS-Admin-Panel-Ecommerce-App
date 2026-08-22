// import 'package:badges/badges.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../models/UserType.dart';
import '../../../services/auth_service.dart';

class NotificationButton extends GetResponsiveView {
  NotificationButton({Key? key}) : super(key: key);
  // DeletionStatusController controller = Get.put(DeletionStatusController());
  @override
  Widget build(BuildContext context) {
    screen.context = context;

    return MaterialButton(
      onPressed: () {
        if (screen.isPhone) {
          AuthService.to.loggedUser != UserType.SHOP_ADMIN
              ? controller.isVisible.toggle()
              : null;
          Navigator.pop(context);
        } else {
          AuthService.to.loggedUser != UserType.SHOP_ADMIN
              ? controller.isVisible.toggle()
              : null;
        }
      },
      color: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      disabledColor: Colors.transparent,
      highlightColor: Colors.transparent,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      disabledElevation: 0,
      highlightElevation: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 24,
            color: DefaultTextStyle.of(context).style.color,
          ),
          if (screen.isPhone)
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                Text(
                  'Notifications',
                  textScaleFactor: Get.textScaleFactor,
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
