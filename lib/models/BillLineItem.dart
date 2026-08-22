import 'package:get/get.dart';

/// A single line item on an in-progress bill/invoice. `productId` is null
/// for custom (non-catalog) items added manually.
class BillLineItem {
  final String? productId;
  final String name;
  final double price;
  final String? imageUrl;
  final RxInt quantity;

  BillLineItem({
    this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    int quantity = 1,
  }) : quantity = quantity.obs;

  double get lineTotal => price * quantity.value;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'price': price,
        'quantity': quantity.value,
        'lineTotal': lineTotal,
      };
}
