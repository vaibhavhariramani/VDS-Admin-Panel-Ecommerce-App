import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthCustomDivider extends StatelessWidget {
  final String title;
  const AuthCustomDivider({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Theme.of(context).disabledColor.withOpacity(0),
                Theme.of(context).disabledColor,
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.0),
              stops: const <double>[0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          width: 80.0,
          height: 1.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Get.width * 0.02,
          ),
          child: Text(
            'Or $title With'.tr,
            style: Theme.of(context).textTheme.button?.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  letterSpacing: -0.28,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Theme.of(context).disabledColor,
                Theme.of(context).disabledColor.withOpacity(0),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.0),
              stops: const <double>[0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          width: 100.0,
          height: 1.0,
        ),
      ],
    );
  }
}
