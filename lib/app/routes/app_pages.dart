import 'package:flutter/material.dart';

import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../middlewares/auth_middleware.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/billing/bindings/billing_binding.dart';
import '../modules/billing/views/billing_view.dart';
import '../modules/deletion_status/bindings/deletion_status_binding.dart';
import '../modules/deletion_status/controllers/deletion_status_controller.dart';
import '../modules/deletion_status/views/deletion_status_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/merchants/bindings/merchants_binding.dart';
import '../modules/merchants/views/merchants_view.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/orders_view.dart';
import '../modules/orders/views/order_details.dart';
import '../modules/products/product_management/bindings/product_management_binding.dart';
import '../modules/products/product_management/views/product_management_view.dart';
import '../modules/products/products_listing/bindings/products_listing_binding.dart';
import '../modules/products/products_listing/views/products_listing_view.dart';
import '../modules/shop_listing/bindings/shop_listing_binding.dart';
import '../modules/shop_listing/views/shop_listing_view.dart';
import '../modules/storefront/bindings/storefront_binding.dart';
import '../modules/storefront/views/storefront_overview_view.dart';
import '../modules/customers/bindings/customers_binding.dart';
import '../modules/customers/views/customers_view.dart';
import '../utilities/contact_us/bindings/contact_us_binding.dart';
import '../utilities/contact_us/views/contact_us_view.dart';
import '../utilities/help/bindings/help_binding.dart';
import '../utilities/help/views/help_view.dart';
import '../utilities/settings/bindings/settings_binding.dart';
import '../utilities/settings/views/settings_view.dart';
import '../utilities/team/team_binding.dart';
import '../utilities/team/team_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.DELETION_STATUS,
      page: () => DeletionStatusView(),
      binding: DeletionStatusBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCTS_LISTING,
      page: () => ProductsListingView(),
      binding: ProductsListingBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCTS,
      page: () => const ProductManagementView(),
      binding: ProductManagementBinding(),
    ),
    GetPage(
      name: _Paths.ORDERS,
      page: () => OrdersView(),
      binding: OrdersBinding(),
      children: [
        GetPage(
          name: _Paths.ORDERS,
          page: () => OrdersView(),
          binding: OrdersBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.BILLING,
      page: () => BillingView(),
      binding: BillingBinding(),
    ),
    GetPage(
      name: _Paths.TEAM,
      page: () => const TeamView(),
      binding: TeamBinding(),
      middlewares: [EnsureAuthenticated()],
    ),
  ];

  static final List<GetPage> rootPages = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
      middlewares: [
        EnsureNotAuthenticated(),
      ],
    ),
  ];

  static List<FlutterDashboardItem> footerPages(BuildContext context) {
    DeletionStatusController deletionStatusController =
        Get.put(DeletionStatusController());
    return [
      // FlutterDashboardItem(
      //   title: 'Account',
      //   page: GetPage(
      //     name: _Paths.ACCOUNT,
      //     page: () {
      //       deletionStatusController.isVisible.value = false;
      //       return AccountView();
      //     },
      //     binding: AccountBinding(),
      //     middlewares: [
      //       EnsureAuthenticated(),
      //     ],
      //   ),
      //   icon: const Icon(
      //     Icons.settings,
      //   ),
      //   selectedIcon: Icon(
      //     Icons.settings,
      //     color: Theme.of(context).scaffoldBackgroundColor,
      //   ),
      // ),
      FlutterDashboardItem(
        title: 'Notifications',
        page: GetPage(
          name: _Paths.CONTACT_US,
          page: () {
            deletionStatusController.isVisible.value = false;
            return ContactUsView();
          },
          binding: ContactUsBinding(),
          middlewares: [
            EnsureAuthenticated(),
          ],
        ),
        icon: const Icon(
          Icons.notifications_outlined,
        ),
        selectedIcon: Icon(
          Icons.notifications,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      FlutterDashboardItem(
        title: 'FAQs',
        page: GetPage(
          name: _Paths.HELP,
          page: () {
            deletionStatusController.isVisible.value = false;
            return const HelpView();
          },
          binding: HelpBinding(),
          middlewares: [
            EnsureAuthenticated(),
          ],
        ),
        icon: const Icon(
          Icons.help_outline_sharp,
        ),
        selectedIcon: Icon(
          Icons.help_outlined,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      FlutterDashboardItem(
        title: 'Settings',
        page: GetPage(
          name: _Paths.SETTINGS,
          page: () {
            deletionStatusController.isVisible.value = false;
            return const SettingsView();
          },
          binding: SettingsBinding(),
          middlewares: [
            EnsureAuthenticated(),
          ],
        ),
        icon: const Icon(
          Icons.settings_outlined,
        ),
        selectedIcon: Icon(
          Icons.settings,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    ];
  }

  static List<FlutterDashboardItem> allPages(BuildContext context) {
    // DeletionStatusController deletionStatusController =
    //     Get.put(DeletionStatusController());

    return [
      FlutterDashboardItem(
        title: 'Dashboard',
        page: GetPage(
          name: _Paths.HOME,
          page: () {
            // deletionStatusController.isVisible.value = false;
            return HomeView();
          },
          binding: HomeBinding(),
          middlewares: [
            EnsureAuthenticated(),
          ],
          children: [
            GetPage(
              name: _Paths.CONTACT_US,
              page: () => ContactUsView(),
              binding: ContactUsBinding(),
            ),
          ],
        ),
        icon: const Icon(
          IconlyLight.home,
        ),
        selectedIcon: Icon(
          IconlyBold.home,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      // FlutterDashboardItem(
      //   title: 'Country Partners',
      //   page: GetPage(
      //     name: _Paths.COUNTRY_PARTNERS,
      //     page: () {
      //       deletionStatusController.isVisible.value = false;
      //       return CountryPartnersView();
      //     },
      //     binding: CountryPartnersBinding(),
      //     middlewares: [
      //       EnsureAuthenticated(),
      //     ],
      //   ),
      //   icon: const Icon(
      //     IconlyLight.discovery,
      //   ),
      //   selectedIcon: Icon(
      //     IconlyBold.discovery,
      //     color: Theme.of(context).scaffoldBackgroundColor,
      //   ),
      // ),
      // FlutterDashboardItem.items(
      //   title: 'Users',
      //   icon: const Icon(
      //     IconlyLight.user,
      //   ),
      //   subItems: [
      //     FlutterDashboardItem(
      //       title: 'Affiliate',
      //       page: GetPage(
      //         name: _Paths.AFFILIATE,
      //         page: () {
      //           deletionStatusController.isVisible.value = false;
      //           return AffiliateView();
      //         },
      //         binding: AffiliateBinding(),
      //         middlewares: [
      //           EnsureAuthenticated(),
      //         ],
      //       ),
      //       icon: SizedBox.square(
      //         dimension: 24,
      //         child: Image.asset(
      //           "assets/check_box.png",
      //           scale: 1,
      //           color: AppColors.grey,
      //         ),
      //       ),
      //       selectedIcon: SizedBox.square(
      //         dimension: 24,
      //         child: Image.asset(
      //           "assets/check_box.png",
      //           scale: 1,
      //           color: Theme.of(context).scaffoldBackgroundColor,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),

      // FlutterDashboardItem(
      //   title: 'Registration',
      //   page: GetPage(
      //     name: _Paths.REGISTRATION,
      //     page: () {
      //       return RegistrationView();
      //     },
      //     binding: RegistrationBinding(),
      //     middlewares: [
      //       EnsureAuthenticated(),
      //     ],
      //   ),
      //   icon: const Icon(
      //     IconlyLight.home,
      //   ),
      //   selectedIcon: Icon(
      //     IconlyBold.home,
      //     color: Theme.of(context).scaffoldBackgroundColor,
      //   ),
      // ),
      // Order below is alphabetical (Dashboard excepted, pinned first
      // above) among whichever of these a given role actually sees -
      // FlutterDashboardNavService renders items in this list's order,
      // filtered to AuthService.enableOrDisableRoutes()'s per-role set.
      FlutterDashboardItem(
        title: 'Shop Listing',
        page: GetPage(
          name: _Paths.SHOP_LISTING,
          page: () {
            deletionStatusController.isVisible.value = false;
            return ShopListingView();
          },
          binding: ShopListingBinding(),
          middlewares: [
            EnsureAuthenticated(),
          ],
        ),
        icon: const Icon(
          Icons.person_outline,
        ),
        selectedIcon: Icon(
          Icons.person_outline,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      FlutterDashboardItem(
        title: 'Merchants',
        page: GetPage(
          name: _Paths.MERCHANTS,
          page: () {
            deletionStatusController2.isVisible.value = false;
            return MerchantsView();
          },
          binding: MerchantsBinding(),
          middlewares: [
            EnsureAuthenticated(),
          ],
        ),
        icon: const Icon(
          IconlyLight.profile,
        ),
        selectedIcon: Icon(
          IconlyBold.profile,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      // FlutterDashboardItem(
      //   title: 'Magazine',
      //   page: GetPage(
      //     name: _Paths.MAGAZINE,
      //     page: () {
      //       deletionStatusController.isVisible.value = false;
      //       return MagazineView();
      //     },
      //     binding: MagazineBinding(),
      //     middlewares: [
      //       EnsureAuthenticated(),
      //     ],
      //   ),
      //   icon: const Icon(
      //     IconlyLight.scan,
      //   ),
      //   selectedIcon: Icon(
      //     IconlyBold.scan,
      //     color: Theme.of(context).scaffoldBackgroundColor,
      //   ),
      // ),
      FlutterDashboardItem(
        title: 'Billing',
        page: GetPage(
          name: _Paths.BILLING,
          page: () => BillingView(),
          binding: BillingBinding(),
          middlewares: [
            EnsureAuthenticated(),
          ],
        ),
        icon: const Icon(
          IconlyLight.discount,
        ),
        selectedIcon: Icon(
          IconlyBold.discount,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      FlutterDashboardItem(
        title: 'Customers',
        page: GetPage(
          name: _Paths.CUSTOMERS,
          page: () => const CustomersView(),
          binding: CustomersBinding(),
          middlewares: [EnsureAuthenticated()],
        ),
        icon: const Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people, color: Theme.of(context).scaffoldBackgroundColor),
      ),
      FlutterDashboardItem(
        title: 'Products',
        page: GetPage(
          name: _Paths.PRODUCTS,
          page: () => const ProductManagementView(),
          binding: ProductManagementBinding(),
          middlewares: [
            EnsureAuthenticated(),
          ],
        ),
        icon: const Icon(
          IconlyLight.bag_2,
        ),
        selectedIcon: Icon(
          IconlyBold.bag_2,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      FlutterDashboardItem(
        title: 'Orders',
        page: GetPage(
          name: _Paths.ORDERS,
          page: () => OrdersView(),
          binding: OrdersBinding(),
          middlewares: [
            EnsureAuthenticated(),
          ],
          children: [
            // Gives an opened order a real, shareable/refreshable URL
            // (/dashboard/orders/online/order-details/<id>) instead of the
            // previous plain Navigator.push, which never touched the URL
            // at all. OrderDetails resolves the order itself - from route
            // arguments when navigated here from the table (no extra
            // fetch), or by fetching :orderId directly on a deep link/
            // refresh.
            GetPage(
              name: '/online/order-details/:orderId',
              page: () => const OrderDetails(),
              middlewares: [
                EnsureAuthenticated(),
              ],
            ),
          ],
        ),
        icon: const Icon(
          IconlyLight.bag,
        ),
        selectedIcon: Icon(
          IconlyBold.bag,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      FlutterDashboardItem(
        title: 'Storefront',
        page: GetPage(
          name: _Paths.STOREFRONT,
          page: () {
            deletionStatusController.isVisible.value = false;
            return const StorefrontOverviewView();
          },
          binding: StorefrontBinding(),
          middlewares: [
            EnsureAuthenticated(),
          ],
        ),
        icon: const Icon(
          Icons.storefront_outlined,
        ),
        selectedIcon: Icon(
          Icons.storefront,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),

      // FlutterDashboardItem(
      //   title: 'Action Log',
      //   page: GetPage(
      //     name: _Paths.ACTION_LOG,
      //     page: () {
      //       deletionStatusController.isVisible.value = false;
      //       return ActionLogView();
      //     },
      //     binding: ActionLogBinding(),
      //     middlewares: [
      //       EnsureAuthenticated(),
      //     ],
      //   ),
      //   icon: const Icon(
      //     Icons.visibility_outlined,
      //   ),
      //   selectedIcon: Icon(
      //     Icons.visibility_rounded,
      //     color: Theme.of(context).scaffoldBackgroundColor,
      //   ),
      // ),
      // FlutterDashboardItem(
      //   title: "Subscriptions",
      //   page: GetPage(
      //     name: _Paths.SUBSCRIPTIONS,
      //     page: () {
      //       deletionStatusController.isVisible.value = false;
      //       return SubscriptionsView();
      //     },
      //     binding: SubscriptionsBinding(),
      //     middlewares: [
      //       EnsureAuthenticated(),
      //     ],
      //   ),
      //   icon: const Icon(IconlyLight.discount),
      //   selectedIcon: Icon(IconlyBold.discount,
      //       color: Theme.of(context).scaffoldBackgroundColor),
      // ),
      // FlutterDashboardItem(
      //   title: "Banner Ads",
      //   page: GetPage(
      //     name: _Paths.BANNER_ADS,
      //     page: () {
      //       deletionStatusController.isVisible.value = false;
      //       return BannerAdsView();
      //     },
      //     binding: BannerAdsBinding(),
      //     middlewares: [
      //       EnsureAuthenticated(),
      //     ],
      //   ),
      //   icon: Image.asset(
      //     'assets/subscription.png',
      //     color: Colors.green,
      //     width: 20,
      //     height: 20,
      //   ),
      //   selectedIcon: Image.asset(
      //     'assets/subscription.png',
      //     color: Colors.white,
      //     width: 25,
      //     height: 25,
      //   ),
      // ),
      // // Remove this only after deletion status is fucntional
      // FlutterDashboardItem(
      //   title: "Notifications",
      //   page: GetPage(
      //     name: _Paths.DELETION_STATUS,
      //     page: () => DeletionStatusView(),
      //     binding: DeletionStatusBinding(),
      //     middlewares: [
      //       EnsureAuthenticated(),
      //     ],
      //   ),
      //   icon: const Icon(
      //     IconlyLight.notification,
      //   ),
      //   selectedIcon: Icon(
      //     IconlyBold.notification,
      //     color: Theme.of(context).scaffoldBackgroundColor,
      //   ),
      // )

      // FlutterDashboardItem(
      //   title: 'Payments',
      //   page: GetPage(
      //     name: _Paths.PAYMENTS,
      //     page: () => PaymentsView(),
      //     binding: PaymentsBinding(),
      //   ),
      //   icon: const Icon(
      //     IconlyLight.wallet,
      //   ),
      //   selectedIcon: Icon(
      //     IconlyBold.wallet,
      //     color: Theme.of(context).scaffoldBackgroundColor,
      //   ),
      // ),
    ];
  }
}
