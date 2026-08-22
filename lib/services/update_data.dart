import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

class UpdateService extends GetxService {
  static UpdateService get to => Get.find<UpdateService>();
  final FirebaseFirestore Collection = FirebaseFirestore.instance;

  Future<bool> deleteShop({
    required String shopId,
  }) async {
    try {
      await Collection.collection('Shops').doc(shopId).update({
        'isactive': false,
      });
      print('Shop $shopId marked inactive');
      return true;
    } catch (e) {
      print('Error deleting shop $shopId: $e');
      return false;
    }
  }

  /// Updates the fields the client app reads to render a shop's storefront
  /// (name, contact info, and branding: logo/banners/accent color).
  Future<bool> updateShopBranding({
    required String shopId,
    required String name,
    required String about,
    required String phoneNumber,
    required String address,
    required String? imgToken,
    required List<String> bannerUrls,
    required String? brandColor,
  }) async {
    try {
      await Collection.collection('Shops').doc(shopId).update({
        'name': name,
        'about': about,
        'phone_number': phoneNumber,
        'address': address,
        'imgToken': imgToken,
        'bannerUrls': bannerUrls,
        'brandColor': brandColor,
      });
      return true;
    } catch (e) {
      print('Error updating shop branding for $shopId: $e');
      return false;
    }
  }
}
