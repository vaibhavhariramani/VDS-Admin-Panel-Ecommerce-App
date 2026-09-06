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
    print("Converted snapshot data into Map");
    print(data);
    tempOrder.orderId = data['id'];
    tempOrder._customerName = data['name'];
    tempOrder._customerNumber = data['phone'];
    tempOrder._totalAmount = data['total'];
    tempOrder._CartItemsId = data['cartId'];
    tempOrder._status = data['status'];
    tempOrder._paymentMethod = data['paymentMethod'];
    tempOrder._paymentStatus = data['paymentStatus'];
    tempOrder._deliveryMethod = data['deliveryMethod'];
    tempOrder._Address = data['address'];
    tempOrder._deliveryDate = data['DateOfDelivery'].toString();
    tempOrder._deliveryTime = data['DateOfDelivery'].toString();
    tempOrder._deliveryCharges = data['deliveryCharges'];
    tempOrder._riderId = data['riderId'];
    tempOrder._deliveryPersonName = data['riderName'];
    tempOrder._deliveryPersonPhone = data['riderPhone'];
    tempOrder._deliveryPersonVehicle = 'deliveryPersonVehicle';
    tempOrder._deliveryPersonVehicleNumber = 'deliveryPersonVehicleNumber';
    tempOrder._dateOfOrder = (data['dateOfOrder']as Timestamp?)?.toDate();
    tempOrder._timeOfOrder = data['dateOfOrder'].toString();
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
