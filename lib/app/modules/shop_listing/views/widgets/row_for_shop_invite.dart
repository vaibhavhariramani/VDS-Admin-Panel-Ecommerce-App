import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:iconly/iconly.dart';

import '../../../../../models/InvitedUser.dart';

class ShopSource extends DataTableSource {
  ShopSource(this.context, this.rows); //snapshot.data

  final BuildContext context;
  List<InvitedUser> rows;
  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= rows.length) return null;
    final InvitedUser row = rows[index];
    print("invited User Name: ${row.fullname}");
    return DataRow.byIndex(
      selected: false,
      index: index,
      onSelectChanged: (value) {},
      cells: [
        DataCell(Text("${row.fullname}")),
        DataCell(Text("${row.email}")),
        DataCell(Text("${row.status?.name}")),
        // DataCell(
        //   Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       CircleAvatar(
        //         radius: 20,
        //         backgroundImage: Image.network(
        //           row.img_token![0],
        //           fit: BoxFit.cover,
        //         ).image,
        //       ),
        //       const SizedBox(
        //         width: 20,
        //       ),
        //       RichText(
        //         textScaleFactor: Get.textScaleFactor,
        //         maxLines: 2,
        //         text: TextSpan(
        //           children: [
        //             TextSpan(
        //               text: '${row.fullname}',
        //               style: DefaultTextStyle.of(context).style.copyWith(
        //                     fontSize: 14,
        //                   ),
        //             ),
        //             const TextSpan(
        //               text: '\n',
        //             ),
        //             TextSpan(
        //               text: row.usersID,
        //               style: DefaultTextStyle.of(context).style.copyWith(
        //                     fontSize: 12,
        //                   ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // DataCell(
        //   Container(
        //     decoration: BoxDecoration(
        //         color: row.status == 'Active'
        //             ? Colors.green.withOpacity(0.4)
        //             : row.saved_location == 'Pending'
        //                 ? Color(0xFFFF9F43).withOpacity(0.12)
        //                 : Color(0xFF6C757D).withOpacity(0.3),
        //         borderRadius: BorderRadius.circular(4)),
        //     padding: const EdgeInsets.all(4),
        //     child: Text(
        //       '${row.status}',
        //       style: TextStyle(
        //           color: row.saved_location == 'Active'
        //               ? Colors.green
        //               : row.saved_location == 'Pending'
        //                   ? const Color(0xFFFF9F43)
        //                   : const Color(0xFF82868B),
        //           fontWeight: FontWeight.bold),
        //     ),
        //   ),
        // ),
        DataCell(Text(row.id)),
        // DataCell(
        //   Row(
        //     children: [
        //       IconButton(onPressed: () {}, icon: const Icon(IconlyLight.show)),
        //       IconButton(
        //           onPressed: () {}, icon: const Icon(IconlyLight.edit_square)),
        //       IconButton(onPressed: () {}, icon: const Icon(Icons.delete))
        //     ],
        //   ),
        // ),
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
