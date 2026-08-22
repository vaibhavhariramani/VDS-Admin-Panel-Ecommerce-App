import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/storefront/storefront_config.dart';
import '../../../modules/storefront/controllers/storefront_controller.dart';

/// Backs the Help page's customer-facing FAQ editor. FAQs live on the
/// shop's own `StorefrontConfig.faqs` (part of the same draft/publish
/// document as branding/homepage/etc.), so this delegates to the shared
/// `StorefrontController` instead of keeping a second, parallel
/// draft/shopId/Firestore round-trip: fetching+seeding a *second* blank
/// draft here (the previous version of this file did exactly that) meant
/// opening Help before ever opening Storefront would seed and immediately
/// publish a storefront with only FAQs on it — no branding, no homepage —
/// which is a real, live storefront a customer could land on. Going
/// through the one shared controller means FAQ edits always build on
/// whatever draft actually exists (rich defaults included) and reuse its
/// already-correct save/publish flow.
class HelpController extends GetxController {
  late final StorefrontController _storefront;

  final RxBool isSaving = false.obs;
  final RxList<Map<String, dynamic>> faqs = <Map<String, dynamic>>[].obs;

  final FormGroup faqForm = FormGroup({
    'question': FormControl<String>(validators: [Validators.required]),
    'answer': FormControl<String>(validators: [Validators.required]),
  });

  /// Non-null while editing an existing FAQ; null while composing a new one.
  final RxString editingId = ''.obs;

  RxBool get isLoading => _storefront.isLoading;

  @override
  void onInit() {
    super.onInit();
    _storefront = Get.isRegistered<StorefrontController>()
        ? Get.find<StorefrontController>()
        : Get.put(StorefrontController());
    ever(_storefront.draft, (StorefrontConfig config) => _syncFaqs(config));
    _syncFaqs(_storefront.draft.value);
  }

  void _syncFaqs(StorefrontConfig config) {
    faqs.assignAll(
      config.faqs.map((faq) => {'id': faq.id, 'question': faq.question, 'answer': faq.answer}),
    );
  }

  void startEditing(Map<String, dynamic> faq) {
    editingId.value = faq['id'].toString();
    faqForm.control('question').value = faq['question'];
    faqForm.control('answer').value = faq['answer'];
  }

  void startCreating() {
    editingId.value = '';
    faqForm.reset();
  }

  Future<void> save() async {
    if (faqForm.invalid) {
      faqForm.markAllAsTouched();
      return;
    }
    isSaving(true);
    final String question = faqForm.control('question').value.toString();
    final String answer = faqForm.control('answer').value.toString();
    final bool wasEditing = editingId.value.isNotEmpty;
    final String id = wasEditing ? editingId.value : 'faq_${DateTime.now().microsecondsSinceEpoch}';

    _storefront.saveFaq(StorefrontFaq(id: id, question: question, answer: answer));
    final bool success = await _storefront.saveDraft();
    if (success) await _storefront.publish();
    isSaving(false);

    if (success) {
      faqForm.reset();
      editingId.value = '';
      Get.snackbar(
        wasEditing ? 'FAQ Updated' : 'FAQ Added',
        'Published to your store’s customer app.',
        duration: const Duration(seconds: 4),
      );
    } else {
      Get.snackbar(
        'Failed to save',
        'Please try again.',
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> deleteFAQ(String id) async {
    _storefront.removeFaq(id);
    final bool success = await _storefront.saveDraft();
    if (success) await _storefront.publish();
    if (success) {
      Get.snackbar(
        'FAQ Deleted',
        'Removed from your customer app.',
        duration: const Duration(seconds: 4),
      );
    }
  }
}
