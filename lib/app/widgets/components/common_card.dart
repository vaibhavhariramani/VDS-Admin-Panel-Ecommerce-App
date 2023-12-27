import 'package:flutter/material.dart';

class CommonCard extends StatelessWidget {
  final double elevation;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final Gradient? gradient;

  const CommonCard({
    Key? key,
    this.elevation = 6,
    this.radius = 15.0,
    required this.child,
    this.padding,
    this.color,
    this.margin,
    this.shape,
    this.clipBehavior,
    this.onTap,
    this.height,
    this.width,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildChild() {
      return AnimatedContainer(
        height: height,
        width: width,
        duration: kThemeAnimationDuration,
        decoration: BoxDecoration(
          color: color,
          gradient: gradient,
        ),
        child: padding == null || padding == EdgeInsets.zero
            ? child
            : Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
      );
    }

    return Card(
      color: gradient != null ? Colors.transparent : color,
      margin: margin ?? EdgeInsets.zero,
      elevation: elevation,
      shape: shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      clipBehavior: clipBehavior ?? Clip.hardEdge,
      child: onTap == null
          ? _buildChild()
          : InkWell(
              onTap: onTap,
              child: _buildChild(),
            ),
    );
  }
}
