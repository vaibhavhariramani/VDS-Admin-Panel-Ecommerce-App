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

  // Takes BuildContext (RootApp.build's, from the plain MaterialApp wrapping
  // it in main()) instead of reading Get.height: this getter runs while
  // FlutterDashboardMaterialApp - and the GetMaterialApp.router inside it -
  // is still being constructed, so GetX's own navigator/context isn't
  // attached yet and Get.height null-checks a window that doesn't exist.
  static DashboardConfig dashboardConfig(BuildContext context) => DashboardConfig(
        enableSpacing: false,
        enableBodySpacing: true,
        debugShowCheckedModeBanner: false,
        hasScrollingBody: false,
        brandLogo: Image.asset(
          "assets/drawer_logo.png",
          scale: 1,
        ),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        // Settings > Dark mode switches this live via Get.changeThemeMode()
        // regardless of what's picked here - this only decides which mode
        // the app boots into, from whatever was last saved to GetStorage.
        themeMode: GetStorage().read(themeModeStorageKey) == 'dark'
            ? ThemeMode.dark
            : ThemeMode.light,
        dashboardAppbarPadding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.03,
        ),
      );

  static DrawerOptions drawerOptions(BuildContext context) => DrawerOptions(
        selectedItemColor: const Color.fromARGB(255, 197, 236, 182),
        selectedTextColor: Colors.green,
        footer: Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: Padding(
            // Was bottom: 10 - the drawer's footer area (nav list + this
            // footer widget) sits in a SliverFillRemaining(hasScrollBody:
            // false), which doesn't grant extra scroll room for overflow.
            // Adding the Settings item to the footer nav list pushed total
            // content 1px past the remaining space; trimming this margin
            // gives back more than enough room without a visible change.
            padding: const EdgeInsets.only(
              bottom: 2,
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
