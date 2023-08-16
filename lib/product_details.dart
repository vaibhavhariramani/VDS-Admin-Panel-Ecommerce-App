import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:ecom_admin_panel/componds/imagess.dart';
import 'models/data_provider.dart';

class ProductDetails extends StatefulWidget {
  final DocumentSnapshot snapshot;
  const ProductDetails({Key? key, required this.snapshot}) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  TextEditingController name = new TextEditingController();
  TextEditingController description = new TextEditingController();
  TextEditingController mrp = new TextEditingController();
  TextEditingController price = new TextEditingController();
  TextEditingController selling = new TextEditingController();
  TextEditingController quantity = new TextEditingController();
  List<String> category = [];
  List<String> sub = [];
  List<String> pincode = [];
  bool check = false;
  late String region;
  late String category1;
  late String sub1;

  @override
  void initState() {
    // TODO: implement initState
    name.text = widget.snapshot['name'];
    description.text = widget.snapshot['description'];
    mrp.text = widget.snapshot['mrp'].toString();
    quantity.text = widget.snapshot['quantity'];
    price.text = widget.snapshot['price'].toString();
    selling.text = widget.snapshot['selling'].toString();
    category = List.from(widget.snapshot['category']);
    sub = List.from(widget.snapshot['tags']);
    pincode = List.from(widget.snapshot['pincode']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.width * 0.15,
              color: Colors.white,
              child: DottedBorder(
                color: Colors.black,
                strokeWidth: 1,
                child: MyImage(imageUrl: widget.snapshot['image']),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _form('Enter Product Name', 'Product name', name),
              ),
              Expanded(
                child: _form('Product Description', 'Description', description),
              ),
              Expanded(
                child: _form('Product Quantity', 'Quantity', quantity),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _form2('M.R.P', 'm.r.p', mrp),
              ),
              Expanded(
                child: _form2('Purchase Price', 'Price', price),
              ),
              Expanded(
                child: _form2('Selling Price', 'Selling Price', selling),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Region Select',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 5.0,
                  childAspectRatio: 3 / 0.6,
                  mainAxisSpacing: 5.0,
                ),
                shrinkWrap: true,
                children: List.generate(pincode.length + 1, (index) {
                  if (pincode.length > index) {
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Colors.black)),
                      child: ListTile(
                        title: Text('${pincode[index]}'),
                        tileColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        trailing: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                pincode.removeAt(index);
                              });
                            }),
                      ),
                    );
                  } else {
                    return Container(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Colors.black)),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: dataProvider.regions(0),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return DropdownButton(
                                value: region,
                                icon: Icon(Icons.keyboard_arrow_down),
                                iconSize: 24,
                                elevation: 16,
                                isExpanded: true,
                                underline: Container(),
                                hint: Text('Pincode'),
                                style: TextStyle(color: Colors.black),
                                onChanged: (v) {
                                  setState(() {
                                    region = v.toString();
                                  });
                                },
                                items: snapshot.data!.docs.map((value) {
                                  return DropdownMenuItem(
                                    value: value['pincode'].toString(),
                                    child: Text(value['pincode'].toString()),
                                    onTap: () {
                                      pincode.add(value['pincode']);
                                      region = value['pincode'];
                                      setState(() {});
                                    },
                                  );
                                }).toList(),
                              );
                            } else {
                              return Text('Something went wrong');
                            }
                          }),
                    );
                  }
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 5.0,
                  childAspectRatio: 3 / 0.6,
                  mainAxisSpacing: 5.0,
                ),
                shrinkWrap: true,
                children: List.generate(category.length + 1, (index) {
                  if (category.length > index) {
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Colors.black)),
                      child: ListTile(
                        title: Text('${category[index]}'),
                        tileColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        trailing: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                category.removeAt(index);
                              });
                            }),
                      ),
                    );
                  } else {
                    return Container(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Colors.black)),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: dataProvider.category(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return DropdownButton(
                                value: category1,
                                icon: Icon(Icons.keyboard_arrow_down),
                                iconSize: 24,
                                elevation: 16,
                                isExpanded: true,
                                underline: Container(),
                                hint: Text('Category'),
                                style: TextStyle(color: Colors.black),
                                onChanged: (v) {
                                  setState(() {
                                    category1 = v.toString();
                                  });
                                },
                                items: snapshot.data!.docs.map((value) {
                                  return DropdownMenuItem(
                                    value: value['name'].toString(),
                                    child: Text(value['name'].toString()),
                                    onTap: () {
                                      category.add(value['name']);
                                      category1 = value['name'];
                                      setState(() {});
                                    },
                                  );
                                }).toList(),
                              );
                            } else {
                              return Text('Something went wrong');
                            }
                          }),
                    );
                  }
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Sub Tags',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 5.0,
                  childAspectRatio: 3 / 0.6,
                  mainAxisSpacing: 5.0,
                ),
                shrinkWrap: true,
                children: List.generate(sub.length + 1, (index) {
                  if (sub.length > index) {
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Colors.black)),
                      child: ListTile(
                        title: Text('${sub[index]}'),
                        tileColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        trailing: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                sub.removeAt(index);
                              });
                            }),
                      ),
                    );
                  } else {
                    return Container(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Colors.black)),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: dataProvider.subTags(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return DropdownButton(
                                value: sub1,
                                icon: Icon(Icons.keyboard_arrow_down),
                                iconSize: 24,
                                elevation: 16,
                                isExpanded: true,
                                underline: Container(),
                                hint: Text('Sub Category'),
                                style: TextStyle(color: Colors.black),
                                onChanged: (v) {
                                  setState(() {
                                    sub1 = v.toString();
                                  });
                                },
                                items: snapshot.data!.docs.map((value) {
                                  return DropdownMenuItem(
                                    value: value['name'].toString(),
                                    child: Text(value['name'].toString()),
                                    onTap: () {
                                      sub.add(value['name']);
                                      sub1 = value['name'];
                                      setState(() {});
                                    },
                                  );
                                }).toList(),
                              );
                            } else {
                              return Text('Something went wrong');
                            }
                          }),
                    );
                  }
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(right: 30),
            alignment: Alignment.centerRight,
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.1,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text('Update', style: TextStyle(color: Colors.white)),
                  ),
                  onPressed: _update),
            ),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  _form2(String title, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$title',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: Colors.black)),
            child: TextField(
              controller: controller,
              showCursor: true,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFF666666),
                ),
                hintText: "$hint",
              ),
            ),
          ),
        ],
      ),
    );
  }

  _form(String title, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$title',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: Colors.black)),
            child: TextField(
              controller: controller,
              showCursor: true,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFF666666),
                ),
                hintText: "$hint",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _update() async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('Products');
    try {
      reference.doc(widget.snapshot.id).set({
        'name': name.text,
        'description': description.text,
        'quantity': quantity.text,
        'mrp': double.parse(mrp.text),
        'price': double.parse(price.text),
        'selling': double.parse(selling.text),
        'pincode': pincode,
        'category': category,
        'tags': sub,
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
