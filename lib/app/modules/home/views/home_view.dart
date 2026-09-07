import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';

import '../../../../models/UserType.dart';
import '../../../../themes/app_theme.dart';
import '../../../widgets/components/common_card.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../../deletion_status/controllers/deletion_status_controller.dart';
import '../../deletion_status/views/deletion_status_view.dart';
import '../controllers/home_controller.dart';
import 'dashboard_alerts_panel.dart';
import 'widgets/performance_chart_card.dart';
import 'widgets/stat_card.dart';

// These three top-level globals are pre-existing cross-file coupling, not
// introduced here: several unrelated files (billing_view.dart,
// app_pages.dart, deletion_status/component/{header,masterheader}.dart,
// products_listing's greendeal_form.dart) import this file specifically to
// use these as date-picker bounds and a shared controller instance,
// instead of each owning its own. Left in place rather than fixed here -
// untangling it means touching 5+ unrelated files' imports, out of scope
// for a dashboard redesign.
DateTime startDate = DateTime(2000);
DateTime endDate = DateTime(3000);
DeletionStatusController deletionStatusController = Get.put(DeletionStatusController());

class HomeView extends GetResponsiveView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    // GetX already calls onInit() exactly once when the (lazyPut) controller
    // is first resolved - calling it again here ran it on *every* rebuild of
    // this view (any Obx anywhere in the tree firing, window resize, etc.),
    // which re-queried Firestore for user counts/invites on each rebuild.
    // That's what made the dashboard feel like it "takes lots of time to
    // populate": it wasn't one slow load, it was being repeatedly restarted.
    return Obx(() {
      final _RoleDashboardConfig? config = _configFor(controller.userType);
      if (config == null) {
        return const Scaffold(
          body: Center(
            child: Text("You don't have enough permission to view this page"),
          ),
        );
      }
      return _RoleDashboard(controller: controller, config: config, screen: screen);
    });
  }

  _RoleDashboardConfig? _configFor(UserType userType) {
    switch (userType) {
      case UserType.ADMIN:
      case UserType.AFFILIATES:
      case UserType.COUNTRY_HEAD:
        return _RoleDashboardConfig(
          statCards: (HomeController c) => [
            StatCardData(
              count: c.totalCustomerCount,
              title: 'Total Customers',
              color: AppSemanticColors.success,
              backgroundColor: AppSemanticColors.successBg,
              icon: Icons.groups_outlined,
            ),
            StatCardData(
              count: c.activeUserCount.value,
              title: 'Active Customers',
              color: AppSemanticColors.info,
              backgroundColor: AppSemanticColors.infoBg,
              icon: Icons.person_outline,
            ),
            StatCardData(
              count: c.inActiveUserCount.value,
              title: 'Inactive Customers',
              color: AppSemanticColors.neutral,
              backgroundColor: AppSemanticColors.neutralBg,
              icon: Icons.person_off_outlined,
            ),
          ],
          showAlertsPanel: false,
        );
      case UserType.MERCHANT:
        return _RoleDashboardConfig(
          statCards: (HomeController c) => [
            StatCardData(
              count: c.activeUserCount.value,
              title: 'Active Users',
              color: AppSemanticColors.success,
              backgroundColor: AppSemanticColors.successBg,
              icon: Icons.person_outline,
            ),
            StatCardData(
              count: c.inActiveUserCount.value,
              title: 'Inactive Users',
              color: AppSemanticColors.info,
              backgroundColor: AppSemanticColors.infoBg,
              icon: Icons.person_off_outlined,
            ),
            StatCardData(
              count: c.requestedUser.value,
              title: 'Requested Users',
              color: AppSemanticColors.neutral,
              backgroundColor: AppSemanticColors.neutralBg,
              icon: Icons.person_add_alt_outlined,
            ),
          ],
          showAlertsPanel: false,
        );
      case UserType.SHOP_ADMIN:
        return _RoleDashboardConfig(
          statCards: (HomeController c) => [
            StatCardData(
              count: c.activeUserCount.value,
              title: 'Active Users',
              color: AppSemanticColors.success,
              backgroundColor: AppSemanticColors.successBg,
              icon: Icons.person_outline,
            ),
            StatCardData(
              count: c.inActiveUserCount.value,
              title: 'Inactive Users',
              color: AppSemanticColors.info,
              backgroundColor: AppSemanticColors.infoBg,
              icon: Icons.person_off_outlined,
            ),
            StatCardData(
              count: c.requestedUser.value,
              title: 'Requested Users',
              color: AppSemanticColors.neutral,
              backgroundColor: AppSemanticColors.neutralBg,
              icon: Icons.person_add_alt_outlined,
            ),
          ],
          showAlertsPanel: true,
        );
      case UserType.CUSTOMER:
      case UserType.RIDER:
        return null;
    }
  }
}

