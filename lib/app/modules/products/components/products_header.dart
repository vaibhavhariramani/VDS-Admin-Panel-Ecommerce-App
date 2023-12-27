import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../widgets/utils/padding_wrapper.dart';

class ProductsHeader extends GetResponsiveView {
  final String title;
  final String subTitle;
  final int totalCount;
  final List<Widget> actions;
  ProductsHeader({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.totalCount,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return PaddingWrapper(
      isSliverItem: true,
      horizontalPadding: screen.isDesktop ? 50 : 20,
      topPadding: 20,
      bottomPadding: 10,
      child: SliverToBoxAdapter(
        child: Row(
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
                    style: DefaultTextStyle.of(screen.context).style.copyWith(
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
                    style: DefaultTextStyle.of(screen.context).style.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.4,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
