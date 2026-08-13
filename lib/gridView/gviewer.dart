import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vdsadmin/models/product_data.dart';
import 'package:vdsadmin/search/product_details.dart';
import 'package:vdsadmin/theme/app_theme.dart';

class HomeGridProductList extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final bool navigatorDecider;
  List<ProductData> listOfProductsInBilling;
  final VoidCallback? onChanged;
  HomeGridProductList({
    Key? key,
    required this.snapshot,
    required this.navigatorDecider,
    required this.listOfProductsInBilling,
    this.onChanged,
  }) : super(key: key);
  @override
  _HomeGridProductListState createState() => _HomeGridProductListState();
}

class _HomeGridProductListState extends State<HomeGridProductList> {
  String get _barcode {
    final data = widget.snapshot.data() as Map<String, dynamic>?;
    return data?['barcode']?.toString() ?? widget.snapshot.id;
  }

  ProductData? get _existingEntry {
    for (final p in widget.listOfProductsInBilling) {
      if (p.barcode == _barcode) return p;
    }
    return null;
  }

  void _addOne() {
    final existing = _existingEntry;
    if (existing != null) {
      setState(() => existing.count += 1);
    } else {
      setState(() {
        widget.listOfProductsInBilling.add(ProductData(
          barcode: _barcode,
          image: '${widget.snapshot.get('image')}',
          name: '${widget.snapshot.get('name')}',
          mrp: double.parse(widget.snapshot.get('mrp').toString()),
          price: double.parse(widget.snapshot.get('selling').toString()),
          quantity: "quantity",
          count: 1,
          description: "description",
          category: "category",
        ));
      });
    }
    widget.onChanged?.call();
  }

  void _removeOne() {
    final existing = _existingEntry;
    if (existing == null) return;
    setState(() {
      if (existing.count <= 1) {
        widget.listOfProductsInBilling.remove(existing);
      } else {
        existing.count -= 1;
      }
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final count = _existingEntry?.count ?? 0;

    return GestureDetector(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  height: 110,
                  width: 110,
                  imageUrl: widget.snapshot.get('image'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              title: Text(
                '${widget.snapshot.get('name')}',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('Price for ${widget.snapshot.get('quantity')}',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: isDark ? Colors.white60 : Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    '₹${widget.snapshot.get('mrp')}',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    '₹${widget.snapshot.get('selling')}',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    color: Colors.green.withOpacity(0.2)),
                padding: const EdgeInsets.all(2),
                child: Text(
                  'You save ₹${widget.snapshot.get('mrp') - widget.snapshot.get('selling')}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: count == 0
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill)),
                      ),
                      onPressed: _addOne,
                      child: Text('Add',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 16)),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: _removeOne,
                          ),
                          Text(
                            '$count',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _addOne,
                          ),
                        ],
                      ),
                    ),
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