/// What differs between roles on this one dashboard — the stat cards shown
/// and whether the shop-scoped alerts panel (new orders / low stock /
/// expiring soon) applies. Everything else (greeting, chart, layout) is
/// shared. This replaces 5 near-identical ~200-line view classes
/// (_RootAdminHome, _AffiliatesAdminView, _CountryAdminView,
/// _MerchantAdminView, _ShopAdminView) that differed only in this data.
class _RoleDashboardConfig {
  final List<StatCardData> Function(HomeController) statCards;
  final bool showAlertsPanel;

  const _RoleDashboardConfig({required this.statCards, required this.showAlertsPanel});
}

class _RoleDashboard extends StatelessWidget {
  final HomeController controller;
  final _RoleDashboardConfig config;
  final ResponsiveScreen screen;

  const _RoleDashboard({
    required this.controller,
    required this.config,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FlutterDashboardListView(
        slivers: [
          SliverVisibility(
            visible: deletionStatusController.isVisible.value,
            sliver: SliverToBoxAdapter(child: DeletionStatusView()),
          ),
          SliverVisibility(
            visible: !deletionStatusController.isVisible.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: AppSpacing.xl,
              topPadding: AppSpacing.xl,
              bottomPadding: 0,
              child: SliverToBoxAdapter(child: _GreetingHeader(controller: controller)),
            ),
          ),
          SliverVisibility(
            visible: !deletionStatusController.isVisible.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: AppSpacing.xl,
              topPadding: AppSpacing.lg,
              child: FlutterDashboardListView.grid(
                isSliverItem: true,
                childCount: 3,
                gridDelegate: screen.isPhone
                    ? null
                    : !screen.isDesktop
                        ? FlutterDashboardGridDelegates.columns_1(width: screen.width, length: 3)
                        : FlutterDashboardGridDelegates.fit(3, 3, 1),
                crossAxisSpacing: screen.isDesktop ? AppSpacing.lg : 0,
                mainAxisSpacing: AppSpacing.lg,
                buildItem: (BuildContext context, int index) {
                  return Obx(() {
                    final cards = config.statCards(controller);
                    if (controller.isloading.value && index != 0) {
                      return const CommonCard(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return StatCard(data: cards[index]);
                  });
                },
                listType: FlutterDashboardListType.Grid,
              ),
            ),
          ),
          SliverVisibility(
            visible: !deletionStatusController.isVisible.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: AppSpacing.xl,
              topPadding: AppSpacing.xxl,
              child: SliverToBoxAdapter(
                child: Obx(
                  () => PerformanceChartCard(
                    data: controller.data,
                    isLoading: controller.isLoadingChart.value,
                  ),
                ),
              ),
            ),
          ),
          if (config.showAlertsPanel)
            SliverVisibility(
              visible: !deletionStatusController.isVisible.value,
              sliver: PaddingWrapper(
                isSliverItem: true,
                topPadding: AppSpacing.xxl,
                child: const SliverToBoxAdapter(child: DashboardAlertsPanel()),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final HomeController controller;
  const _GreetingHeader({required this.controller});

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final String firstName = (controller.user?.fullname ?? '').split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstName.isEmpty ? '${_greeting()} 👋' : '${_greeting()}, $firstName 👋',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          "Here's what's happening with your store today.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
        ),
      ],
    );
  }
}
