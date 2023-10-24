import 'dart:io';
// import 'dart:html' as webFile;
// import 'package:file_picker_web/file_picker_web.dart' as webPicker;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    print("Saving PDF now");
    final bytes = await pdf.save();

    print("Getting path to store pdf in android");
    final dir = await getApplicationDocumentsDirectory();
    print(dir);
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}

class PdfApiWeb {
  static Future<Object> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    print("Saving PDF now");
    final bytes = await pdf.save();
    if (kIsWeb) {
      return bytes;
    } else {
      print("Getting path to store pdf in android");
      final dir = await getApplicationDocumentsDirectory();
      print(dir);
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(bytes);

      return file;
    }
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}
