import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:vdsadmin/invoice/pdf_api.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdfx/pdfx.dart' as nativepdf;

import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class PdfViewerPg extends StatefulWidget {
  final String pth;
  final String number;
  const PdfViewerPg({Key? key, required this.pth, required this.number})
      : super(key: key);

  @override
  State<PdfViewerPg> createState() => _PdfViewerPgState();
}

class _PdfViewerPgState extends State<PdfViewerPg> {
  final _controller = ScreenshotController();

  TextEditingController description = TextEditingController();

  TextEditingController msg = TextEditingController();
  late File _pdf;
  late File _image;

  FutureOr<void> share() async {
    await WhatsappShare.share(
      text: msg.text,
      linkUrl: 'https://flutter.dev/',
      phone: '91${description.text}',
    );
  }

  FutureOr<void> shareFile() async {
    await getImage();
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    // print('${directory!.path} / ${_image.path}');
    await WhatsappShare.shareFile(
      text: 'Thank You For Shopping at Vishal Departmental Store',
      phone: '91${widget.number}',
      filePath: [(_pdf.path)],
    );
  }

  FutureOr<void> isInstalled() async {
    final val = await WhatsappShare.isInstalled();
    print('Whatsapp is installed: $val');
  }

  FutureOr<void> shareScreenShot() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    final String localPath =
        '${directory?.path}/${DateTime.now().toIso8601String()}.png';

    // await _controller.capture(path: localPath);

    await Future.delayed(const Duration(seconds: 1));

    await WhatsappShare.shareFile(
      text: 'Whatsapp message text',
      phone: '917790991077',
      filePath: [localPath],
    );
  }

  form(String title, String hint, TextEditingController controller, Icon ic) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: Colors.white)),
            child: TextField(
              controller: controller,
              showCursor: true,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: Colors.white,
                ),
                hintText: hint,
                prefixIcon: ic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  final sampleUrl = 'http://www.africau.edu/images/default/sample.pdf';

  String? pdfFlePath;

  Future<String> downloadAndSavePdf() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sample.pdf');
    if (await file.exists()) {
      return file.path;
    }
    final response = await http.get(Uri.parse(sampleUrl));
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Invoice Bill'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.pth != null)
                Expanded(
                  child: Container(
                    child: PdfView(path: widget.pth),
                  ),
                )
              else
                const Text("Pdf is not Loaded"),
              ElevatedButton(
                child: const Text('Send Bill'),
                onPressed: shareFile,
              ),
              ElevatedButton(
                child: const Text('Print Bill'),
                onPressed: () {
                  PdfApi.openFile(File(widget.pth));
                },
              ),
              ElevatedButton(
                child: const Text('is Installed'),
                onPressed: isInstalled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///Pick Image From gallery using image_picker plugin
  Future getImage() async {
    // final picker = ImagePicker();
    try {
      // XFile? dfile = (await picker.pickImage(
      //     source: ImageSource.gallery, imageQuality: 70));

      // getting a directory path for saving
      final directory = await getExternalStorageDirectory();

      // copy the file to a new path
      // _image = await File(dfile.path).copy('${directory!.path}/image1.png');
      _pdf = await File(widget.pth).copy(
          '${directory!.path}/Thank_you_for_shopping_at_vishal_store.pdf');
    } catch (er) {
      print(er);
    }
  }
}

class PdfViewerweb extends StatefulWidget {
  FutureOr<Uint8List> data;
  final String number;
  PdfViewerweb({Key? key, required this.data, required this.number})
      : super(key: key);

  @override
  State<PdfViewerweb> createState() => _PdfViewerwebState();
}

class _PdfViewerwebState extends State<PdfViewerweb> {
  final _controller = ScreenshotController();

  TextEditingController description = TextEditingController();

  TextEditingController msg = TextEditingController();
  late File _pdf;
  late File _image;

  Future<void> share() async {
    await WhatsappShare.share(
      text: msg.text,
      linkUrl: 'https://flutter.dev/',
      phone: '91${description.text}',
    );
  }

  Future<void> shareFile() async {
    await getImage();
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    // print('${directory!.path} / ${_image.path}');
    await WhatsappShare.shareFile(
      text: 'Thank You For Shopping at Vishal Departmental Store',
      phone: '91${widget.number}',
      filePath: [(_pdf.path)],
    );
  }

  Future<void> isInstalled() async {
    final val = await WhatsappShare.isInstalled();
    print('Whatsapp is installed: $val');
  }

  Future<void> shareScreenShot() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    final String localPath =
        '${directory?.path}/${DateTime.now().toIso8601String()}.png';

    // await _controller.capture(path: localPath);

    await Future.delayed(const Duration(seconds: 1));

    await WhatsappShare.shareFile(
      text: 'Whatsapp message text',
      phone: '917790991077',
      filePath: [localPath],
    );
  }

  form(String title, String hint, TextEditingController controller, Icon ic) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: Colors.white)),
            child: TextField(
              controller: controller,
              showCursor: true,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: Colors.white,
                ),
                hintText: hint,
                prefixIcon: ic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  final sampleUrl = 'http://www.africau.edu/images/default/sample.pdf';

  String? pdfFlePath;

  Future<String> downloadAndSavePdf() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sample.pdf');
    if (await file.exists()) {
      return file.path;
    }
    final response = await http.get(Uri.parse(sampleUrl));
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    print("inside PdfViewerweb");
    // print(widget.data);
    final pdfController = nativepdf.PdfController(
      document: nativepdf.PdfDocument.openData(widget.data),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Invoice Bill'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  elevation: 0,
                  onPressed: shareFile,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)),
                  padding: const EdgeInsets.all(0.0),
                  child: const Text(
                    "Send Bill",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  color: Colors.white,
                ),
                ElevatedButton(
                  child: const Text('Print Bill'),
                  onPressed: () {
                    print('print button pressed');
                    // PdfApi.openFile(File(widget.data));
                  },
                ),
                ElevatedButton(
                  child: const Text('is Installed'),
                  onPressed: isInstalled,
                ),
              ],
            ),
          ],
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.data != null)
                Expanded(
                  child: Container(
                    child: nativepdf.PdfView(
                      controller: pdfController,
                    ),
                  ),
                )
              else
                const Text("Pdf is not Loaded"),
            ],
          ),
        ),
      ),
    );
  }

  ///Pick Image From gallery using image_picker plugin
  Future getImage() async {
    // final picker = ImagePicker();
    try {
      // XFile? dfile = (await picker.pickImage(
      //     source: ImageSource.gallery, imageQuality: 70));

      // getting a directory path for saving
      final directory = await getExternalStorageDirectory();

      // copy the file to a new path
      // _image = await File(dfile.path).copy('${directory!.path}/image1.png');
      _pdf = await File(widget.data as String).copy(
          '${directory!.path}/Thank_you_for_shopping_at_vishal_store.pdf');
    } catch (er) {
      print(er);
    }
  }
}
