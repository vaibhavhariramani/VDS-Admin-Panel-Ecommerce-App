import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/Permission.dart';
import '../../../models/Users.dart';
import '../../../themes/app_theme.dart';
import 'permission_catalog.dart';
import 'team_controller.dart';

/// Edits a user's explicit `Users/{uid}.permissions` override. Before this
/// screen existed, that field could only ever be set by hand in the
/// Firestore console — [kDefaultPermissionsByRole] (the role fallback) was
/// the only permission source any UI ever exercised. See
/// docs/architecture/CURRENT_ARCHITECTURE.md.
class PermissionsDialog extends StatefulWidget {
  final Users user;
  final TeamController controller;

  const PermissionsDialog({Key? key, required this.user, required this.controller}) : super(key: key);

  @override
  State<PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<PermissionsDialog> {
  late Set<String> _selected = Set.of(widget.user.effectivePermissions);
  final RxBool _isSaving = false.obs;

  bool get _hasFullAccess => _selected.contains(Permission.platformFullAccess);

  Future<void> _save() async {
    _isSaving(true);
    // An explicit override always replaces the role default, even if it
    // happens to be identical to it — that's the documented meaning of
    // Users.permissions (see the model). Saving an empty set is treated as
    // "reset to role default" by the service layer, not "revoke everything".
    final bool ok = await widget.controller.updatePermissions(widget.user.id!, _selected);
    _isSaving(false);
    if (ok) {
      Get.back();
      Get.snackbar('Permissions updated', '${widget.user.fullname ?? 'This user'}\'s access has been saved.');
    } else {
      Get.snackbar('Could not save permissions', 'Please try again.');
    }
  }

  Future<void> _resetToRoleDefault() async {
    _isSaving(true);
    final bool ok = await widget.controller.updatePermissions(widget.user.id!, null);
    _isSaving(false);
    if (ok) {
      Get.back();
      Get.snackbar('Reset', 'Now using the ${widget.user.roleLabel} default permissions.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<PermissionCatalogEntry>>{};
    for (final entry in kPermissionCatalog) {
      groups.putIfAbsent(entry.group, () => []).add(entry);
    }
    final bool hasOverride = widget.user.permissions != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.fullname?.isNotEmpty == true ? widget.user.fullname! : (widget.user.email ?? 'User'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasOverride
                        ? '${widget.user.roleLabel} — custom permissions'
                        : '${widget.user.roleLabel} — using role defaults',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: groups.entries.map((group) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
                          child: Text(
                            group.key,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.grey, fontSize: 12),
                          ),
                        ),
                        ...group.value.map((entry) => CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(entry.label),
                              value: _hasFullAccess && entry.value != Permission.platformFullAccess
                                  ? true
                                  : _selected.contains(entry.value),
                              onChanged: _hasFullAccess && entry.value != Permission.platformFullAccess
                                  ? null
                                  : (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _selected.add(entry.value);
                                        } else {
                                          _selected.remove(entry.value);
                                        }
                                      });
                                    },
                            )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Obx(() => Row(
                    children: [
                      if (hasOverride)
                        TextButton(
                          onPressed: _isSaving.value ? null : _resetToRoleDefault,
                          child: const Text('Reset to role default'),
                        ),
                      const Spacer(),
                      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton(
                        onPressed: _isSaving.value ? null : _save,
                        child: _isSaving.value
                            ? const SizedBox(
                                width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Save'),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
