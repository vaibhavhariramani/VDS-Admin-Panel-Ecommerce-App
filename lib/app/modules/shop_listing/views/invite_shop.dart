import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../services/auth_service.dart';
import '../../../../themes/app_theme.dart';
import '../controllers/shop_listing_controller.dart';
import 'widgets/alertbox_for_invitation.dart';
import 'widgets/row_for_shop_invite.dart';

class AddShopView extends GetResponsiveView<ShopListingController> {
  ShopListingController createController = Get.put(ShopListingController());
  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return Obx(() => FlutterDashboardListView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20,
              ),
              sliver: SliverToBoxAdapter(child: _buildInviteMerchantsBox()),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20,
              ),
              sliver: SliverToBoxAdapter(
                  child: createController.invitedUsers.isNotEmpty &&
                          !createController.isloadinglist.value
                      ? Padding(
                          padding: const EdgeInsets.only(right: 2, top: 12),
                          child: PaginatedDataTable(
                            showCheckboxColumn: false,
                            rowsPerPage: createController.invitedUsers.isEmpty
                                ? 1
                                : createController.invitedUsers.length < 5
                                    ? createController.invitedUsers.length
                                    : 5,
                            columns: const [
                              // DataColumn(label: Text('Icon')),
                              DataColumn(label: Text('User')),
                              DataColumn(label: Text('email')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Invitation ID')),
                              // DataColumn(label: Text('Actions')),
                            ],
                            columnSpacing: 10,
                            source: ShopSource(
                                context, createController.invitedUsers),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator())),
            )
          ],
        ));
  }

  Widget _buildInviteMerchantsBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                    "${createController.addedShops.length} Invites Generated | Available Invites : ${AuthService.to.user.value!.shops_subscription_left ?? 0}")),
                Obx(
                  () => FlutterDashboardListView.grid(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    gridDelegate: screen.isPhone
                        ? FlutterDashboardGridDelegates.columns_2(
                            width: screen.width,
                            length: createController.addedShops.length)
                        : FlutterDashboardGridDelegates.fit(
                            createController.addedShops.length, 4, 1),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    isSliverItem: false,
                    childCount: createController.addedShops.length,
                    listType: FlutterDashboardListType.Grid,
                    buildItem: (BuildContext context, int index) {
                      return Center(
                        child: ListTile(
                          tileColor: const Color(0xff000000).withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          dense: true,
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                            radius: 15,
                          ),
                          title: Text(
                            '${createController.addedShops[index]}',
                            maxLines: 1,
                          ),
                          trailing: CircleAvatar(
                              maxRadius: 15,
                              backgroundColor: AppColors.green,
                              child: IconButton(
                                color: Colors.white,
                                icon: const Icon(Icons.close),
                                padding: EdgeInsets.zero,
                                iconSize: 15,
                                onPressed: () {
                                  createController.removeSHOP2(
                                      createController.addedShops[index]);
                                },
                              )),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 210,
                  child: InkWell(
                    onTap: () {
                      _buildAddMerchantDialog();
                    },
                    child: ListTile(
                      dense: true,
                      tileColor: const Color(0xff000000).withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      leading: const CircleAvatar(
                          maxRadius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.add)),
                      title: const Text("Add Shops"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () async {
            Get.defaultDialog(
              // barrierDismissible: false,
              title: "Sending Invitation",
              content: const CircularProgressIndicator(),
              // cancel: Icon(Icons.close),
            );
            await controller.sendInvittion();
            Get.back();
          },
          child: const Text("Send Invitation"),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(AppColors.green)),
        )
      ],
    );
  }

  _buildAddMerchantDialog() {
    return Get.dialog(
      AlertDialog(
        content: SizedBox(
          width: Get.width * 0.4,
          height: Get.height * 0.5,
          child: InvitationBox(),
        ),
      ),
    );
  }
}
