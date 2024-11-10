import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poverty_lens/temp/background.dart';

class DetailLembagaScreen extends StatefulWidget {
  final String lembagaId;
  final String lembagaName;
  final String logoUrl;

  DetailLembagaScreen({required this.lembagaId, required this.lembagaName, required this.logoUrl});

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
    final url = Uri.parse('http://localhost:8000/2'); 
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detailData = data['data']?.firstWhere(
          (item) => item['lembaga_id'] == widget.lembagaId,
          orElse: () => null,
        );
        setState(() {
          _lembagaDetail = detailData;
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
      appBar: AppBar(
        backgroundColor: Color.fromARGB(25, 254, 1, 84),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.lembagaName,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: CustomBackground(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      '${widget.logoUrl}',
                      height: 80,
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.lembagaName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _lembagaDetail?['deskripsi'] ?? 'Deskripsi tidak tersedia',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Alamat Kantor: ${_lembagaDetail?['alamat_kantor'] ?? 'Tidak tersedia'}"),
                          Text("Telepon: ${_lembagaDetail?['telepon'] ?? 'Tidak tersedia'}"),
                          Text("Email: ${_lembagaDetail?['email'] ?? 'Tidak tersedia'}"),
                          Text("Website Resmi: ${_lembagaDetail?['web_resmi'] ?? 'Tidak tersedia'}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
