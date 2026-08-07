import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vdsadmin/banners/banner.dart';
import 'package:vdsadmin/billing/bill.dart';
import 'package:vdsadmin/category/category1.dart';
import 'package:vdsadmin/category_wise/category.dart';
import 'package:vdsadmin/database/add_item_to_db.dart';
import 'package:vdsadmin/gridView/grid_vw.dart';
import 'package:vdsadmin/home/loginpage.dart';
import 'package:vdsadmin/models/product_data.dart';
import 'package:vdsadmin/notification/notifyhome.dart';
import 'package:vdsadmin/orders/orders.dart';
import 'package:vdsadmin/settings/settings_screen.dart';
import 'package:vdsadmin/theme_controller.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xff17191c) : const Color(0xffF5F6F8);
    final appBarTextColor = isDark ? Colors.white : Colors.black87;

    final cards = <_DashboardCardData>[
      _DashboardCardData(
        title: 'Add Items',
        subtitle: 'Add to stock',
        icon: Icons.add_box_outlined,
        color: const Color(0xFFE44E4F),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ShopRegister())),
      ),
      _DashboardCardData(
        title: 'Category',
        subtitle: 'Manage category & sub-category',
        icon: Icons.category_outlined,
        color: const Color(0xFF6674F1),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Category1())),
      ),
      _DashboardCardData(
        title: 'Orders',
        subtitle: 'Online and offline',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF08B499),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Orderspage())),
      ),
      _DashboardCardData(
        title: 'Banners',
        subtitle: 'Home screen banners',
        icon: Icons.image_outlined,
        color: const Color(0xFFE67E49),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BannerDisplay())),
      ),
      _DashboardCardData(
        title: 'Notification',
        subtitle: 'Send push notifications',
        icon: Icons.notifications_outlined,
        color: const Color(0xFF02D4F9),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const Notificationpage())),
      ),
      _DashboardCardData(
        title: 'Grid View',
        subtitle: 'Browse products',
        icon: Icons.grid_view_rounded,
        color: const Color(0xFF3D5AFE),
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
        color: const Color(0xFFBA779A),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Category())),
      ),
      _DashboardCardData(
        title: 'Profile & Settings',
        subtitle: 'Account and store settings',
        icon: Icons.settings_outlined,
        color: const Color(0xFF546E7A),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SettingsScreen())),
      ),
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Vishal Departmental Store',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  color: appBarTextColor),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              'Admin Panel',
              style: TextStyle(
                  fontSize: 20.0,
                  color: appBarTextColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0),
            ),
          ],
        ),
        backgroundColor: const Color(0xffF3AB0D),
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
                            _DashboardCard(data: card, isDark: isDark),
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
                  decoration: const BoxDecoration(
                      color: Color(0xffF3AB0D),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
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
                                color: Color(0xffF3AB0D)),
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
  final bool isDark;

  const _DashboardCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: data.color,
      borderRadius: BorderRadius.circular(18),
      elevation: isDark ? 0 : 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: data.onTap,
        child: Container(
          width: 230,
          height: 150,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: Colors.white, size: 26),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      color: const Color(0xFF003D64),
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
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
                  const Text(
                    'Start Billing',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.0,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Scan or add items to create a new bill',
                    style: TextStyle(color: Colors.white.withOpacity(0.75)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 42.0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xFF00578D),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Click Here', style: TextStyle(color: Colors.white)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
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
