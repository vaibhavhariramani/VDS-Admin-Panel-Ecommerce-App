import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vdsadmin/gridView/gviewer.dart';
import 'package:vdsadmin/models/data_provider.dart';
import 'package:vdsadmin/models/product_data.dart';

class HomeGridProducts extends StatelessWidget {
  final DocumentSnapshot snapshot;
  List<ProductData> productsInBilling = [];
  HomeGridProducts(
      {Key? key, required this.snapshot, required this.productsInBilling})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: dataProvider.prd(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
          if (snap.hasData) {
            return snap.data!.docs.isNotEmpty
                ? Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1 / 1.05,
                          child: GridView.builder(
                            // itemExtent: 210,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? 3
                                      : 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: (2 / 1),
                            ),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: snap.data!.docs.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return HomeGridProductList(
                                snapshot: snap.data!.docs[index],
                                navigatorDecider: true,
                                listOfProductsInBilling: productsInBilling,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Container();
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
