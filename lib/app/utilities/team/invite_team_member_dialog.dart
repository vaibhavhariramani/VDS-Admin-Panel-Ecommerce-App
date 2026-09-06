import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/UserType.dart';
import '../../../themes/app_theme.dart';
import 'team_controller.dart';

/// Both existing invite flows (Merchants, Shop Listing) hardcode which role
/// they invite — there was previously no way to invite a Country Head or
/// another platform Admin at all. This is deliberately generic instead.
class InviteTeamMemberDialog extends StatefulWidget {
  final TeamController controller;
  const InviteTeamMemberDialog({Key? key, required this.controller}) : super(key: key);

  @override
  State<InviteTeamMemberDialog> createState() => _InviteTeamMemberDialogState();
}

class _InviteTeamMemberDialogState extends State<InviteTeamMemberDialog> {
  final TextEditingController _emailController = TextEditingController();
  UserType _role = UserType.SHOP_ADMIN;
  final RxnString _error = RxnString();
  final RxBool _isSending = false.obs;

  Future<void> _submit() async {
    _isSending(true);
    final String? error = await widget.controller.invite(email: _emailController.text, role: _role);
    _isSending(false);
    if (error != null) {
      _error.value = error;
      return;
    }
    Get.back();
    Get.snackbar('Invitation sent', '${_emailController.text.trim()} has been invited as ${_role.label}.');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invite a team member'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<UserType>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: kInvitableRoles
                  .map((role) => DropdownMenuItem(value: role, child: Text(role.label)))
                  .toList(),
              onChanged: (role) => setState(() => _role = role ?? _role),
            ),
            Obx(() => _error.value == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(_error.value!, style: const TextStyle(color: AppSemanticColors.danger)),
                  )),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        Obx(() => FilledButton(
              onPressed: _isSending.value ? null : _submit,
              child: _isSending.value
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Send invite'),
            )),
      ],
    );
  }
}
