// import 'package:file_picker_web/file_picker_web.dart' as webPicker;
import 'package:flutter/material.dart';

class TestPlugin extends StatefulWidget {
  const TestPlugin({Key? key}) : super(key: key);

  @override
  _TestPluginState createState() => _TestPluginState();
}

class _TestPluginState extends State<TestPlugin> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        width: 200,
        height: 200,
        child: const Text("hi"));
  }
}
