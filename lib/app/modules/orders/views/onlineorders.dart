import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../constants/order_status.dart';
import '../../../../models/Orders.dart';
import '../../../../services/fetch_data.dart';
import 'order_details.dart';

class OnlineOrders extends StatefulWidget {
  const OnlineOrders({Key? key}) : super(key: key);

  @override
  _OnlineOrdersState createState() => _OnlineOrdersState();
}

class _OnlineOrdersState extends State<OnlineOrders> {
  dynamic pincode;
  String? search;

  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.placed:
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
      case OrderStatus.readyForPickup:
      case OrderStatus.riderAssigned:
      case OrderStatus.pickedUp:
      case OrderStatus.outForDelivery:
        return Colors.amber.shade800;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.delivered:
        return Color(0xff32CC34);
      default:
        return Color(0xff32CC34);
    }
  }
  late String url;
  DateFormat format = DateFormat.yMMMMd('en_US');
  DateFormat time = DateFormat.jm();

  /// `dateOfOrder` is consistently a Firestore Timestamp; `booking` is not
  /// (int epoch-micros on older orders, Timestamp on newer ones), so it's
  /// only used as a last resort here.
  DateTime? _orderDate(QueryDocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final dynamic dateOfOrder = data['dateOfOrder'];
    if (dateOfOrder is Timestamp) return dateOfOrder.toDate();
    final dynamic booking = data['booking'];
    if (booking is Timestamp) return booking.toDate();
    if (booking is int) return DateTime.fromMicrosecondsSinceEpoch(booking);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Order Onlines'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 32, top: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: MediaQuery.of(context).size.width < 1000 ? 7 : 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Row(
                            children: <Widget>[
                              Expanded(flex: 1, child: Icon(Icons.search)),
                              Expanded(
                                flex: 9,
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  cursorColor: Colors.deepPurple,
                                  onChanged: (v) {
                                    setState(() {});
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Search orders",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: MediaQuery.of(context).size.width < 1000 ? 3 : 2,
                    child: Container(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Colors.black26)),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FetchService.to.regions(null),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return DropdownButton(
                                value: pincode,
                                icon: Icon(Icons.keyboard_arrow_down),
                                iconSize: 24,
                                elevation: 16,
                                isExpanded: true,
                                underline: Container(),
                                hint: Text('Pincode'),
                                style: TextStyle(color: Colors.black),
                                onChanged: (v) {
                                  setState(() {
                                    pincode = v;
                                  });
                                },
                                items: snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data()! as Map<String, dynamic>;
                                  return DropdownMenuItem(
                                    value: data['pincode'].toString(),
                                    child: Text(data['pincode'].toString()),
                                  );
                                }).toList(),
                              );
                            } else {
                              return Text('Something went wrong');
                            }
                          }),
                    ),
                  ),
                  SizedBox(width: 8)
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream:
                  FetchService.to.OnlineOrders(search: search, filter: pincode),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // `booking` is stored inconsistently across documents (an
                  // int epoch-micros value on older orders, a Firestore
                  // Timestamp on newer ones), so ordering/formatting by it
                  // directly is unreliable and `DateTime.fromMicrosecondsSinceEpoch`
                  // outright crashes when it's a Timestamp. `dateOfOrder` is
                  // consistently a Timestamp, so sort/display use that
                  // (falling back to `booking` only if `dateOfOrder` is
                  // missing), client-side — sorting here also avoids
                  // depending on a Firestore composite index for `booking`.
                  final List<QueryDocumentSnapshot> docs =
                      snapshot.data!.docs.toList()
                        ..sort((a, b) {
                          final DateTime? da = _orderDate(a);
                          final DateTime? db = _orderDate(b);
                          if (da == null && db == null) return 0;
                          if (da == null) return 1;
                          if (db == null) return -1;
                          return db.compareTo(da);
                        });
                  return docs.length > 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final DateTime? orderDate = _orderDate(docs[index]);
                            return GestureDetector(
                              child: Card(
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                    Expanded(
                                        flex: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.15,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1,
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              imageUrl: docs[index]['image'],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 7,
                                        child: Column(
                                          children: [
                                            ListTile(
                                              title: Text.rich(
                                                  TextSpan(text: '', children: [
                                                TextSpan(
                                                    text: docs[index]['booking']
                                                        .toString(),
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ])),
                                              subtitle: Text.rich(TextSpan(
                                                  text: orderDate != null
                                                      ? '${format.format(orderDate)}   '
                                                      : '',
                                                  style: GoogleFonts.poppins(),
                                                  children: [
                                                    TextSpan(
                                                      text: orderDate != null
                                                          ? '${time.format(orderDate)}'
                                                          : '',
                                                    )
                                                  ])),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 8,
                                                    ),
                                                    child: Text(
                                                      '₹${docs[index]['total']}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 4,
                                                    ),
                                                    child: Builder(builder: (context) {
                                                      final String orderStatus =
                                                          '${docs[index]['status']}';
                                                      final Color statusColor =
                                                          _statusColor(orderStatus);
                                                      return Container(
                                                        decoration: BoxDecoration(
                                                            color: statusColor
                                                                .withOpacity(0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8)),
                                                        padding: EdgeInsets.all(4),
                                                        child: Text(
                                                          OrderStatus.label(
                                                              orderStatus),
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 14,
                                                                  color:
                                                                      statusColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))
                                  ])),
                              onTap: () {
                                Map<String, dynamic> mp =
                                    docs[index].data()
                                        as Map<String, dynamic>;
                                Orders orderDetails = Orders.fromJson(mp);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            OrderDetails(
                                              mp: orderDetails,
                                            )));
                              },
                            );
                          },
                        )
                      : Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  imageUrl:
                                      'https://firebasestorage.googleapis.com/v0/b/atus-kart.appspot.com/o/static%2Fbasket.png?alt=media&token=4ca7a331-90d3-4ce0-8113-0226e577085e',
                                  width: 120,
                                  height: 120),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8, top: 12),
                                child: Text('No items in your cart!',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 60, right: 60),
                                child: Text(
                                  "We are looking to provide our services for you",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                }
                return Center(child: CircularProgressIndicator());
              }),
        ],
      ),
    );
  }
}
