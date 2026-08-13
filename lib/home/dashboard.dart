import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vdsadmin/attendance/attendance_screen.dart';
import 'package:vdsadmin/banners/banner.dart';
import 'package:vdsadmin/billing/bill.dart';
import 'package:vdsadmin/billing/invoice_requests/invoice_requests_screen.dart';
import 'package:vdsadmin/category/category1.dart';
import 'package:vdsadmin/category_wise/category.dart';
import 'package:vdsadmin/customers/customer_list_screen.dart';
import 'package:vdsadmin/database/add_item_to_db.dart';
import 'package:vdsadmin/gridView/grid_vw.dart';
import 'package:vdsadmin/home/loginpage.dart';
import 'package:vdsadmin/models/product_data.dart';
import 'package:vdsadmin/notification/notifyhome.dart';
import 'package:vdsadmin/orders/orders.dart';
import 'package:vdsadmin/settings/settings_screen.dart';
import 'package:vdsadmin/theme/app_theme.dart';
import 'package:vdsadmin/theme_controller.dart';
import 'package:vdsadmin/utils/role_controller.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
}

class Dashboard extends StatefulWidget {
  List<ProductData> MasterproductListForBilling = [];
  Dashboard({Key? key, required this.MasterproductListForBilling})
      : super(key: key);
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? username;
  String? fullname;

  @override
  void initState() {
    getToken();

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print("onMessage: $message");
        //_showItemDialog(message);
      },
    );
    //onBackgroundMessage: myBackgroundMessageHandler,
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        print("onLaunch: $message");
        //_navigateToItemDetail(message);
      },
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    super.initState();
    name();
  }

  void name() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username')!;
      fullname = prefs.getString('fullname')!;
    });
  }

  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    prefs.setString('username', username ?? "");
    prefs.setString('fullname', fullname ?? "");
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (c) => const Login()));
  }

  String token = '';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  void getToken() async {
    token = (await firebaseMessaging.getToken())!;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('Users');
    // final status = await OneSignal.shared.getDeviceState();
    final status = OneSignal.User.toString();
    // final String? tokenId = status?.userId;
    final String tokenId = status;
    print('token ID is : $tokenId');
    try {
      reference.doc(username).update({
        'OneSignalTokenID': tokenId,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode(context);

    final cards = <_DashboardCardData>[
      _DashboardCardData(
        title: 'Add Items',
        subtitle: 'Add to stock',
        icon: Icons.add_box_outlined,
        color: AppColors.accentRed,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ShopRegister())),
      ),
      _DashboardCardData(
        title: 'Category',
        subtitle: 'Manage category & sub-category',
        icon: Icons.category_outlined,
        color: AppColors.accentBlue,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Category1())),
      ),
      _DashboardCardData(
        title: 'Orders',
        subtitle: 'Online and offline',
        icon: Icons.receipt_long_outlined,
        color: AppColors.accentTeal,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Orderspage())),
      ),
      _DashboardCardData(
        title: 'Banners',
        subtitle: 'Home screen banners',
        icon: Icons.image_outlined,
        color: AppColors.accentAmber,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BannerDisplay())),
      ),
      _DashboardCardData(
        title: 'Notification',
        subtitle: 'Send push notifications',
        icon: Icons.notifications_outlined,
        color: AppColors.accentCyan,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const Notificationpage())),
      ),
      _DashboardCardData(
        title: 'Grid View',
        subtitle: 'Browse products',
        icon: Icons.grid_view_rounded,
        color: AppColors.accentIndigo,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GridScreen(
                dataViewer: true,
                listOfProductsInBill: widget.MasterproductListForBilling,
              ),
            )),
      ),
      _DashboardCardData(
        title: 'Category View',
        subtitle: 'Products by category',
        icon: Icons.dashboard_customize_outlined,
        color: AppColors.accentPink,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Category())),
      ),
      _DashboardCardData(
        title: 'Customer Base',
        subtitle: 'Search customers & order history',
        icon: Icons.people_alt_outlined,
        color: AppColors.primaryDark,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CustomerListScreen())),
      ),
      _DashboardCardData(
        title: 'Invoice Requests',
        subtitle: RoleController.isSuperAdmin
            ? 'Review employee bills'
            : 'Track your submitted bills',
        icon: Icons.receipt_long_outlined,
        color: AppColors.accentTeal,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const InvoiceRequestsScreen())),
      ),
      _DashboardCardData(
        title: 'Attendance',
        subtitle: RoleController.isSuperAdmin
            ? 'Review hours & approve shifts'
            : 'Clock in / clock out',
        icon: Icons.access_time_outlined,
        color: AppColors.accentCyan,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AttendanceScreen())),
      ),
      _DashboardCardData(
        title: 'Profile & Settings',
        subtitle: 'Account and store settings',
        icon: Icons.settings_outlined,
        color: AppColors.accentSlate,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SettingsScreen())),
      ),
    ];

    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Vishal Departmental Store',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              'Admin Panel',
              style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.get_app),
            onPressed: () {
              getToken();
              print(token);
            },
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: mode == ThemeMode.dark
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
                onPressed: ThemeController.toggle,
              );
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logOut)
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    children: [
                      _StartBillingHero(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Bill(
                              products: widget.MasterproductListForBilling,
                              addedfromDB: false,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          for (final card in cards)
                            _DashboardCard(data: card, dark: dark),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
              initialChildSize: 0.09,
              minChildSize: 0.09,
              maxChildSize: 0.35,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.xl),
                        topRight: Radius.circular(AppRadius.xl),
                      )),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                )),
                            height: 10,
                            width: 100,
                          ),
                        ),
                        CircleAvatar(
                          radius: 36.0,
                          backgroundColor: Colors.white,
                          child: Text(
                            (fullname != null && fullname!.isNotEmpty
                                    ? fullname![0]
                                    : '?')
                                .toUpperCase(),
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Hii, $fullname",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          username ?? "",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen())),
                          icon: const Icon(Icons.settings_outlined,
                              color: Colors.white),
                          label: const Text('Profile & Settings',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              })
        ],
      ),
    );
  }
}

class _DashboardCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _DashboardCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _DashboardCard extends StatelessWidget {
  final _DashboardCardData data;
  final bool dark;

  const _DashboardCard({required this.data, required this.dark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 150,
      child: AppCard(
        padding: const EdgeInsets.all(18),
        onTap: data.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: data.color.withOpacity(dark ? 0.24 : 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(data.icon, color: data.color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppText.bodyStrong(context).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 3),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StartBillingHero extends StatelessWidget {
  final VoidCallback onTap;

  const _StartBillingHero({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Billing',
                    style: AppText.display(context, color: Colors.white)
                        .copyWith(fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Scan or add items to create a new bill',
                    style: AppText.body(context,
                        color: Colors.white.withOpacity(0.85)),
                  ),
                  const SizedBox(height: 20),
                  PillButton(
                    label: 'Click Here',
                    icon: Icons.arrow_forward,
                    onPressed: onTap,
                    filled: true,
                    color: Colors.white,
                  ),
                ],
              ),
              Icon(Icons.point_of_sale_rounded,
                  color: Colors.white.withOpacity(0.25), size: 96),
            ],
          ),
        ),
      ),
    );
  }
}
