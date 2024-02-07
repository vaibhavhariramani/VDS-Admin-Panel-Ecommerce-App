import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../services/fetch_data.dart';
import '../../../../widgets/components/raised_gradient_button.dart';
import '../../controllers/billing_controller.dart';
import '../widgets/form.dart';
import 'dialog_popup.dart';

class addItemDialog extends GetResponsiveView<BillingController> {
  String? barcode;

  addItemDialog(BuildContext context, {required String barcode});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.blueGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          var sete = setState;
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.6,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  const Center(
                    child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Text("Add New Item to Database",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.white))),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Barcode',
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.backup_table_rounded,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  border: Border.all(color: Colors.white)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  barcode!,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  form(
                    'Enter Product name',
                    'Product name',
                    controller.newProductName,
                    const Icon(
                      Icons.description,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  form(
                    'Enter MRP',
                    'MRP',
                    controller.newMRP,
                    const Icon(
                      Icons.description,
                      color: Colors.white,
                    ),
                  ),
                  form(
                    'Enter Selling price',
                    'Selling Price',
                    controller.newSP,
                    const Icon(
                      Icons.description,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(8)),
                        border: Border.all(color: Colors.white)),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FetchService.to.category(),
                        builder: (context, snapshot) {
                          return DropdownButton(
                            value: controller.category1,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                            iconSize: 24,
                            elevation: 16,
                            isExpanded: true,
                            underline: Container(),
                            hint: const Text(
                              'Category',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                            onChanged: (v) {
                              setState(() {
                                controller.category1 = v;
                              });
                            },
                            items: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: data['tag'],
                                child: Text(data['tag']),
                              );
                            }).toList(),
                          );
                        }),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        controller.Dataseturl == null
                            ? const Icon(Icons.image)
                            : Image.network(
                                controller.Dataseturl!,
                                height: 200.0,
                                width: MediaQuery.of(context).size.width * 0.7,
                              ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedGradientButton(
                            child: const Text(
                              'Upload Image',
                              style: TextStyle(color: Colors.white),
                            ),
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color(0xffCB0338),
                                Color(0xffFF5001)
                              ],
                            ),
                            // onPressed: () => startFilePicker(),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    buildPopupDialog(context),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    elevation: 0,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'ADD TO DATABASE',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onPressed: () {
                      controller.addToDatabase(
                        barcode!,
                        controller.newProductName.text,
                        double.parse(controller.newMRP.text),
                        controller.newMRP.text,
                        double.parse(controller.newSP.text),
                        controller.newSP.text,
                      );
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    color: Colors.green,
                  )
                ],
              ),
            ),
          );
        }));
  }
}
