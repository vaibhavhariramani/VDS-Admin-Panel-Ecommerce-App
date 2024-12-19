import 'package:flutter/material.dart';
// import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import 'common_card.dart';

class BuildCard extends GetResponsiveView {
  final VoidCallback onPressed;
  final String text;
  BuildCard({required this.onPressed, required this.text, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
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
