import 'package:flutter/material.dart';
import 'package:poverty_lens/ui/map.dart';
import 'dart:convert';

class PindaiScreen extends StatefulWidget {
  const PindaiScreen({super.key});

  @override
  State<PindaiScreen> createState() => _PindaiScreenState();
}

class _PindaiScreenState extends State<PindaiScreen> {
  String? _overlayImageBase64;
  Map<String, double>? _percentages;
  final TextEditingController _kelurahanController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _laporanController = TextEditingController();

  void _openMapScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _overlayImageBase64 = result['overlay_image'];
        _percentages = (result['percentages'] as Map)
            .map((key, value) => MapEntry(key.toString(), value.toDouble()));
        _kelurahanController.text = result['kelurahan'] ?? 'Tidak ditemukan';
      });
    }
  }

  void _submitData() {
    if (_overlayImageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capture peta terlebih dahulu!')),
      );
      return;
    }
    // Lakukan submit data ke backend
    print("Submit berhasil dengan data:");
    print("Kelurahan: ${_kelurahanController.text}");
    print("Kategori: ${_kategoriController.text}");
    print("Laporan: ${_laporanController.text}");
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
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: ElevatedButton(
                  onPressed: _openMapScreen,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text("Buka PovertyMap",),
                ),
              ),
            ),
            if (_overlayImageBase64 != null)
              Column(
                children: [
                  const SizedBox(height: 16),
                  Image.memory(
                    base64Decode(_overlayImageBase64!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  if (_percentages != null)
                    ..._percentages!.entries.map(
                      (entry) => Text(
                        "${entry.key}: ${entry.value.toStringAsFixed(2)}%",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _kelurahanController,
              decoration: const InputDecoration(
                labelText: "Kelurahan",
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kategoriController,
              decoration: const InputDecoration(
                labelText: "Kategori Bantuan",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _laporanController,
              decoration: const InputDecoration(
                labelText: "Laporan Anda",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Submit"),
            ),
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
