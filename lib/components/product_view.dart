import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductView extends StatelessWidget {
  final DocumentSnapshot snapshot;
  final Function onClick;

  ProductView({required this.snapshot, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(bottom: 2),
        ),
      ),
      onTap: () {
        onClick();
      },
    );
  }
}
