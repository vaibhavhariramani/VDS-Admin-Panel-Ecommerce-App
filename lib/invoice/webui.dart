import 'dart:html' as webFile;
// import 'package:file_picker_web/file_picker_web.dart' as webPicker;
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui' as ui;

class TestPlugin extends StatefulWidget {
  TestPlugin();

  _TestPluginState createState() => _TestPluginState();
}

class _TestPluginState extends State<TestPlugin> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        width: 200,
        height: 200,
        child: Text("hi"));
  }
}
