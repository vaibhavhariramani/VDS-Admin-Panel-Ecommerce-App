import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:progress_loading_button/progress_loading_button.dart';

class AnimatedSubmitButton extends StatelessWidget {
  final String buttonText;
  final Future<dynamic> Function()? onPressed;
  final Color? color;
  final Color? textColor;
  final double? radius;
  final double? width;
  const AnimatedSubmitButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.color,
    this.textColor,
    this.radius,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingButton(
        defaultWidget: Text(
          buttonText,
          textScaleFactor: Get.textScaleFactor,
          style: DefaultTextStyle.of(context).style.copyWith(
                color: textColor,
              ),
        ),
        loadingWidget: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
        color: onPressed == null
            ? Theme.of(context).disabledColor
            : color ?? Theme.of(context).primaryColor,
        type: LoadingButtonType.Elevated,
        borderRadius: radius ?? 10,
        height: 46,
        width: width,
        onPressed: onPressed,
      ),
    );
  }
}
