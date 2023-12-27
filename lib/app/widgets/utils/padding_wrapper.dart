import 'package:flutter/material.dart';

class PaddingWrapper extends StatelessWidget {
  final bool isSliverItem;
  final dynamic child;

  final double? topPadding;
  final double? bottomPadding;
  final double? leftPadding;
  final double? rightPadding;
  final double? horizontalPadding;

  const PaddingWrapper({
    Key? key,
    required this.isSliverItem,
    required this.child,
    this.topPadding = 0.0,
    this.bottomPadding = 0.0,
    this.leftPadding,
    this.rightPadding,
    this.horizontalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSliverItem) {
      return SliverPadding(
        padding: EdgeInsets.only(
          left: leftPadding ?? horizontalPadding ?? 20,
          top: topPadding!,
          right: rightPadding ?? horizontalPadding ?? 20,
          bottom: bottomPadding!,
        ),
        sliver: child,
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(
          left: leftPadding ?? horizontalPadding ?? 20,
          top: topPadding!,
          right: rightPadding ?? horizontalPadding ?? 20,
          bottom: bottomPadding!,
        ),
        child: child,
      );
    }
  }
}
