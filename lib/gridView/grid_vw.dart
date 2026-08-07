// ignore: import_of_legacy_library_into_null_safe

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
import 'package:vdsadmin/billing/bill.dart';
import 'package:vdsadmin/gridView/gviewer.dart';
import 'package:vdsadmin/home/loginpage.dart';
import 'package:vdsadmin/models/data_provider.dart';
import 'package:vdsadmin/models/product_data.dart';
import 'package:vdsadmin/search/search.dart';

class GridScreen extends StatefulWidget {
  final bool dataViewer;
  List<ProductData> listOfProductsInBill;
  GridScreen(
      {Key? key, required this.dataViewer, required this.listOfProductsInBill})
      : super(key: key);

  @override
  _GridScreenState createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  List<String> links = [];
  late String url;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int get _itemCount =>
      widget.listOfProductsInBill.fold(0, (sum, p) => sum + p.count);

  double get _total => widget.listOfProductsInBill
      .fold(0, (sum, p) => sum + (p.price * p.count));

  void _viewBill() {
    if (widget.dataViewer) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Bill(
            products: widget.listOfProductsInBill,
            addedfromDB: true,
          ),
        ),
      );
    } else {
      Navigator.of(context).pop(widget.listOfProductsInBill);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xff17191c) : const Color(0xffF5F6F8);
    final searchBarColor = isDark ? const Color(0xff23262b) : Colors.white;
    final searchTextColor = isDark ? Colors.white : const Color(0xFF666666);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: const Color(0xffF3AB0D),
        foregroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: const Text('Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0).copyWith(top: 2, bottom: 5),
            child: Container(
              padding: const EdgeInsets.only(left: 8),
              height: 38,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(02)),
                  border: Border.all(color: searchBarColor),
                  color: searchBarColor),
              child: TextField(
                showCursor: true,
                textAlign: TextAlign.left,
                readOnly: true,
                style: TextStyle(color: searchTextColor),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xffA0CD4A),
                  ),
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: searchTextColor),
                  hintText: "Search your products",
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const Search()));
                },
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        padding: EdgeInsets.only(bottom: _itemCount > 0 ? 80 : 0),
        children: [
          const SizedBox(height: 5),
          StreamBuilder<QuerySnapshot>(
              stream: dataProvider.prd(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
                if (snap.hasData) {
                  return snap.data!.docs.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      MediaQuery.of(context).orientation ==
                                              Orientation.landscape
                                          ? 3
                                          : 2,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                  mainAxisExtent: 336),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snap.data!.docs.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return HomeGridProductList(
                              snapshot: snap.data!.docs[index],
                              navigatorDecider: widget.dataViewer,
                              listOfProductsInBilling:
                                  widget.listOfProductsInBill,
                              onChanged: () => setState(() {}),
                            );
                          },
                        )
                      : Container();
                }
                return const Center(child: CircularProgressIndicator());
              }),
          const SizedBox(height: 20)
        ],
      ),
      bottomNavigationBar: _itemCount > 0
          ? Material(
              color: const Color(0xff2E7D32),
              child: InkWell(
                onTap: _viewBill,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_itemCount item${_itemCount == 1 ? '' : 's'} · ₹${_total.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Bill',
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void pickImage() {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 34),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Center(
                        child: Icon(
                          Icons.info_outline,
                          size: 65,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          'Are sure you want to logout?',
                          style: GoogleFonts.poppins(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: MaterialButton(
                                elevation: 0,
                                color: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "NO",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                }),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            child: MaterialButton(
                                elevation: 0,
                                color: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "YES",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  FirebaseAuth auth = FirebaseAuth.instance;
                                  await auth.signOut();
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const Login()));
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
