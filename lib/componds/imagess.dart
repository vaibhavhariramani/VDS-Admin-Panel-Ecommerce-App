import 'dart:html';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MyImage extends StatelessWidget {
  final String imageUrl;

  MyImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // https://github.com/flutter/flutter/issues/41563
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      imageUrl,
      (int _) => ImageElement()..src = imageUrl,
    );
    return HtmlElementView(
      viewType: imageUrl,
    );
  }
}
