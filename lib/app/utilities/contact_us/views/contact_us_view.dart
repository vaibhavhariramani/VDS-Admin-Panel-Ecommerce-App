import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/Shop.dart';
import '../../../widgets/components/animated_submit_button.dart';
import '../../../widgets/components/form_input_field.dart';
import '../../../widgets/components/labled_textfield.dart';
import '../controllers/contact_us_controller.dart';

class ContactUsView extends GetView<ContactUsController> {
  ContactUsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send a notification to your customers',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Messages appear in the client app\'s notification feed.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).disabledColor),
              ),
              const SizedBox(height: 20),
              ReactiveFormBuilder(
                form: () => controller.composeForm,
                builder: (context, form, child) => _buildForm(context),
              ),
              const SizedBox(height: 40),
              Text(
                'Recently sent',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isLoadingHistory.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.notificationHistory.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No notifications sent yet.',
                      style: TextStyle(color: Theme.of(context).disabledColor),
                    ),
                  );
                }
                return Column(
                  children: controller.notificationHistory
                      .map((n) => _buildHistoryTile(context, n))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledTextField(
          label: 'Title',
          isRequired: true,
          textfield: FormTextInputField<String>(
            controlName: 'title',
            hintText: 'e.g. Weekend Sale!',
            onEditingComplete: () => controller.composeForm.focus('body'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            validationMessage: (control) => "Title can't be empty.",
          ),
        ),
        LabeledTextField(
          label: 'Message',
          isRequired: true,
          textfield: FormTextInputField<String>(
            controlName: 'body',
            hintText: 'What do you want to tell your customers?',
            onEditingComplete: () => controller.composeForm.unfocus(),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            validationMessage: (control) => "Message can't be empty.",
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (!controller.canTargetMultipleShops) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send to',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Shops'),
                    selected: controller.sendToAllShops.value,
                    onSelected: (_) => controller.sendToAllShops(true),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Specific Shop'),
                    selected: !controller.sendToAllShops.value,
                    onSelected: (_) => controller.sendToAllShops(false),
                  ),
                ],
              ),
              if (!controller.sendToAllShops.value) ...[
                const SizedBox(height: 12),
                controller.isLoadingShops.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : DropdownButtonFormField<Shop>(
                        value: controller.selectedShop.value,
                        isExpanded: true,
                        hint: const Text('Choose a shop'),
                        items: controller.availableShops
                            .map(
                              (Shop s) => DropdownMenuItem<Shop>(
                                value: s,
                                child: Text(s.name ?? s.id ?? 'Unnamed shop'),
                              ),
                            )
                            .toList(),
                        onChanged: (Shop? s) => controller.selectedShop.value = s,
                      ),
              ],
            ],
          );
        }),
        const SizedBox(height: 24),
        Obx(
          () => AnimatedSubmitButton(
            buttonText: controller.isSending.value ? 'Sending...' : 'Send Notification',
            width: 220,
            onPressed: controller.isSending.value ? null : controller.send,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTile(BuildContext context, Map<String, dynamic> n) {
    final String targetLabel = n['targetType'] == 'shop'
        ? (n['targetShopName']?.toString() ?? 'One shop')
        : 'All Shops';
    final dynamic createdOn = n['createdOn'];
    String dateLabel = '';
    try {
      if (createdOn != null) {
        final DateTime dt = (createdOn as dynamic).toDate() as DateTime;
        dateLabel = '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(n['title']?.toString() ?? ''),
        subtitle: Text(n['body']?.toString() ?? ''),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(targetLabel, style: const TextStyle(fontSize: 12)),
            if (dateLabel.isNotEmpty)
              Text(
                dateLabel,
                style: TextStyle(fontSize: 11, color: Theme.of(context).disabledColor),
              ),
          ],
        ),
      ),
    );
  }
}
