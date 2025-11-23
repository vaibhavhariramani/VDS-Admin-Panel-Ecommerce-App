import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ecom_admin_panel/product_details.dart';

import 'componds/product_view.dart';
import 'models/data_provider.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  String search = '';
  String? selectedCategory;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await dataProvider.category().first;
      setState(() {
        categories = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'tag': data['tag']?.toString() ?? '',
            'name': data['name']?.toString() ?? '',
            'id': doc.id,
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Widget _buildLoadingState() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Loading....',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 80, right: 80),
            child: Text(
              "We are looking to match best product for you",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                // Search bar
                Expanded(
                  flex: MediaQuery.of(context).size.width < 1000 ? 7 : 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(flex: 1, child: Icon(Icons.search)),
                            Expanded(
                              flex: 9,
                              child: TextField(
                                style: TextStyle(color: Colors.black),
                                cursorColor: Colors.deepPurple,
                                onChanged: (v) {
                                  setState(() {
                                    search = v;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Search products",
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
                // Category dropdown
                Expanded(
                  flex: MediaQuery.of(context).size.width < 1000 ? 3 : 2,
                  child: Container(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      icon: Icon(Icons.keyboard_arrow_down),
                      iconSize: 24,
                      elevation: 16,
                      isExpanded: true,
                      underline: Container(),
                      hint: Text('All Categories'),
                      style: TextStyle(color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['tag'],
                            child: Text(category['tag']),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: dataProvider.products(search: search, filter: selectedCategory ?? ''),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Center(child: Text('No products found'));
              }
              
              return GridView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, childAspectRatio: 3 / 2),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  
                  // Safe type conversion for all fields
                  String safeToString(dynamic value) => value?.toString() ?? '';
                  
                  return ProductView(
                    image: safeToString(data['image']),
                    name: safeToString(data['name']),
                    description: safeToString(data['description']),
                    quantity: safeToString(data['quantity']),
                    mrp: safeToString(data['mrp']),
                    wholesale: safeToString(data['selling']),
                    onClick: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ProductDetails(snapshot: doc)));
                    },
                    onDelete: () async {
                      await doc.reference.delete();
                    },
                  );
                },
              );
            }
            
            if (snapshot.hasError) {
              return Center(child: Text('Error loading products'));
            }
            
            return Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }
}