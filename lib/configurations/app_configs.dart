part of '../main.dart';

late PackageInfo packageInfo;

abstract class AppConfig extends StatelessWidget {
  const AppConfig({Key? key}) : super(key: key);

  static Map<String, String> get _packageInfoData => {
        "appName": packageInfo.appName,
        "packageName": packageInfo.packageName,
        "version": packageInfo.version,
        "buildNumber": packageInfo.buildNumber,
      };

  static DashboardConfig get dashboardConfig => DashboardConfig(
        enableSpacing: false,
        enableBodySpacing: true,
        debugShowCheckedModeBanner: false,
        hasScrollingBody: false,
        brandLogo: Image.asset(
          "assets/drawer_logo.png",
          scale: 1,
        ),
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        dashboardAppbarPadding: EdgeInsets.only(
          bottom: Get.height * 0.03,
        ),
      );

  static DrawerOptions drawerOptions(BuildContext context) => DrawerOptions(
        selectedItemColor: const Color.fromARGB(255, 197, 236, 182),
        selectedTextColor: Colors.green,
        footer: Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\u24B8 ${(_packageInfoData['appName'] ?? "").replaceAll("_", " ").replaceAll("-", " ").capitalize} - ${DateTime.now().year}',
                  textScaleFactor: Get.textScaleFactor,
                  style: GoogleFonts.poppins().copyWith(
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Version ${_packageInfoData['version']?.replaceAll('.', '.')}',
                  textScaleFactor: Get.textScaleFactor,
                  style: GoogleFonts.poppins().copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        centerHeaderLogo: true,
        overrideHeader: CustomDrawerHeader(),
        listSpacing: 20,
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
        tileShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        footerNavItems: AppPages.footerPages(context),
      );

  static AppBarOptions get rootAppBarOptions => AppBarOptions(
        floating: true,
        floatingOnMobile: true,
        theme: AppBarTheme(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        showTitle: false,
      );

  static FlutterDashboarAuthConfig get authConfiguration =>
      const FlutterDashboarAuthConfig(
          // overrideLoginFunction: (Map<String, dynamic> _credential) async {
          //   print(_credential);
          //   return true;
          // },
          // overrideRegisterFunction:
          //     (Map<String, dynamic> _registrationPayload) async {
          //   return false;
          // },
          // overrideLogoutFunction: () async {
          //   return false;
          // },
          // overrideLoginView: CustomLoginView(),
          // rootUser: const FlutterDashboardUser(
          //   username: 'Cucumia Admin',
          //   email: 'admin@cucumia.com',
          //   password: '#Notroot1',
          //   role: 'Admin',
          // ),
          );
}
