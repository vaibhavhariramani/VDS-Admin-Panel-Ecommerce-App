import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../widgets/components/animated_submit_button.dart';
import '../../../widgets/components/form_input_field.dart';
import '../../../widgets/components/labled_textfield.dart';
import '../controllers/help_controller.dart';

class HelpView extends GetView<HelpController> {
  const HelpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQs'),
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
                'Customer-facing FAQs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'These questions and answers are shown to customers in the client app.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).disabledColor),
              ),
              const SizedBox(height: 20),
              _buildForm(context),
              const SizedBox(height: 30),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.faqs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No FAQs yet. Add your first one above.',
                      style: TextStyle(color: Theme.of(context).disabledColor),
                    ),
                  );
                }
                return Column(
                  children: controller.faqs
                      .map((faq) => _buildFAQTile(context, faq))
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ReactiveFormBuilder(
          form: () => controller.faqForm,
          builder: (context, form, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.editingId.value.isEmpty
                        ? 'Add a new FAQ'
                        : 'Editing FAQ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 12),
                LabeledTextField(
                  label: 'Question',
                  isRequired: true,
                  textfield: FormTextInputField<String>(
                    controlName: 'question',
                    hintText: 'e.g. How do I track my order?',
                    onEditingComplete: () => controller.faqForm.focus('answer'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    validationMessage: (control) => "Question can't be empty.",
                  ),
                ),
                LabeledTextField(
                  label: 'Answer',
                  isRequired: true,
                  textfield: FormTextInputField<String>(
                    controlName: 'answer',
                    hintText: 'Write the answer customers will see',
                    onEditingComplete: () => controller.faqForm.unfocus(),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    validationMessage: (control) => "Answer can't be empty.",
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Obx(
                      () => AnimatedSubmitButton(
                        buttonText: controller.editingId.value.isEmpty
                            ? 'Add FAQ'
                            : 'Save Changes',
                        width: 160,
                        onPressed: controller.isSaving.value ? null : controller.save,
                      ),
                    ),
                    Obx(
                      () => Visibility(
                        visible: controller.editingId.value.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: TextButton(
                            onPressed: controller.startCreating,
                            child: const Text('Cancel'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFAQTile(BuildContext context, Map<String, dynamic> faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(faq['question']?.toString() ?? ''),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(faq['answer']?.toString() ?? ''),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => controller.startEditing(faq),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () => controller.deleteFAQ(faq['id'].toString()),
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                label: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
