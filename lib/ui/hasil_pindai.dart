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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(),
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          )),
          backgroundColor: const Color.fromARGB(255, 22, 163, 74),
          title: const Text(
            'Hasil Pindai',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              backendResult != null
                  ? Column(
                      children: [
                        Container(
                          height: 300,
                          child: Image.memory(
                            base64Decode(backendResult?["overlay_image"]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (backendResult?['kategori'] != null)
                          Text(
                            "Kategori: ${backendResult!['kategori']}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        if (backendResult?['persentase'] != null)
                          Text(
                            "Persentase Kemiskinan: ${backendResult!['persentase']}%",
                            style: const TextStyle(fontSize: 16),
                          ),
                      ],
                    )
                  : const Text("Tidak ada hasil dari backend"),
            ],
          ),
        ),
      ),
    );
  }
}
