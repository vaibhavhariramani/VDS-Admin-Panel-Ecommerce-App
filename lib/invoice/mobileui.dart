import 'package:flutter/material.dart';

class TestPlugin extends StatefulWidget {
  const TestPlugin({Key? key}) : super(key: key);

  @override
  _TestPluginState createState() => _TestPluginState();
}

class _TestPluginState extends State<TestPlugin> {
  @override
  Widget build(BuildContext context) {
    return const Text("Mobile");
  }
}
