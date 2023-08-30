import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vdsadmin/models/data_provider.dart';
import 'package:vdsadmin/models/product_data.dart';
import 'package:vdsadmin/search/product_details.dart';

import '../billing/bill.dart';

class HomeGridProductList extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final bool navigatorDecider;
  List<ProductData> listOfProductsInBilling;
  HomeGridProductList(
      {Key? key,
      required this.snapshot,
      required this.navigatorDecider,
      required this.listOfProductsInBilling})
      : super(key: key);
  @override
  _HomeGridProductListState createState() => _HomeGridProductListState();
}

class _HomeGridProductListState extends State<HomeGridProductList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        elevation: 0,
        child: Column(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white10.withOpacity(0.95)),
              child: CachedNetworkImage(
                imageUrl: widget.snapshot.get('image'),
              ),
            ),
            ListTile(
              title: Text(
                '${widget.snapshot.get('name')}',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('Price for ${widget.snapshot.get('quantity')}',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.normal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4)),
                padding: EdgeInsets.all(6),
                child: Text(
                  '${widget.snapshot.get('quantity')}',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '₹${widget.snapshot.get('selling')}',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '₹${widget.snapshot.get('mrp')}',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green.withOpacity(0.2)),
                padding: EdgeInsets.all(2),
                child: Text(
                  'You save ₹${widget.snapshot.get('mrp') - widget.snapshot.get('selling')}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ),
            Container(
              width: 120,
              child: StreamBuilder<DocumentSnapshot>(
                  stream: dataProvider.cartCheck(widget.snapshot.id),
                  builder: (context, snapshotData) {
                    if (snapshotData.hasData) {
                      return ElevatedButton(
                        child: Text('Edit',
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {},
                      );
                    }
                    return Row(
                      children: [
                        // ElevatedButton(
                        //   child: Text('Edit',
                        //       style: GoogleFonts.poppins(
                        //           color: Colors.white, fontSize: 16)),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: Colors.green,
                        //     elevation: 0,
                        //     shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(8)),
                        //   ),
                        //   onPressed: () {},
                        // ),
                        ElevatedButton(
                          child: Text('Add',
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            widget.listOfProductsInBilling.add(ProductData(
                                barcode: '${widget.snapshot.get('barcode')}',
                                image: '${widget.snapshot.get('image')}',
                                name: '${widget.snapshot.get('name')}',
                                mrp: widget.snapshot.get('mrp'),
                                price: widget.snapshot.get('selling'),
                                quantity: "quantity",
                                count: 1,
                                description: "description",
                                category: "category"));
                            setState(() {});
                            widget.navigatorDecider
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Bill(
                                        products:
                                            widget.listOfProductsInBilling,
                                      ),
                                    ),
                                  )
                                : Navigator.of(context).pop();
                            print(widget.snapshot.data);
                          },
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    ProductDetails(snapshot: widget.snapshot)));
      },
    );
  }
}
