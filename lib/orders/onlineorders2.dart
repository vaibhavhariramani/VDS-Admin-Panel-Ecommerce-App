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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Order Onlines'),
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
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Row(
                            children: <Widget>[
                              const Expanded(flex: 1, child: Icon(Icons.search)),
                              Expanded(
                                flex: 9,
                                child: TextField(
                                  style: const TextStyle(color: Colors.black),
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
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Colors.black26)),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: dataProvider.regions(null),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return DropdownButton(
                                value: pincode,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                iconSize: 24,
                                elevation: 16,
                                isExpanded: true,
                                underline: Container(),
                                hint: const Text('Pincode'),
                                style: const TextStyle(color: Colors.black),
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
                                                0.2,
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(),
                                              imageUrl: snapshot
                                                  .data!.docs[index]['image'],
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
                                                    text: snapshot.data!
                                                        .docs[index]['booking']
                                                        .toString(),
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ])),
                                              subtitle: Text.rich(TextSpan(
                                                  text:
                                                      '${format.format(DateTime.fromMicrosecondsSinceEpoch(snapshot.data!.docs[index]['booking']))}   ',
                                                  style: GoogleFonts.poppins(),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          time.format(DateTime.fromMicrosecondsSinceEpoch(snapshot.data!.docs[index]['booking'])),
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
                                                      '₹${snapshot.data!.docs[index]['total']}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                                                color: snapshot.data!.docs[index]
                                                                            [
                                                                            'status'] ==
                                                                        'Order Placed'
                                                                    ? Colors
                                                                        .blue
                                                                        .withOpacity(
                                                                            0.1)
                                                                    : snapshot.data!.docs[index]['status'] ==
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
                                                          '${snapshot.data!.docs[index]['status']}',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 14,
                                                                  color: snapshot.data!.docs[index]
                                                                              [
                                                                              'status'] ==
                                                                          'Order Placed'
                                                                      ? Colors
                                                                          .blue
                                                                      : snapshot.data!.docs[index]['status'] ==
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
                                    snapshot.data!.docs[index].data()
                                        as Map<String, dynamic>;
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
                return const Center(child: CircularProgressIndicator());
              }),
        ],
      ),
    );
  }
}
