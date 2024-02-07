import 'package:flutter/material.dart';

form(String title, String hint, TextEditingController controller, Icon ic) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$title',
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
              hintText: "$hint",
              prefixIcon: ic,
            ),
          ),
        ),
      ],
    ),
  );
}
