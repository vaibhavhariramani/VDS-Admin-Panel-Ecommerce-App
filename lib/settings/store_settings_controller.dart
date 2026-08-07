import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreSettingsController {
  StoreSettingsController._();

  static const _docPath = 'Settings/store';

  static final ValueNotifier<String> storeName =
      ValueNotifier<String>('Vishal Departmental Store');
  static final ValueNotifier<String> storeAddress =
      ValueNotifier<String>('A-126, Murlipura Scheme, Murlipura, Jaipur, Rajasthan');

  static Future<void> initialize() async {
    try {
      final doc = await FirebaseFirestore.instance.doc(_docPath).get();
      if (doc.exists) {
        final data = doc.data();
        if (data?['name'] != null) storeName.value = data!['name'];
        if (data?['address'] != null) storeAddress.value = data!['address'];
      }
    } catch (e) {
      // Keep defaults if the doc doesn't exist yet or read fails.
    }
  }

  static Future<void> save({required String name, required String address}) async {
    await FirebaseFirestore.instance.doc(_docPath).set({
      'name': name,
      'address': address,
    });
    storeName.value = name;
    storeAddress.value = address;
  }
}
