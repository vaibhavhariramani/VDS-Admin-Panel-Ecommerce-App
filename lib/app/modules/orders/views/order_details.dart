import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../constants/order_status.dart';
import '../../../../models/Orders.dart';
import '../../../../services/fetch_data.dart';
import 'items_details.dart';

class OrderDetails extends StatefulWidget {
  // Optional fast-path: the Orders table already has this object in memory
  // and passes it as the route's `arguments`, so opening details from the
  // table doesn't need an extra Firestore round trip. A direct deep link
  // or a page refresh won't have arguments though - see _loadOrder below,
  // which falls back to fetching by the :orderId route parameter.
  final Orders? mp;
  const OrderDetails({Key? key, this.mp}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  Orders? _order;
  bool _loading = true;
  String? _loadError;
  late final Stream<QuerySnapshot> _itemsStream;
  String? status;
  DateFormat format = DateFormat.yMMMMd('en_US');
  DateFormat time = DateFormat.jm();
  String? delivery;

  /// DropdownButton requires `value` to exactly match one of `items`, or it
  /// throws. An order can carry a status string that predates this
  /// canonical list (e.g. from before the status vocabulary was unified
  /// across apps) — folding the order's actual status into the list when
  /// it's unrecognized keeps the dropdown from crashing and still lets the
  /// admin move it to a known status.
  List<String> get _statusOptions {
    if (status != null && !OrderStatus.all.contains(status)) {
      return [status!, ...OrderStatus.all];
    }
    return OrderStatus.all;
  }

  // Safe numeric getters
  double get totalAmount {
    final v = _order?.totalAmount;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  double get deliveryCharges {
    final v = _order?.deliveryCharges;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  double get discount {
    final v = _order?.discount;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  // Safe date parser
  DateTime? parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) return DateTime.fromMicrosecondsSinceEpoch(dateValue);
    if (dateValue is String) {
      final asInt = int.tryParse(dateValue);
      if (asInt != null) return DateTime.fromMicrosecondsSinceEpoch(asInt);
      return DateTime.tryParse(dateValue);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.rootDelegate.arguments();
    final Orders? preloaded = args is Orders ? args : widget.mp;
    if (preloaded != null) {
      _applyOrder(preloaded);
      _loading = false;
    } else {
      _loadOrder();
    }
  }

  /// Sets every piece of state derived from the resolved order in one
  /// place, so the fast (arguments) path and the fetch-by-id fallback
  /// path can't drift from each other.
  void _applyOrder(Orders order) {
    _order = order;
    // Pre-selects the currently-assigned rider's radio button below —
    // this used to read deliveryPersonPhoto (an image URL), which never
    // matched an Employee doc id, so the picker never showed a selection
    // even when a rider was already assigned.
    status = order.status;
    delivery = order.riderId;
    // Items are always written with `orderID` set to the order's own
    // document id (see the client app's checkout code) - querying by that
    // directly instead of the redundant `cartId`/`CartItemsId` field is
    // both simpler and doesn't depend on a legacy/optional field staying
    // in sync.
    final String orderId = order.orderId;
    _itemsStream = orderId.isEmpty
        ? const Stream<QuerySnapshot>.empty()
        : FetchService.to.orderItems(orderId);
  }

  /// Deep-link / page-refresh fallback: resolves the order from the
  /// `:orderId` route parameter when it wasn't handed over via arguments.
  Future<void> _loadOrder() async {
    final String? orderId = Get.rootDelegate.parameters['orderId'];
    if (orderId == null || orderId.isEmpty) {
      setState(() {
        _loading = false;
        _loadError = 'No order id in the URL.';
      });
      return;
    }
    final Orders? fetched = await FetchService.to.fetchOrderById(orderId);
    if (!mounted) return;
    setState(() {
      if (fetched != null) {
        _applyOrder(fetched);
      } else {
        _loadError = 'Order not found.';
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(child: Text(_loadError ?? 'Order not found.')),
      );
    }
    final Orders order = _order!;
    final deliveryDate = parseDate(order.deliveryDate);
    final deliveryTime = parseDate(order.deliveryTime);
    return Scaffold(
        backgroundColor: Color(0xffebebeb),
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          elevation: 0,
          // title: Text(
          //   widget.mp['phone'],
          //   maxLines: 1,
          //   overflow: TextOverflow.ellipsis,
          // ),
          title: Row(
            children: [
              Text(
                order.customerNumber?.toString() ?? '',
                style: TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                width: 10,
              ),
              DropdownButton(
                dropdownColor: Colors.blueGrey,
                value: status,
                icon:
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                iconSize: 24,
                elevation: 16,
                underline: Container(),
                hint: Text('Status'),
                style: TextStyle(color: Colors.white, fontSize: 16),
                items: _statusOptions.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(OrderStatus.label(value)),
                  );
                }).toList(),
                onChanged: _update,
              ),
            ],
          ),
        ),
        body: ListView(
          children: [
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      Card(
                        elevation: 0,
                        child: Column(
                          children: [
                            const ListTile(
                              title: Text(
                                'Customer Details',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                  child: Icon(Icons.person_outline)),
                              title: Text('${order.customerName}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text(
                                '${order.customerNumber}',
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.local_shipping_outlined),
                              title: Text('Shipping Address',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text(
                                '${order.Address}',
                              ),
                            ),
                            SizedBox(height: 10)
                          ],
                        ),
                      ),
                      Card(
                        elevation: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const ListTile(
                              title: Text(
                                'Price Details',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            CustomTile(
                                title: 'Total Cost',
                                tail: '₹${totalAmount.toStringAsFixed(2)}',
                                titlestyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    fontSize: 16),
                                tailstyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                    fontSize: 16)),
                            CustomTile(
                                title: 'Delivery Charge',
                                tail: '₹${deliveryCharges.toStringAsFixed(2)}',
                                titlestyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    fontSize: 16),
                                tailstyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                    fontSize: 16)),
                            CustomTile(
                                title: 'Sub Total',
                                tail:
                                    '₹${(totalAmount + deliveryCharges).toStringAsFixed(2)}',
                                titlestyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    fontSize: 16),
                                tailstyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                    fontSize: 16)),
                            CustomTile(
                                title: 'Discount',
                                tail:
                                    '${totalAmount > 0 ? ((discount / totalAmount) * 100).floor() : 0}% OFF',
                                titlestyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    fontSize: 16),
                                tailstyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff6fb840),
                                    fontSize: 16)),
                            CustomTile(
                                title: 'Total Saving',
                                tail: '- ₹${discount.toStringAsFixed(2)}',
                                titlestyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    fontSize: 16),
                                tailstyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff6fb840),
                                    fontSize: 16)),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Order Total:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        'including all taxes',
                                        style: TextStyle(
                                          color:
                                              Color.fromRGBO(112, 112, 112, 1),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "₹${(totalAmount + deliveryCharges - discount).toStringAsFixed(2)}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              const ListTile(
                                title: Text(
                                  'Booking Details',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              ListTile(
                                title: Text('${order.orderId}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: Text.rich(TextSpan(
                                    text:deliveryDate != null ? format.format(deliveryDate) : '',
                                    style: TextStyle(),
                                    children: [TextSpan(text: deliveryTime != null ? '   ${time.format(deliveryTime)}' : '')],)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Container(
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      border:
                                          Border.all(color: Colors.black26)),
                                  child: Builder(builder: (context) {
                                    // Hardcoded black text/icon used to go
                                    // invisible against this Card's dark-mode
                                    // background (the Card follows the theme;
                                    // this text didn't) - follow the theme's
                                    // brightness instead.
                                    final bool isDark =
                                        Theme.of(context).brightness ==
                                            Brightness.dark;
                                    final Color textColor =
                                        isDark ? Colors.white : Colors.black;
                                    return DropdownButton(
                                      value: status,
                                      icon: Icon(Icons.keyboard_arrow_down,
                                          color: textColor),
                                      iconSize: 24,
                                      elevation: 16,
                                      isExpanded: true,
                                      underline: Container(),
                                      hint: Text('Status'),
                                      style: TextStyle(color: textColor),
                                      items: _statusOptions.map((value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(OrderStatus.label(value)),
                                        );
                                      }).toList(),
                                      onChanged: _update,
                                    );
                                  }),
                                ),
                              ),
                              SizedBox(height: 10)
                            ],
                          ),
                        ),
                      ],
                    )),
                Expanded(flex: 1, child: Container()),
              ],
            ),
            SizedBox(height: 10),
            Card(
              elevation: 0,
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Item Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _itemsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Could not load items: ${snapshot.error}'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final int itemCount = snapshot.data?.docs.length ?? 0;
                      if (itemCount == 0) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No items found for this order.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: itemCount,
                          itemBuilder: (BuildContext context, int index) {
                            Map<String, dynamic> data =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return ItemsDetails(
                              data: data,
                            );
                          });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'DeliveryBoy Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FetchService.to.employee(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              'Could not load delivery boys: ${snapshot.error}'),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No delivery staff found.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, dynamic> data =
                              docs[index].data() as Map<String, dynamic>;
                          final String? image = data['image']?.toString();
                          return ListTile(
                            leading: Container(
                                width: 60,
                                height: 60,
                                child: (image != null && image.isNotEmpty)
                                    ? Image.network(
                                        image,
                                        errorBuilder: (context, error, stack) =>
                                            const Icon(Icons.person, size: 40),
                                      )
                                    : const Icon(Icons.person, size: 40)),
                            title: Text('${data['name']}'),
                            subtitle: Text('${data['phone']}'),
                            trailing: Radio(
                              groupValue: delivery,
                              value: docs[index].id,
                              onChanged: (value) {
                                _deliveryBoy(docs[index]);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }

  void _update(String? value) async {
    // Real customer orders live in OnlineOrders (see fetch_data.dart) —
    // this used to write to the unrelated legacy `Orders` collection, so
    // status changes made here never reached the order the customer or
    // the delivery app actually reads.
    CollectionReference referencer =
        FirebaseFirestore.instance.collection('OnlineOrders');
    try {
      await referencer.doc(_order?.orderId).update({
        'status': value,
      });
      setState(() {
        status = value;
      });
    } catch (e) {}
  }

  Future _deliveryBoy(DocumentSnapshot snapshot) async {
    CollectionReference referencer =
        FirebaseFirestore.instance.collection('OnlineOrders');
    try {
      // Assigning a rider moves the order to "rider_assigned", not
      // straight to "picked_up" — pickup is a separate action the rider
      // confirms from the Delivery app once they're actually at the shop.
      await referencer.doc(_order?.orderId).update({
        'riderId': snapshot.id,
        'riderName': snapshot['name'],
        'riderPhone': snapshot['phone'],
        'status': OrderStatus.riderAssigned,
      });
      setState(() {
        delivery = snapshot.id;
        status = OrderStatus.riderAssigned;
      });
    } catch (e) {}
  }
}

class CustomTile extends StatelessWidget {
  final String title;
  final String tail;
  final TextStyle titlestyle;
  final TextStyle tailstyle;
  CustomTile(
      {required this.title,
      required this.tail,
      required this.titlestyle,
      required this.tailstyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 12, right: 12, top: 12),
      child: Row(
        children: [
          Expanded(
            child: Align(
              child: Text(
                '$title',
                style: titlestyle,
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
          Expanded(
            child: Align(
              child: Text(
                '$tail',
                style: tailstyle,
              ),
              alignment: Alignment.centerRight,
            ),
          )
        ],
      ),
    );
  }
}
