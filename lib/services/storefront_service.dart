import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../models/Product.dart';
import '../models/storefront/storefront_config.dart';
import 'auth_service.dart';
import 'fetch_data.dart';

/// A store code must be URL-safe, reasonably short, and can't collide with
/// a route the platform itself might use.
const List<String> reservedStoreCodes = [
  'admin', 'api', 'app', 'store', 'stores', 'shop', 'shops', 'preview',
  'help', 'about', 'contact', 'login', 'signup', 'www', 'static', 'assets',
];

final RegExp _storeCodePattern = RegExp(r'^[a-z0-9](?:[a-z0-9-]{1,38}[a-z0-9])?$');

/// Reads/writes the Storefront Configuration Manager's draft/published
/// documents and the store-code uniqueness reservation. Direct Firestore
/// access, no repository layer - same style as DataService/UpdateService/
/// FetchService in this codebase.
class StorefrontService extends GetxService {
  static StorefrontService get to => Get.find<StorefrontService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _storefrontDoc(String shopId, String state) =>
      _firestore.collection('Shops').doc(shopId).collection('Storefront').doc(state);

  Future<StorefrontConfig> fetchDraft(String shopId) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _storefrontDoc(shopId, 'draft').get();
    return StorefrontConfig.fromJson(snap.data());
  }

  Future<StorefrontConfig> fetchPublished(String shopId) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _storefrontDoc(shopId, 'published').get();
    return StorefrontConfig.fromJson(snap.data());
  }

  Future<bool> saveDraft(String shopId, StorefrontConfig config) async {
    try {
      await _storefrontDoc(shopId, 'draft').set({
        ...config.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': AuthService.to.user.value?.id,
      });
      return true;
    } catch (e) {
      print('Error saving storefront draft for $shopId: $e');
      return false;
    }
  }

  /// Snapshots the current draft onto `published` - the Client App only
  /// ever reads `published`, so nothing goes live until this runs.
  Future<bool> publish(String shopId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> draftSnap =
          await _storefrontDoc(shopId, 'draft').get();
      if (!draftSnap.exists) return false;
      await _storefrontDoc(shopId, 'published').set({
        ...draftSnap.data()!,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': AuthService.to.user.value?.id,
      });
      return true;
    } catch (e) {
      print('Error publishing storefront for $shopId: $e');
      return false;
    }
  }

  /// Products a Featured Products / Product Grid / Product Carousel picker
  /// can offer - reuses the shop's existing product fetch, no duplicate
  /// query logic.
  Future<List<Product>> fetchPickableProducts(String shopId) =>
      FetchService.to.fetchAllProductsByShop(shopId);

  /// There's no dedicated Category collection in real use in this app
  /// (`Product.category` is free text) - so "categories" for the Category
  /// Grid picker are the distinct category strings already on this shop's
  /// own products.
  Future<List<String>> fetchDistinctCategories(String shopId) async {
    final List<Product> products = await fetchPickableProducts(shopId);
    final Set<String> categories = {
      for (final Product p in products)
        if ((p.category as String?)?.trim().isNotEmpty ?? false) p.category as String,
    };
    final List<String> sorted = categories.toList()..sort();
    return sorted;
  }

  String slugify(String input) {
    final String lower = input.trim().toLowerCase();
    final String replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final String trimmed = replaced.replaceAll(RegExp(r'^-+|-+$'), '');
    return trimmed;
  }

  String? validateStoreCode(String code) {
    if (code.isEmpty) return 'Store code cannot be empty.';
    if (code.length < 3) return 'Store code must be at least 3 characters.';
    if (code.length > 40) return 'Store code must be under 40 characters.';
    if (!_storeCodePattern.hasMatch(code)) {
      return 'Only lowercase letters, numbers, and single hyphens are allowed.';
    }
    if (reservedStoreCodes.contains(code)) return '"$code" is reserved.';
    return null;
  }

  Future<bool> isStoreCodeAvailable(String code) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _firestore.collection('StoreCodes').doc(code).get();
    return !snap.exists;
  }

  /// Atomically releases the shop's previous code (if any) and claims the
  /// new one, so two shops can never end up holding the same slug even
  /// under concurrent requests.
  Future<String?> claimStoreCode(String shopId, String newCode) async {
    final String? validationError = validateStoreCode(newCode);
    if (validationError != null) return validationError;
    try {
      await _firestore.runTransaction((Transaction tx) async {
        final DocumentReference<Map<String, dynamic>> newCodeRef =
            _firestore.collection('StoreCodes').doc(newCode);
        final DocumentReference<Map<String, dynamic>> shopRef =
            _firestore.collection('Shops').doc(shopId);

        final DocumentSnapshot<Map<String, dynamic>> newCodeSnap = await tx.get(newCodeRef);
        if (newCodeSnap.exists) {
          throw StateError('That store code is already taken.');
        }
        final DocumentSnapshot<Map<String, dynamic>> shopSnap = await tx.get(shopRef);
        final String? oldCode = shopSnap.data()?['storeCode']?.toString();

        tx.set(newCodeRef, {'shopId': shopId});
        tx.update(shopRef, {'storeCode': newCode});
        if (oldCode != null && oldCode.isNotEmpty && oldCode != newCode) {
          tx.delete(_firestore.collection('StoreCodes').doc(oldCode));
        }
      });
      return null;
    } on StateError catch (e) {
      return e.message;
    } catch (e) {
      print('Error claiming store code $newCode for $shopId: $e');
      return 'Could not claim that store code. Please try again.';
    }
  }
}
