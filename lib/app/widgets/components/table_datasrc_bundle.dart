import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../models/Product.dart';
import '../../../services/data_service.dart';
import '../../modules/products/products_listing/controllers/products_listing_controller.dart';

class DSforBundleProduct extends DataTableSource {
  ProductsListingController controller = Get.put(ProductsListingController());

  DSforBundleProduct(this.rows); //snapshot.data

  RxList<Product> rows;
  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= rows.length) return null;
    final row = rows[index];

    return DataRow.byIndex(
      selected: false,
      index: index,
      onSelectChanged: (value) {},
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CircleAvatar(
              //   radius: 20,
              //   backgroundImage: CachedNetworkImageProvider(
              //     row[0],
              //     // fit: BoxFit.cover,
              //   ),
              // ),
              AnimatedContainer(
                  duration: kThemeChangeDuration,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    maxHeight: math.pi * 25,
                    minHeight: math.pi * 25,
                    minWidth: math.pi * 25,
                    maxWidth: math.pi * 25,
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: CachedNetworkImage(
                    imageUrl: row.img_token!,
                    fit: BoxFit.fill,
                    progressIndicatorBuilder: (_, __, ___) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )),
              const SizedBox(
                width: 20,
              ),
              RichText(
                textScaleFactor: Get.textScaleFactor,
                maxLines: 2,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: row.name.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(' ${row.sku.toString()}')),
        DataCell(Text(' ${row.price}')),
        DataCell(Text(' ${row.discount}')),
        DataCell(Text(DataService.to.DateTimeToString(date: row.expires_on!))),
        DataCell(
            Text(DataService.to.DateTimeToString(date: row.available_from!))),
        DataCell(Row(
          children: [
            // IconButton(
            //     onPressed: () async {
            //       await Get.dialog(
            //         AlertDialog(
            //           content: SizedBox(
            //             width: Get.width * 0.4,
            //             height: Get.height * 0.5,
            //             child: BulkProductEditor(
            //                 ProductDetails: row, index: index),
            //           ),
            //         ),
            //       );
            //       Get.back();
            //     },
            //     icon: const Icon(IconlyLight.editSquare)),
            IconButton(
                onPressed: () {
                  controller.deleteProduct(index);
                },
                icon: const Icon(Icons.delete))
          ],
        )),
      ],
    );
  }

  @override
  int get rowCount => rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
