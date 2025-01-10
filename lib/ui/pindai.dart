import 'package:flutter/material.dart';
import 'package:poverty_lens/ui/hasil_pindai.dart';
import 'package:poverty_lens/ui/map.dart';
import 'dart:convert';

class PindaiScreen extends StatefulWidget {
  const PindaiScreen({super.key});

  @override
  State<PindaiScreen> createState() => _PindaiScreenState();
}

class _PindaiScreenState extends State<PindaiScreen> {
  String? _overlayImageBase64;
  Map<String, dynamic>? _backendResult;
  Map<String, double>? _percentages;
  final TextEditingController _kelurahanController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _laporanController = TextEditingController();

  void _openMapScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _overlayImageBase64 = result['image'];
        _backendResult = result['result'];
      });
    }
  }

  void _resetCapture() {
    setState(() {
      _overlayImageBase64 = null;
      _backendResult = null;
    });
  }

  void _submitData() {
    if (_overlayImageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capture peta terlebih dahulu!')),
      );
      return;
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HasilPindaiScreen(
            imageBase64: _overlayImageBase64,
            backendResult: _backendResult,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(),
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          )),
          backgroundColor: const Color.fromARGB(255, 208, 232, 197),
          title: const Text(
            'Pindai Wilayah',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, 
              ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: _overlayImageBase64 != null
                  ? Stack(
                      children: [
                        Image.memory(
                          base64Decode(_overlayImageBase64!),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.refresh, color: Colors.red),
                            onPressed: _resetCapture,
                          ),
                        ),
                      ],
                    )
                  :
                  Center(
                    child: ElevatedButton(
                      onPressed: _openMapScreen,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: const Text(
                        "Buka PovertyMap",
                        style: TextStyle(
                          color: Color.fromARGB(255, 208, 232, 197)
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kelurahanController,
              decoration: const InputDecoration(
                labelText: "Kelurahan",
                floatingLabelStyle: TextStyle(color: Color.fromARGB(255, 208, 232, 197)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 208, 232, 197))
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 208, 232, 197))
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kategoriController,
              decoration: const InputDecoration(
                labelText: "Kategori Bantuan",
                floatingLabelStyle: TextStyle(color: Color.fromARGB(255, 208, 232, 197)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 208, 232, 197))
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 208, 232, 197))
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _laporanController,
              decoration: const InputDecoration(
                labelText: "Laporan Anda",
                floatingLabelStyle: TextStyle(color: Color.fromARGB(255, 208, 232, 197)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 208, 232, 197))
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 208, 232, 197))
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text(
                "Submit",
                style: TextStyle(
                  color: Color.fromARGB(255, 208, 232, 197)
                ),
              ),
            ),
            SizedBox(height: 16,)
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
