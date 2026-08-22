import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/Users.dart';
import '../controllers/billing_controller.dart';

/// Shows every registered customer in a scrollable table. Opened from the
/// Billing page's "Total Users" tile.
class UsersTableDialog extends StatelessWidget {
  const UsersTableDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BillingController controller = Get.find<BillingController>();
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      'All Users (${controller.allUsers.length})',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Obx(() {
                  if (controller.isLoadingAllUsers.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (controller.allUsers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('No users found.')),
                    );
                  }
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Phone')),
                          DataColumn(label: Text('Country')),
                        ],
                        rows: controller.allUsers
                            .map(
                              (Users u) => DataRow(cells: [
                                DataCell(Text(u.fullname ?? '—')),
                                DataCell(Text(u.email ?? '—')),
                                DataCell(Text(u.phn_number ?? '—')),
                                DataCell(Text(u.country ?? '—')),
                              ]),
                            )
                            .toList(),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
