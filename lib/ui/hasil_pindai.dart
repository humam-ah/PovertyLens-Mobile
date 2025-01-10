import 'dart:convert';

import 'package:flutter/material.dart';

class HasilPindaiScreen extends StatelessWidget {
  final String? imageBase64;
  final Map<String, dynamic>? backendResult;

  const HasilPindaiScreen({
    Key? key,
    required this.imageBase64,
    required this.backendResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hasil Pindai"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            backendResult != null
                ? Image.memory(
                    base64Decode(backendResult?["overlay_image"]),
                    fit: BoxFit.cover,
                  )
                : Text("Tidak ada hasil dari backend"),
          ],
        ),
      ),
    );
  }
}