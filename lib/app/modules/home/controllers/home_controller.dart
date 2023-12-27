import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../models/UserStatus.dart';
import '../../../../models/UserType.dart';
import '../../../../models/Users.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/data_service.dart';

class ShopVisitorChartData {
  ShopVisitorChartData(this.x, this.y);
  String? x;
  double? y;

  ShopVisitorChartData.fromJson(Map<String, dynamic> json) {
    x = json['month'];
    y = json['visitors'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['month'] = x;
    data['visitors'] = y;
    return data;
  }
}

class HomeController extends GetxController {
  final AuthService _authService = AuthService.to;
  RxInt activeUserCount = 0.obs;
  RxInt inActiveUserCount = 0.obs;
  RxInt requestedUser = 0.obs;
  final RxBool isloading = false.obs;
  Users? get user => _authService.user.value;
  final AuthService userService = AuthService.to;
  UserType get userType => _authService.userType.value;

  List<ShopVisitorChartData> data = [
    ShopVisitorChartData('Jan', 800),
    ShopVisitorChartData('Feb', 500),
    ShopVisitorChartData('Mar', 650),
    ShopVisitorChartData('Apr', 300),
    ShopVisitorChartData('May', 500),
    ShopVisitorChartData('Jun', 750),
    ShopVisitorChartData('Jul', 400),
    ShopVisitorChartData('Aug', 900),
    ShopVisitorChartData('Sep', 750),
    ShopVisitorChartData('Oct', 600),
    ShopVisitorChartData('Nov', 850),
    ShopVisitorChartData('Dec', 700),
  ];
  Future<void> userCountActive() async {
    // isloading(true);
    await DataService.to
        .GetUserCount(
          status: UserStatus.ACTIVE,
          userType: UserType.CUSTOMER,
        )
        .then(
          (value) => activeUserCount(
            value,
          ),
        );
    // isloading(false);
  }

  Future<void> userCountInactive() async {
    await DataService.to
        .GetUserCount(
          status: UserStatus.INACTIVE,
          userType: UserType.CUSTOMER,
        )
        .then(
          (value) => inActiveUserCount(
            value,
          ),
        );
  }

  void _fetchdata() async {
    userCountActive();
    userCountInactive();
    await DataService.to.FetchInvitedUserData(id: userService.user.value!.id);
    requestedUser(DataService.to.invitedUserCount);
  }

  @override
  void onReady() {
    if (userType == UserType.ADMIN) {
      // FlutterDashboardNavService.to.enabledRoutes.addEntries(const [
      //   MapEntry("Dashboard", true), //Firstpage alsways need to be enabled
      //   MapEntry("Products", false),
      //   MapEntry("Help", false),
      // ]);
    }
    super.onReady();
  }

  @override
  void onInit() {
    _fetchdata();
    super.onInit();
  }

  @override
  void onClose() {}
}
