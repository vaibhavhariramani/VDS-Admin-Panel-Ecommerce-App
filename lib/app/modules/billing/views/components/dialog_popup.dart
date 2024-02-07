import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

import '../../controllers/billing_controller.dart';

class buildPopupDialog extends GetResponsiveView<BillingController> {
  buildPopupDialog(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.bottomLeft,
      child: AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Select Option',
          style: TextStyle(color: Colors.white),
        ),
        content: !kIsWeb
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Upload Image from Camera",
                    style: TextStyle(color: Colors.white),
                  ),
                  MaterialButton(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 90.0,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[Color(0xffCB0338), Color(0xffFF5001)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF000000),
                            offset: Offset(0.0, 1.5),
                            blurRadius: 1.5,
                          ),
                        ],
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(10),
                          right: Radius.circular(10),
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 90.0,
                      ),
                    ),
                    // onPressed: () => startFilePicker(),
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.ImagePickerFromCamera();
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Upload Image from Gallery",
                    style: TextStyle(color: Colors.white),
                  ),
                  MaterialButton(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 90.0,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[Color(0xffCB0338), Color(0xffFF5001)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF000000),
                            offset: Offset(0.0, 1.5),
                            blurRadius: 1.5,
                          ),
                        ],
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(10),
                          right: Radius.circular(10),
                        ),
                      ),
                      child: Icon(
                        Icons.album,
                        color: Colors.white,
                        size: 90.0,
                      ),
                    ),
                    // onPressed: () => startFilePicker(),
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.ImagePickerFromGallery();
                    },
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Upload Image from Gallery",
                    style: TextStyle(color: Colors.white),
                  ),
                  MaterialButton(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 90.0,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[Color(0xffCB0338), Color(0xffFF5001)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF000000),
                            offset: Offset(0.0, 1.5),
                            blurRadius: 1.5,
                          ),
                        ],
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(10),
                          right: Radius.circular(10),
                        ),
                      ),
                      child: Icon(
                        Icons.album,
                        color: Colors.white,
                        size: 90.0,
                      ),
                    ),
                    // onPressed: () => startFilePicker(),
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.ImagePickerFromGalleryWeb();
                    },
                  ),
                ],
              ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              textStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
