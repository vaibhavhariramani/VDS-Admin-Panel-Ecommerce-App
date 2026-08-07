import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vdsadmin/models/data_provider.dart';
import 'package:vdsadmin/orders/order_details.dart';

class Orders2 extends StatefulWidget {
  const Orders2({Key? key}) : super(key: key);

  @override
  _Orders2State createState() => _Orders2State();
}

class _Orders2State extends State<Orders2> {
  dynamic pincode;
  String? search;
  late String url;
  DateFormat format = DateFormat.yMMMMd('en_US');
  DateFormat time = DateFormat.jm();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xff23262b) : Colors.white;
    final borderColor = isDark ? Colors.white24 : Colors.black26;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedTextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff17191c) : const Color(0xffF5F6F8),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Order Onlines'),
        backgroundColor: const Color(0xffF3AB0D),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 32, left: 16, top: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: surfaceColor,
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
                              border: Border.all(color: borderColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Icon(Icons.search, color: textColor)),
                              Expanded(
                                flex: 9,
                                child: TextField(
                                  style: TextStyle(color: textColor),
                                  cursorColor: Colors.deepPurple,
                                  onChanged: (v) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Search orders",
                                    hintStyle: TextStyle(color: mutedTextColor),
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
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: borderColor)),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: dataProvider.regions(null),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return DropdownButton(
                                value: pincode,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: textColor),
                                iconSize: 24,
                                elevation: 16,
                                isExpanded: true,
                                underline: Container(),
                                hint: Text('Pincode',
                                    style: TextStyle(color: mutedTextColor)),
                                dropdownColor: surfaceColor,
                                style: TextStyle(color: textColor),
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
                              return const Text('Something went wrong');
                            }
                          }),
                    ),
                  ),
                  const SizedBox(width: 8)
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: dataProvider.orders(search: search, filter: pincode),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.docs.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final data = snapshot.data!.docs[index];
                            final name = (data.data() as Map<String, dynamic>)
                                        .containsKey('name') &&
                                    data['name'] != null &&
                                    data['name'].toString().isNotEmpty
                                ? data['name'].toString()
                                : 'Customer';
                            final address = (data.data()
                                            as Map<String, dynamic>)
                                        .containsKey('address') &&
                                    data['address'] != null
                                ? data['address'].toString()
                                : '';
                            return GestureDetector(
                              child: Card(
                                  color: surfaceColor,
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
                                                0.2,
                                            decoration: BoxDecoration(
                                                color: isDark
                                                    ? Colors.white12
                                                    : Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(),
                                              imageUrl: data['image'],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 7,
                                        child: Column(
                                          children: [
                                            ListTile(
                                              title: Text(
                                                name,
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: textColor),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (address.isNotEmpty)
                                                    Text(
                                                      address,
                                                      maxLines: 2,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style: GoogleFonts
                                                          .poppins(
                                                              color:
                                                                  mutedTextColor),
                                                    ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${format.format(DateTime.fromMicrosecondsSinceEpoch(data['booking']))}   ${time.format(DateTime.fromMicrosecondsSinceEpoch(data['booking']))}',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        color:
                                                            mutedTextColor),
                                                  ),
                                                ],
                                              ),
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
                                                      '₹${data['total']}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  textColor),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 4,
                                                    ),
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                color: data[
                                                                            'status'] ==
                                                                        'Order Placed'
                                                                    ? Colors
                                                                        .blue
                                                                        .withOpacity(
                                                                            0.1)
                                                                    : data['status'] ==
                                                                            'Order Progress'
                                                                        ? Colors
                                                                            .amber
                                                                            .withOpacity(
                                                                                0.1)
                                                                        : const Color(0xff32CC34).withOpacity(
                                                                            0.1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                        padding: const EdgeInsets.all(4),
                                                        child: Text(
                                                          '${data['status']}',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 14,
                                                                  color: data[
                                                                              'status'] ==
                                                                          'Order Placed'
                                                                      ? Colors
                                                                          .blue
                                                                      : data['status'] ==
                                                                              'Order Progress'
                                                                          ? Colors
                                                                              .amber
                                                                          : const Color(
                                                                              0xff32CC34),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))
                                  ])),
                              onTap: () {
                                Map<String, dynamic> mp =
                                    data.data() as Map<String, dynamic>;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            OrderDetails(
                                              mp: mp,
                                            )));
                              },
                            );
                          },
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  imageUrl:
                                      'https://firebasestorage.googleapis.com/v0/b/ecommerce-26b18.appspot.com/o/icon%2FVDS_no_image.png?alt=media&token=31e046b8-4665-4985-af21-f5ca990009b6',
                                  width: 120,
                                  height: 120),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, top: 12),
                                child: Text('No online orders yet',
                                    style: TextStyle(color: mutedTextColor)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 60, right: 60),
                                child: Text(
                                  "Orders placed by customers on the app will show up here",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                }
                return const Center(child: CircularProgressIndicator());
              }),
        ],
      ),
    );
  }
}
