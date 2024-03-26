import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vdsadmin/models/data_provider.dart';
import 'package:vdsadmin/search/product_details.dart';
import 'package:vdsadmin/search/search.dart';

class FilterProduct extends StatefulWidget {
  final DocumentSnapshot snapshot;

  const FilterProduct({Key? key, required this.snapshot}) : super(key: key);
  @override
  _FilterProductState createState() => _FilterProductState();
}

class _FilterProductState extends State<FilterProduct> {
  bool loading = false;
  late String filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10.withOpacity(0.95),
      appBar: AppBar(
        backgroundColor: const Color(0xff6fb840),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '${widget.snapshot.get('name')}',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => const Search(),
                  transitionsBuilder: (c, anim, a2, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 10),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 8),
          widget.snapshot.get('tags') != null
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.snapshot.get('tags').length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 0,
                        child: GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: filter ==
                                            widget.snapshot.get('tags')[index]
                                                ['name']
                                        ? Colors.green
                                        : Colors.white,
                                    width: 2)),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, bottom: 4),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.snapshot
                                          .get('tags')[index]['image'],
                                      fit: BoxFit.contain,
                                      width: 60,
                                      height: 60,
                                    )),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 90,
                                    child: Text(
                                        '${widget.snapshot.get('tags')[index]['name']}',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600),
                                        maxLines: 2,
                                        overflow: TextOverflow.clip)),
                                const SizedBox(width: 4),
                              ],
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              filter =
                                  widget.snapshot.get('tags')[index]['name'];
                            });
                          },
                        ),
                      );
                    },
                  ),
                )
              : Container(),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
              stream: dataProvider.products(widget.snapshot.get('tag')),
              builder: (context, snapshot) {
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: snapshot.data?.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    if (snapshot.hasData) {
                      return ProductView(
                        snapshot: snapshot.data?.docs[index]
                            as QueryDocumentSnapshot<Object>,
                        onClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ProductDetails(
                                          snapshot:
                                              snapshot.data!.docs[index])));
                        },
                      );
                    }
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Loading....',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 80, right: 80),
                            child: Text(
                              "We are looking to match best product for you",
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              })
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget ProductView(
      {required QueryDocumentSnapshot<Object> snapshot,
      Null Function()? onClick}) {
    return Container(
      child: const Text('hello'),
    );
  }
}
