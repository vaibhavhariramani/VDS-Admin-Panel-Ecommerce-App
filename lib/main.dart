// ignore_for_file: unnecessary_const

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vdsadmin/billing/startbilling.dart';
// import 'package:vdsadmin/category/category.dart';
// import 'package:vdsadmin/category/category1.dart';
// import 'package:vdsadmin/example.dart';
// import 'package:auto_size_text/auto_size_text.dart';
import 'package:vdsadmin/home/splashscreen.dart';
// import 'constant.dart';
// import 'database/add_item_to_db.dart';
import 'firebase_options.dart';
import 'settings/store_settings_controller.dart';
import 'theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool user = false;

  @override
  void initState() {
    super.initState();
    _initCheck();
    configOneSignel();
    ThemeController.initialize();
    StoreSettingsController.initialize();
  }

  void configOneSignel() {
    OneSignal.initialize('d43fa4f9-2fa5-48a3-a184-49636c9d96c5');
  }

  void _initCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('user') != null) {
      setState(() {
        user = prefs.getBool('user')!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    final ThemeData darkTheme = ThemeData.dark();
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          theme: theme.copyWith(
            colorScheme:
                theme.colorScheme.copyWith(secondary: const Color(0xffF5F6F8)),
          ),
          darkTheme: darkTheme.copyWith(
            colorScheme: darkTheme.colorScheme.copyWith(
              secondary: const Color(0xff2A2E32),
            ),
          ),
          themeMode: mode,
          title: 'Admin Panel',
          debugShowCheckedModeBanner: false,
          home: SplashScreen(user),
        );
      },
    );
  }
}
