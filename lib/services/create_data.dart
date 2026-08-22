import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import 'auth_service.dart';
import 'fetch_data.dart';

class CreateService extends GetxService {
  static CreateService get to => Get.find<CreateService>();
  final FirebaseFirestore Collection = FirebaseFirestore.instance;

  Future<bool> CreateNewGreenProduct({
    required String sku,
    required String img_token,
    required String product_name,
    required String shopid,
    required String currency_type,
    required double price,
    required double offer_price,
    required var offer_ends_on,
    required var offer_available_from,
    required deal_type,
  }) async {
    if (!AuthService.to.isAuthenticated) {
      return false;
    }
    print('creating new Green Deal product');
    print('SKU $sku');
    print('Fresh Untill Date: $offer_ends_on');
    print('Visible on Mobile App: $offer_available_from');
    print("Shop ID: $shopid");
    print("updted image url $img_token");
    print("product_name: $product_name");
    print("currency_type: $currency_type");
    try {
      final hierarchy = await FetchService.to.fetchShopHierarchy(shopid);
      await Collection.collection('Products').doc(sku).set({
        'barcode': sku,
        'image': img_token,
        'name': product_name,
        'price': price,
        'discount': offer_price,
        'shopId': shopid,
        'regionId': hierarchy.regionId,
        'Country': hierarchy.country,
        'currencyType': currency_type,
        'dealType': deal_type is Enum ? deal_type.name : deal_type.toString(),
        'availableFrom': _toTimestamp(offer_available_from),
        'expiresOn': _toTimestamp(offer_ends_on),
        'isPublished': true,
        'createdOn': Timestamp.now(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error creating green deal product: $e');
      return false;
    }
  }

  Timestamp? _toTimestamp(dynamic value) {
    if (value is DateTime) return Timestamp.fromDate(value);
    if (value is Timestamp) return value;
    return null;
  }
}
