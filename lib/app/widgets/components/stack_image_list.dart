// import 'package:flutter/material.dart';
// import 'package:image_stack/image_stack.dart';

// class StackedImageList extends StatelessWidget {
//   final List<String> images;
//   final int imageCount;
//   final bool showTotalCount;
//   final double imageRadius;

//   const StackedImageList({
//     Key? key,
//     required this.images,
//     required this.imageCount,
//     this.showTotalCount = true,
//     this.imageRadius = 50,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ImageStack(
//       imageList: images,
//       totalCount: images.length,
//       imageRadius: imageRadius,
//       // showTotalCount: screen.width <= 800
//       //     ? (screen.isPhone || screen.context.isSmallTablet) &&
//       //         !screen.context.isLargeTablet
//       //     : screen.width <= 995
//       //         ? false
//       //         : screen.width <= 1460
//       //             ? screen.width <= 1150
//       //             : screen.width >= 1400
//       //                 ? screen.width <= 1469
//       //                     ? false
//       //                     : screen.context.isLargeTablet
//       //                 : screen.context.isLargeTablet,
//       // imageCount: (screen.isPhone || screen.context.isSmallTablet) &&
//       //         !screen.context.isLargeTablet
//       //     ? 4
//       //     : screen.width <= 800
//       //         ? 1
//       //         : screen.width <= 900
//       //             ? 2
//       //             : screen.width <= 1150
//       //                 ? 3
//       //                 : screen.width <= 1460
//       //                     ? 3
//       //                     : 4,
//       showTotalCount: showTotalCount,
//       imageCount: imageCount,
//       imageBorderWidth: 1,
//       imageBorderColor: Theme.of(context).disabledColor,
//       extraCountBorderColor: Theme.of(context).disabledColor,
//     );
//   }
// }
