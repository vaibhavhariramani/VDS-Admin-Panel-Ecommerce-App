import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  String orderId;
  String? _customerName;
  String? _customerNumber;
  double? _totalAmount;
  double? _discount;
  String? _CartItemsId;
  String? _status;
  String? _paymentMethod;
  String? _paymentStatus;
  String? _Status;
  String? _deliveryMethod;
  String? _Address;
  String? _deliveryDate;
  String? _deliveryTime;
  String? _deliveryCharges;
  String? _riderId;
  String? _deliveryPersonName;
  String? _deliveryPersonPhone;
  String? _deliveryPersonVehicle;
  String? _deliveryPersonVehicleNumber;
  DateTime? _dateOfOrder;
  String? _timeOfOrder;
  String? _pincode;

  Orders({
    required this.orderId,
    String? customerName,
    String? customerNumber,
    double? totalAmount,
    String? CartItemsId,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    String? Status,
    String? deliveryMethod,
    String? Address,
    String? deliveryDate,
    String? deliveryTime,
    String? deliveryCharges,
    String? riderId,
    String? deliveryPersonName,
    String? deliveryPersonPhone,
    String? deliveryPersonVehicle,
    String? deliveryPersonVehicleNumber,
    DateTime? dateOfOrder,
    String? timeOfOrder,
    String? pincode,
  }) {
    _customerName = customerName;
    _customerNumber = customerNumber;
    _totalAmount = totalAmount;
    _CartItemsId = CartItemsId;
    _status = status;
    _paymentMethod = paymentMethod;
    _paymentStatus = paymentStatus;
    _deliveryMethod = deliveryMethod;
    _Address = Address;
    _deliveryDate = deliveryDate;
    _deliveryTime = deliveryTime;
    _deliveryCharges = deliveryCharges;
    _riderId = riderId;
    _deliveryPersonName = deliveryPersonName;
    _deliveryPersonPhone = deliveryPersonPhone;
    _deliveryPersonVehicle = deliveryPersonVehicle;
    _deliveryPersonVehicleNumber = deliveryPersonVehicleNumber;
    _dateOfOrder = dateOfOrder;
    _timeOfOrder = timeOfOrder;
    _pincode = pincode;
  }

  get CartItemsId {
    return _CartItemsId;
  }

  get status {
    return _status;
  }

  get customerNumber {
    return _customerNumber;
  }

  get Address {
    return _Address;
  }

  get customerName {
    return _customerName;
  }

  get riderId {
    return _riderId;
  }

  get deliveryPersonName {
    return _deliveryPersonName;
  }

  get deliveryPersonPhone {
    return _deliveryPersonPhone;
  }

  /// Not yet populated — assigning a rider (see order_details.dart)
  /// currently denormalizes id/name/phone onto the order but not a photo.
  /// Callers already fall back to a placeholder avatar when this is null.
  get deliveryPersonPhoto {
    return null;
  }

  get deliveryDate {
    return _deliveryDate;
  }

  get totalAmount {
    return _totalAmount;
  }

  get deliveryCharges {
    return _deliveryCharges;
  }

  get discount {
    return _discount;
  }

  get deliveryTime {
    return _deliveryTime;
  }

  get dateOfOrder {
    return _dateOfOrder;
  }

  void printOrderDetails() {
    print('Order ID: $orderId');
    print('Customer Name: $_customerName');
    print('Total Amount: $_totalAmount');
    print('ItemsId: $CartItemsId');
  }

  

  static Orders fromJson(Map<String, dynamic> data) {
    Orders tempOrder = emptyOrder();
    // Firestore's integerValue deserializes to a Dart `int`, not `double` -
    // every real order in this collection stores `total` as an integer, so
    // a direct `_totalAmount = data['total']` assignment (a `double?`
    // field) threw a runtime TypeError on every single document. Since
    // that throw happened inside the caller's for-loop
    // (fetchOnlineOrdersUsingShopId), it silently emptied the *entire*
    // order list after the first document, not just that one order - the
    // Online Orders table was blank for every order, not just malformed
    // ones. `(x as num?)?.toDouble()` accepts either int or double.
    tempOrder.orderId = (data['id'] as String?) ?? '';
    tempOrder._customerName = data['name'];
    tempOrder._customerNumber = data['phone'];
    tempOrder._totalAmount = (data['total'] as num?)?.toDouble();
    tempOrder._CartItemsId = data['cartId'];
    tempOrder._status = data['status'];
    tempOrder._paymentMethod = data['paymentMethod'];
    tempOrder._paymentStatus = data['paymentStatus'];
    tempOrder._deliveryMethod = data['deliveryMethod'];
    tempOrder._Address = data['address'];
    tempOrder._deliveryDate = data['DateOfDelivery']?.toString();
    tempOrder._deliveryTime = data['DateOfDelivery']?.toString();
    // Also stored as a string on every real order ("0"), but be defensive
    // for the same reason as `total` above in case a future write ever
    // sends a number instead.
    tempOrder._deliveryCharges = data['deliveryCharges']?.toString();
    tempOrder._riderId = data['riderId'];
    tempOrder._deliveryPersonName = data['riderName'];
    tempOrder._deliveryPersonPhone = data['riderPhone'];
    tempOrder._deliveryPersonVehicle = 'deliveryPersonVehicle';
    tempOrder._deliveryPersonVehicleNumber = 'deliveryPersonVehicleNumber';
    // Legacy orders (pre-dating this platform's Firebase consolidation)
    // stored a `booking` field as a raw microseconds string instead of a
    // Firestore Timestamp; `dateOfOrder` itself has been a real Timestamp
    // on every order seen so far, but a bad cast here has the same
    // whole-list-empties-out blast radius as the `total` bug above, so
    // this is deliberately tolerant rather than assuming the type holds.
    final dynamic rawDate = data['dateOfOrder'];
    tempOrder._dateOfOrder = rawDate is Timestamp ? rawDate.toDate() : null;
    tempOrder._timeOfOrder = rawDate?.toString();
    tempOrder._pincode = data['pincode'];
    return tempOrder;
  }
}

Orders emptyOrder() {
  return Orders(
    orderId: '',
    customerName: '',
    customerNumber: '',
    totalAmount: 0,
    CartItemsId: '',
    status: '',
    paymentMethod: '',
    paymentStatus: '',
    Status: '',
    deliveryMethod: '',
    Address: '',
    deliveryDate: '',
    deliveryTime: '',
    deliveryCharges: '',
    riderId: '',
    deliveryPersonName: '',
    deliveryPersonPhone: '',
    deliveryPersonVehicle: '',
    deliveryPersonVehicleNumber: '',
    dateOfOrder: null,
    timeOfOrder: '',
    pincode: '',
  );
}
