import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:vdsadmin/invoice/pdf_api.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdfx/pdfx.dart' as nativepdf;

import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

const _sendWhatsAppBillUrl =
    'https://us-central1-ecommerce-26b18.cloudfunctions.net/sendWhatsAppBill';

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
              Expanded(
                child: Container(
                  child: PdfView(path: widget.pth),
                ),
              ),
              ElevatedButton(
                onPressed: shareFile,
                child: const Text('Send Bill'),
              ),
              ElevatedButton(
                child: const Text('Print Bill'),
                onPressed: () {
                  PdfApi.openFile(File(widget.pth));
                },
              ),
              ElevatedButton(
                onPressed: isInstalled,
                child: const Text('is Installed'),
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
  final String? pdfUrl;
  final dynamic amount;
  PdfViewerweb({
    Key? key,
    required this.data,
    required this.number,
    this.pdfUrl,
    this.amount,
  }) : super(key: key);

  @override
  State<PdfViewerweb> createState() => _PdfViewerwebState();
}

class _PdfViewerwebState extends State<PdfViewerweb> {
  final _controller = ScreenshotController();

  TextEditingController description = TextEditingController();

  TextEditingController msg = TextEditingController();
  bool _isSendingWhatsApp = false;
  late final nativepdf.PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = nativepdf.PdfController(
      document: nativepdf.PdfDocument.openData(widget.data),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> sendViaWhatsApp() async {
    if (widget.pdfUrl == null || widget.number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing customer number or bill link.'),
        ),
      );
      return;
    }
    setState(() => _isSendingWhatsApp = true);
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse(_sendWhatsAppBillUrl),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'data': {
            'phone': widget.number,
            'customerName': 'Customer',
            'amount': widget.amount?.toString() ?? '0',
            'pdfUrl': widget.pdfUrl,
          },
        }),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode != 200 || decoded['error'] != null) {
        throw Exception(
          decoded['error']?['message'] ?? 'Failed to send bill via WhatsApp.',
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bill sent via WhatsApp.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send bill via WhatsApp: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingWhatsApp = false);
    }
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
                  onPressed: _isSendingWhatsApp ? null : sendViaWhatsApp,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  color: Colors.white,
                  child: _isSendingWhatsApp
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        )
                      : const Text(
                          "Send via WhatsApp",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                ),
                ElevatedButton(
                  child: const Text('Print Bill'),
                  onPressed: () {
                    print('print button pressed');
                    // PdfApi.openFile(File(widget.data));
                  },
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
              Expanded(
                child: Container(
                  child: nativepdf.PdfView(
                    controller: _pdfController,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
