import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../models/InvitedUser.dart';
import '../../../models/Permission.dart';
import '../../../models/UserType.dart';
import '../../../models/Users.dart';
import '../../../services/auth_service.dart';
import '../../../services/data_service.dart';

/// Roles an admin can actually pick when inviting someone new here.
/// CUSTOMER and RIDER accounts aren't invited from the admin panel (see
/// docs/architecture/MULTI_TENANCY.md — customers self-register via the
/// Client app, riders are provisioned separately for the Delivery app).
const List<UserType> kInvitableRoles = [
  UserType.SHOP_ADMIN,
  UserType.MERCHANT,
  UserType.COUNTRY_HEAD,
  UserType.AFFILIATES,
  UserType.ADMIN,
];

class TeamController extends GetxController {
  final DataService _dataService = DataService.to;

  final RxBool isLoading = true.obs;
  final RxList<Users> staffUsers = <Users>[].obs;
  final RxList<InvitedUser> pendingInvites = <InvitedUser>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isInviting = false.obs;

  List<Users> get visibleStaff {
    final String query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return staffUsers;
    return staffUsers.where((u) {
      return (u.fullname?.toLowerCase().contains(query) ?? false) ||
          (u.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadTeam();
  }

  Future<void> loadTeam() async {
    isLoading(true);
    final results = await Future.wait([
      _dataService.fetchStaffUsers(),
      _dataService.fetchAllPendingInvites(),
    ]);
    staffUsers.assignAll(results[0] as List<Users>);
    pendingInvites.assignAll(results[1] as List<InvitedUser>);
    isLoading(false);
  }

  /// Returns null on success, or an error message.
  Future<String?> invite({required String email, required UserType role}) async {
    final String trimmed = email.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      return 'Enter a valid email address.';
    }
    isInviting(true);
    try {
      await _dataService.invitingUser(inviteuser: [trimmed], user_type: role);
      await loadTeam();
      return null;
    } catch (e) {
      return 'Could not send the invitation. Please try again.';
    } finally {
      isInviting(false);
    }
  }

  Future<bool> updatePermissions(String uid, Set<String>? permissions) async {
    final bool ok = await _dataService.updateUserPermissions(uid, permissions);
    if (ok) await loadTeam();
    return ok;
  }

  bool get canManageTeam =>
      AuthService.to.hasPermission(Permission.platformFullAccess) ||
      AuthService.to.hasPermission(Permission.shopsManage) ||
      AuthService.to.hasPermission(Permission.regionsManage);
}
