import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import 'package:get/get.dart';

import '../../../widgets/components/header.dart';
import '../../deletion_status/controllers/deletion_status_controller.dart';
import '../../deletion_status/views/deletion_status_view.dart';
import '../../shop_listing/controllers/shop_listing_controller.dart';
import '../../shop_listing/views/header_invite.dart';
import '../../shop_listing/views/shop_list_for_super_admin.dart';
import '../controllers/merchants_controller.dart';
import 'components/table_datasrc_merchant.dart';
import 'invite_merchant_view.dart';

// class MerchantsView extends GetView<MerchantsController> {
//   const MerchantsView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('MerchantsView'),
//         centerTitle: true,
//       ),
//       body: const Center(
//         child: Text(
//           'MerchantsView is working',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }
DeletionStatusController deletionStatusController2 =
    Get.put(DeletionStatusController());

class MerchantsView extends GetResponsiveView<MerchantsController> {
  MerchantsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ShopListingController());
    screen.context = context;
    return Obx(
      () => FlutterDashboardListView(
        slivers: [
          SliverVisibility(
            visible: deletionStatusController2.isVisible.value,
            sliver: SliverToBoxAdapter(
              child: DeletionStatusView(),
            ),
          ),
          SliverVisibility(
            visible: controller.isInviting.isFalse &&
                controller.shopGridView.isFalse &&
                !deletionStatusController2.isVisible.value,
            sliver: UsersHeader(
              title: 'Merchants',
              onCreateNew: () {
                controller.isInviting.toggle();
                print("Create");
              },
            ),
          ),
          SliverVisibility(
            visible: controller.isInviting.isFalse &&
                controller.shopGridView.isFalse &&
                !deletionStatusController2.isVisible.value,
            sliver: SliverToBoxAdapter(
              // hasScrollBody: false,
              child: controller.merchantsData.isNotEmpty
                  ? Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2, top: 12),
                        child: PaginatedDataTable(
                          showCheckboxColumn: false,
                          rowsPerPage: controller.merchantsData.isEmpty
                              ? 1
                              : controller.merchantsData.length < 10
                                  ? controller.merchantsData.length
                                  : 10,
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Country')),
                            DataColumn(label: Text('contact')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('ACTIONS')),
                          ],
                          columnSpacing: 20,
                          source: DataSourceMerchants(
                              context, controller.merchantsData),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          SliverVisibility(
            visible: controller.isInviting.isTrue &&
                controller.shopGridView.isFalse &&
                !deletionStatusController2.isVisible.value,
            sliver: InviteHeader(
              title: 'Invite Merchants',
              onBackPressed: () {
                controller.isInviting.toggle();
              },
            ),
          ),
          SliverVisibility(
            visible: controller.isInviting.isTrue &&
                controller.shopGridView.isFalse &&
                !deletionStatusController2.isVisible.value,
            sliver: SliverToBoxAdapter(
              child: AddMerchantView(),
            ),
          ),
          SliverVisibility(
            visible: controller.shopGridView.isTrue &&
                controller.isInviting.isFalse &&
                !deletionStatusController2.isVisible.value,
            sliver: SliverToBoxAdapter(
              child: ShopListingForSuperadmin(),
            ),
          ),
        ],
      ),
    );
  }
}
