import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../../services/firebase.service.dart';
import '../../controllers/billing_controller.dart';
import 'form.dart';

Widget buildProductItem(BuildContext context, int index) {
  final BillingController controller = Get.put(BillingController());

  return Padding(
    padding: const EdgeInsets.only(bottom: 2.0),
    child: Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(children: <Widget>[
        controller.products[index].image != null
            ? Image.network(
                controller.products[index].image,
                height: 80,
                width: 80,
              )
            : const Icon(Icons.photo_size_select_actual_outlined),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.products[index].name, //product name
                style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                        '₹${controller.products[index].price}', //price of product
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text('₹${controller.products[index].mrp}',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough)),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: const Icon(Icons.remove_circle,
                        color: Colors.redAccent, size: 35),
                    onPressed: () async {
                      try {
                        if (controller.products[index].count >= 1) {
                          controller.products[index].count =
                              controller.products[index].count - 1;

                          controller.mrptotal = controller.mrptotal -
                              controller.products[index].mrp;
                          controller.total = controller.total -
                              controller.products[index].price;
                          // setState(() {});
                        }
                        if (controller.products[index].count == 0) {
                          // count.removeAt(index);
                          // images.removeAt(index);
                          // productnames.removeAt(index);
                          // barcodes.removeAt(index);
                          // prices.removeAt(index);
                          // mrp.removeAt(index);
                          // desc.removeAt(index);
                          // cat.removeAt(index);
                          controller.products.removeAt(index);
                        }
                      } catch (e) {}
                    },
                  ),
                  Text(
                    '${controller.products[index].count}',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: const Icon(Icons.add_circle_outlined,
                        color: Colors.redAccent, size: 35),
                    onPressed: () async {
                      try {
                        if (controller.products[index].count < 5) {
                          controller.products[index].count =
                              controller.products[index].count + 1;
                          controller.mrptotal = controller.mrptotal +
                              controller.products[index].mrp;
                          controller.total = controller.total +
                              controller.products[index].price;
                          // setState(() {});
                        }
                      } catch (e) {}
                    },
                  ),
                  Expanded(
                    flex: 1,
                    child: MaterialButton(
                      onPressed: () {
                        // UpdateData();
                        showDialog(
                            context: context,
                            builder: (
                              context,
                            ) {
                              return Dialog(
                                  backgroundColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setState) {
                                    var sete = setState;

                                    TextEditingController FBProductName =
                                        TextEditingController(
                                            text: controller
                                                .products[index].name);
                                    TextEditingController FBMRP =
                                        TextEditingController(
                                            text: controller.products[index].mrp
                                                .toString());
                                    TextEditingController FBSP =
                                        TextEditingController(
                                            text: controller
                                                .products[index].price
                                                .toString());
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.8,
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: ListView(
                                          children: [
                                            const SizedBox(height: 8),
                                            const Center(
                                              child: Padding(
                                                  padding: EdgeInsets.all(15),
                                                  child: Text("Update Details",
                                                      style: TextStyle(
                                                          fontSize: 40,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Colors.white))),
                                            ),
                                            const SizedBox(height: 8),
                                            form(
                                              'Product name',
                                              controller.products[index].name,
                                              FBProductName,
                                              const Icon(
                                                Icons.description,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            form(
                                              'Enter MRP',
                                              controller.products[index].mrp
                                                  .toString(),
                                              FBMRP,
                                              const Icon(
                                                Icons.description,
                                                color: Colors.white,
                                              ),
                                            ),
                                            form(
                                              'Enter Selling price',
                                              controller.products[index].price
                                                  .toString(),
                                              FBSP,
                                              const Icon(
                                                Icons.description,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                            MaterialButton(
                                              elevation: 0,
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'UPDATE',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                InsertDatainFirebase().upload(
                                                    controller.products[index]
                                                        .barcode,
                                                    FBProductName.text,
                                                    controller.products[index]
                                                        .description,
                                                    FBMRP.text,
                                                    FBSP.text,
                                                    controller
                                                        .products[index].count,
                                                    FBSP.text,
                                                    controller
                                                        .products[index].image,
                                                    controller.products[index]
                                                        .category);
                                                controller.products[index]
                                                    .name = FBProductName.text;
                                                controller.products[index].mrp =
                                                    double.parse(FBMRP.text);
                                                controller
                                                        .products[index].price =
                                                    double.parse(FBSP.text);
                                                setState(() {});
                                                FBProductName.clear();
                                                FBMRP.clear();
                                                FBSP.clear();

                                                Navigator.of(context).pop();
                                              },
                                              color: Colors.green,
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }));
                            });
                      },
                      child: Icon(Icons.edit),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: MaterialButton(
                      onPressed: () {
                        controller.mrptotal = controller.mrptotal -
                            (controller.products[index].count *
                                controller.products[index].mrp);
                        controller.total = controller.total -
                            (controller.products[index].count *
                                controller.products[index].price);
                        // count.removeAt(index);
                        // images.removeAt(index);
                        // productnames.removeAt(index);
                        // barcodes.removeAt(index);
                        // prices.removeAt(index);
                        // mrp.removeAt(index);
                        // desc.removeAt(index);
                        // cat.removeAt(index);
                        controller.products.removeAt(index);
                        // setState(() {});
                      },
                      child: Icon(Icons.delete),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    ),
  );
}
