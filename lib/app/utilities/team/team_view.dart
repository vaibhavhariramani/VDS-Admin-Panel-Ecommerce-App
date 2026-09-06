import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/InvitedUserStatus.dart';
import '../../../models/UserType.dart';
import '../../../models/Users.dart';
import '../../../themes/app_theme.dart';
import 'invite_team_member_dialog.dart';
import 'permissions_dialog.dart';
import 'team_controller.dart';

class TeamView extends GetView<TeamController> {
  const TeamView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team & Permissions'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: ElevatedButton.icon(
              onPressed: () => Get.dialog(InviteTeamMemberDialog(controller: controller)),
              icon: const Icon(Icons.person_add_alt_outlined, size: 18),
              label: const Text('Invite'),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadTeam,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search team members by name or email',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (controller.pendingInvites.isNotEmpty) ...[
                Text('Pending invites', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                ...controller.pendingInvites.map((invite) => Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: ListTile(
                        leading: const Icon(Icons.mail_outline),
                        title: Text(invite.email ?? invite.fullname ?? 'Pending invite'),
                        subtitle: Text(invite.user_type?.label ?? 'Unknown role'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppSemanticColors.warningBg,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            invite.status == InvitedUserStatus.PENDING ? 'Pending' : (invite.status?.name ?? ''),
                            style: const TextStyle(color: AppSemanticColors.warning, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: AppSpacing.xl),
              ],
              Text('Team members', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              if (controller.visibleStaff.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(
                    child: Text(
                      controller.staffUsers.isEmpty ? 'No team members found.' : 'No team members match your search.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
                    ),
                  ),
                )
              else
                ...controller.visibleStaff.map((user) => _TeamMemberTile(user: user, controller: controller)),
            ],
          ),
        );
      }),
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  final Users user;
  final TeamController controller;
  const _TeamMemberTile({required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool hasOverride = user.permissions != null;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.12),
          child: Text(
            (user.fullname?.isNotEmpty == true ? user.fullname![0] : (user.email?.isNotEmpty == true ? user.email![0] : '?'))
                .toUpperCase(),
            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(user.fullname?.isNotEmpty == true ? user.fullname! : (user.email ?? 'Team member')),
        subtitle: Text('${user.roleLabel}${hasOverride ? ' · custom permissions' : ''}'),
        trailing: OutlinedButton(
          onPressed: () => Get.dialog(PermissionsDialog(user: user, controller: controller)),
          child: const Text('Permissions'),
        ),
      ),
    );
  }
}
