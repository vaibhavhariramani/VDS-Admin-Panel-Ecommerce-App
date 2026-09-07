import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'app/routes/app_pages.dart';
import 'app/utilities/settings/controllers/settings_controller.dart';
import 'app/widgets/appbar_actions/go_to_live_store_button.dart';
import 'app/widgets/appbar_actions/notification_button.dart';
import 'app/widgets/appbar_actions/user_button.dart';
import 'app/widgets/components/brand_mark.dart';
import 'app/widgets/components/not_found_page.dart';
import 'app/widgets/drawer_header.dart';
import 'firebase_options.dart';
import 'middlewares/auth_middleware.dart';
import 'services/auth_service.dart';
import 'services/create_data.dart';
import 'services/data_service.dart';
import 'services/fetch_data.dart';
import 'services/storefront_service.dart';
import 'services/update_data.dart';
import 'themes/app_theme.dart';
part './configurations/app_configs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setPathUrlStrategy();
  await GetStorage.init();
  // await initHiveForFlutter();
  packageInfo = await PackageInfo.fromPlatform();
  runApp(MaterialApp(home: RootApp()));
}

class RootApp extends AppConfig {
  const RootApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   color: Colors.blue,
    //   child: Text('Colored Card'),
    // );

    return FlutterDashboardMaterialApp(
      title: "Local Bazaar Admin",
      dashboardItems: AppPages.allPages(context),
      notFoundPage: const NotFoundPage(),
      // This was commented out, so FlutterDashboardMaterialApp fell back to
      // DashboardConfig's own bare defaults (theme/darkTheme both null,
      // themeMode: ThemeMode.system) instead of AppTheme's actual
      // light/dark themes - GetMaterialApp.router falls back to `theme`
      // for every mode when `darkTheme` is null, so Settings' dark-mode
      // toggle had nothing to switch to no matter what it set.
      config: AppConfig.dashboardConfig(context),

      drawerOptions: AppConfig.drawerOptions(context),
      appBarOptions: AppConfig.rootAppBarOptions,
      overrideActions: [
        NotificationButton(),
        const GoToLiveStoreButton(),
        AppBarUserButton(),
      ],
      rootControllers: [
        Get.lazyPut(() => AuthService(), fenix: true),
        Get.lazyPut(() => DataService(), fenix: true),
        Get.lazyPut(() => FetchService(), fenix: true),
        Get.lazyPut(() => CreateService(), fenix: true),
        Get.lazyPut(() => UpdateService(), fenix: true),
        Get.lazyPut(() => StorefrontService(), fenix: true),
      ],
      rootPages: AppPages.rootPages,
      dashboardMiddlewares: [
        EnsureAuthenticated(),
      ],
      overrideRootPage: (BuildContext context, GetDelegate delegate,
          GetNavConfig? currentRoute) {
        String _initialRoute = '/';

        if (AuthService.to.isAuthenticated) {
          _initialRoute = DashboardRoutes.DASHBOARD;
        } else {
          _initialRoute = Routes.LOGIN;
        }
        return GetRouterOutlet(
          initialRoute: _initialRoute,
        );
      },
      builder: BotToastInit(), //1. call BotToastInit
      navigatorObservers: [
        BotToastNavigatorObserver(),
      ],
    );
  }
}
