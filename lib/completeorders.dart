import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ecom_admin_panel/order_details.dart';
import 'componds/imagess.dart';
import 'models/data_provider.dart';

class CompleteOrders extends StatefulWidget {
  const CompleteOrders({Key? key}) : super(key: key);

  @override
  _CompleteOrdersState createState() => _CompleteOrdersState();
}

class _CompleteOrdersState extends State<CompleteOrders> {
  String? pincode;
  String search = '';

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
                                BorderRadius.all(Radius.circular(10))),
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
                                    search = v; // Fixed: Actually update search variable
                                  });
                                },
                                decoration: InputDecoration(
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
                    padding: EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.black26)),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: dataProvider.regions(0),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return DropdownButton(
                              value: pincode,
                              icon: Icon(Icons.keyboard_arrow_down),
                              iconSize: 24,
                              elevation: 16,
                              isExpanded: true,
                              underline: Container(),
                              hint: Text('Pincode'),
                              style: TextStyle(color: Colors.black),
                              onChanged: (v) {
                                setState(() {
                                  pincode = v.toString();
                                });
                              },
                              items: snapshot.data!.docs.map((value) {
                                return DropdownMenuItem(
                                  value: value['pincode'].toString(),
                                  child: Text(value['pincode'].toString()),
                                );
                              }).toList(),
                            );
                          } else {
                            return Text('Something went wrong');
                          }
                        }),
                  ),
                ),
                SizedBox(width: 8)
              ],
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: dataProvider.completeOrders(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(right: 32, top: 12),
                  child: PaginatedDataTable(
                    showCheckboxColumn: false,
                    rowsPerPage: snapshot.data!.docs.isEmpty
                        ? 1
                        : snapshot.data!.docs.length < 10
                            ? snapshot.data!.docs.length
                            : 10,
                    columns: [
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('Order ID')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Total Amount')),
                      DataColumn(label: Text('Pincode')),
                      DataColumn(label: Text('Status')),
                    ],
                    source: DataSource(context, snapshot.data!), // FIXED: Use snapshot.data!
                  ),
                );
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error loading orders'));
              }
              
              return Center(child: CircularProgressIndicator());
            }),
      ],
    );
  }
}

class DataSource extends DataTableSource {
  DataSource(this.context, this.rows);

  final BuildContext context;
  final QuerySnapshot rows;
  int _selectedCount = 0;

  // Helper method for safe data access
  String _getFieldValue(QueryDocumentSnapshot doc, String fieldName) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      return data?[fieldName]?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= rows.docs.length) return null;
    final row = rows.docs[index];
    
    return DataRow.byIndex(
      selected: false,
      index: index,
      onSelectChanged: (value) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    OrderDetails(snapshot: row)));
      },
      cells: [
        DataCell(CircleAvatar(
          backgroundColor: Colors.white,
          child: Container(
            width: 40,
            height: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: MyImage(imageUrl: _getFieldValue(row, 'image')),
            ),
          ),
        )),
        DataCell(Text(_getFieldValue(row, 'booking'))),
        DataCell(Text(_getFieldValue(row, 'name'))),
        DataCell(Text(_getFieldValue(row, 'phone'))),
        DataCell(Text('₹${_getFieldValue(row, 'total')}')),
        DataCell(Text(_getFieldValue(row, 'pincode'))),
        DataCell(Container(
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4)),
            padding: EdgeInsets.all(4),
            child: Text(
              _getFieldValue(row, 'status'),
              style: TextStyle(color: Colors.green),
            ))),
      ],
    );
  }

  @override
  int get rowCount => rows.docs.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}