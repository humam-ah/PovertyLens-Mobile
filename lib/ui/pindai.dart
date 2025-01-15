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
  final TextEditingController _kelurahanController = TextEditingController();
  String? _selectedCategory;

  // Dropdown kategori (ambil dari JSON backend atau definisi statis)
  final List<String> _categories = [
    "Pendidikan",
    "Kesehatan",
    "Kesejahteraan Sosial",
    "Infrastruktur",
  ];

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
        // Update kelurahan dari hasil peta
        if (result['kelurahan'] != null) {
          _kelurahanController.text = result['kelurahan'];
        }
      });
    }
  }

  void _submitData() {
    if (_overlayImageBase64 == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pastikan semua data telah diisi!')),
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
      backgroundColor: Colors.white,
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
          backgroundColor: const Color.fromARGB(255, 22, 163, 74),
          title: const Text(
            'Pindai Wilayah',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _openMapScreen,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _overlayImageBase64 != null
                      ? Image.memory(
                          base64Decode(_overlayImageBase64!.split(',')[1]),
                          fit: BoxFit.cover,
                        )
                      : const Center(child: Text('Klik untuk memilih wilayah')),
                ),
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
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Kategori Bantuan",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 152, 0)),
                child: const Text('Submit',
                style: TextStyle(
                            color: Colors.white,
                          ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
