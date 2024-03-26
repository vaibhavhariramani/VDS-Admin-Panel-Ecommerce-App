// ignore: import_of_legacy_library_into_null_safe

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white10.withOpacity(0.95),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        titleSpacing: 0,
        title: const Text('grid view'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0).copyWith(top: 2, bottom: 5),
            child: Container(
              padding: const EdgeInsets.only(left: 8),
              height: 38,
              // width: 0.75*MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(02)),
                  border: Border.all(color: Colors.white),
                  color: Colors.white),
              child: TextField(
                showCursor: true,
                textAlign: TextAlign.left,
                readOnly: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Color(0xffA0CD4A),
                  ),
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Color(0xFF666666),
                  ),
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        children: [
          const SizedBox(height: 5),
          StreamBuilder<QuerySnapshot>(
              stream: dataProvider.prd(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
                if (snap.hasData) {
                  return snap.data!.docs.isNotEmpty
                      ? GridView.builder(
                          // itemExtent: 210,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      MediaQuery.of(context).orientation ==
                                              Orientation.landscape
                                          //     &&
                                          // MediaQuery.of(context).size.width >
                                          //     500
                                          ? 3
                                          : 2,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                  // childAspectRatio: (2 / 1),\
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
