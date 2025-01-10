import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailLembagaScreen extends StatefulWidget {
  final String lembagaId;
  final String lembagaName;
  final String logoUrl;

  const DetailLembagaScreen(
      {super.key, required this.lembagaId,
      required this.lembagaName,
      required this.logoUrl});

  @override
  _DetailLembagaScreenState createState() => _DetailLembagaScreenState();
}

class _DetailLembagaScreenState extends State<DetailLembagaScreen> {
  Map<String, dynamic>? _lembagaDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLembagaDetail();
  }

  Future<void> _fetchLembagaDetail() async {
    print(
        'Memuat detail untuk lembaga ID: ${widget.lembagaId}'); // Log ID lembaga
    final url =
        // Uri.parse('http://127.0.0.1:5000/detail-lembaga/${widget.lembagaId}');
        Uri.parse('https://sound-prompt-crawdad.ngrok-free.app/api/detail-lembaga/${widget.lembagaId}');
    try {
      final response = await http.get(url);
      print('Request URL: $url');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Data dari API: $data'); // Tambahkan log untuk memeriksa data
        setState(() {
          _lembagaDetail = data;
          _isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          backgroundColor: const Color.fromARGB(255, 208, 232, 197),
          title: Text(
            widget.lembagaName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 500,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color.fromARGB(255, 217, 217, 217),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.logoUrl,
                      height: 16,
                      width: 16,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _lembagaDetail?['nama_lengkap'],
                    style:
                        const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 217, 217, 217),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _lembagaDetail?['deskripsi'] ??
                          'Deskripsi tidak tersedia',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 217, 217, 217),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Alamat Kantor: ${_lembagaDetail?['alamat_kantor'] ?? 'Tidak tersedia'}"),
                        Text(
                            "Telepon: ${_lembagaDetail?['telepon'] ?? 'Tidak tersedia'}"),
                        Text(
                            "Email: ${_lembagaDetail?['email'] ?? 'Tidak tersedia'}"),
                        Text(
                            "Website Resmi: ${_lembagaDetail?['web_resmi'] ?? 'Tidak tersedia'}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
