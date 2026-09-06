import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../routes/app_pages.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Applies to this browser only.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).disabledColor),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Obx(
                  () => SwitchListTile(
                    title: const Text('Dark mode'),
                    subtitle: Text(
                      controller.isDarkMode.value ? 'On' : 'Off',
                    ),
                    secondary: Icon(
                      controller.isDarkMode.value
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                    ),
                    value: controller.isDarkMode.value,
                    onChanged: controller.toggleDarkMode,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Team',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Invite staff and manage what each person can access.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).disabledColor),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Team & Permissions'),
                  subtitle: const Text('View team members, invite new staff, edit permissions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.toNamed(Routes.TEAM),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
