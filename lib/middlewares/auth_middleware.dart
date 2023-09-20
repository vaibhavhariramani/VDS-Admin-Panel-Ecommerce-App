import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../app/routes/app_pages.dart';
import '../services/auth_service.dart';

class EnsureAuthenticated extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    AuthService.to.readAuthToken();
    if (!AuthService.to.isAuthenticated) {
      final newRoute = Routes.LOGIN_THEN(route.location!);
      return GetNavConfig.fromRoute(newRoute);
    }
    return await super.redirectDelegate(route);
  }
}

class EnsureNotAuthenticated extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    AuthService.to.readAuthToken();
    if (AuthService.to.isAuthenticated) {
      const newRoute = DashboardRoutes.DASHBOARD;
      return GetNavConfig.fromRoute(newRoute);
    }
    return await super.redirectDelegate(route);
  }
}
