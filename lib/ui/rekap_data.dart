import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class RekapDataScreen extends StatefulWidget {
  const RekapDataScreen({super.key});

  @override
  _RekapDataScreenState createState() => _RekapDataScreenState();
}

class _RekapDataScreenState extends State<RekapDataScreen> {
  String selectedRange = "2021-2023";
  List<dynamic> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://povertylens.my.id/rekap-data-ajax?tahun=$selectedRange'),
      );

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
        });
      } else {
        showError("Failed to fetch data");
      }
    } catch (e) {
      showError("Error occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void downloadCSV() async {
  final url = 'http://povertylens.my.id/download-csv?tahun=$selectedRange';
  try {
    final uri = Uri.parse(url);

    // Cek apakah URL dapat dibuka
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault, // Membuka di browser eksternal
      );
    } else {
      // Tampilkan pesan error jika URL tidak dapat dibuka
      showError("Gagal membuka tautan unduhan.");
    }
  } catch (e) {
    // Tangani jika terjadi error saat mencoba membuka URL
    showError("Terjadi kesalahan saat mengunduh file: $e");
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
            'Rekap Data',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terakhir Diperbarui : 25 Januari 2024',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedRange,
                  items: const [
                    DropdownMenuItem(value: "2021-2023", child: Text("2021 - 2023")),
                    DropdownMenuItem(value: "2018-2020", child: Text("2018 - 2020")),
                    DropdownMenuItem(value: "2015-2017", child: Text("2015 - 2017")),
                    DropdownMenuItem(value: "2011-2013", child: Text("2011 - 2013")),
                    DropdownMenuItem(value: "2008-2010", child: Text("2008 - 2010")),
                    DropdownMenuItem(value: "2005-2007", child: Text("2005 - 2007")),
                    DropdownMenuItem(value: "2002-2004", child: Text("2002 - 2004")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRange = value;
                      });
                      fetchData();
                    }
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: downloadCSV,
                  style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 152, 0)),
                  child: const Row(
                    children: [
                      Icon(Icons.download, color: Colors.white),
                      SizedBox(width: 5),
                      Text('Download', style: TextStyle(
                            color: Colors.white,
                          ),),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Tahun')),
                          DataColumn(label: Text('Garis Kemiskinan')),
                          DataColumn(label: Text('Jumlah Penduduk Miskin')),
                          DataColumn(label: Text('Persentase Penduduk Miskin')),
                          DataColumn(label: Text('Indeks Kedalaman Kemiskinan')),
                          DataColumn(label: Text('Indeks Keparahan Kemiskinan')),
                          DataColumn(label: Text('Gini Rasio')),
                        ],
                        rows: data
                            .map((row) => DataRow(cells: [
                                  DataCell(Text(row['tahun'].toString())),
                                  DataCell(Text(row['garis_kemiskinan'].toString())),
                                  DataCell(Text(row['jumlah_penduduk_miskin'].toString())),
                                  DataCell(Text(row['presentase_penduduk_miskin'].toString())),
                                  DataCell(Text(row['indeks_kedalaman_kemiskinan'].toString())),
                                  DataCell(Text(row['indeks_keparahan_kemiskinan'].toString())),
                                  DataCell(Text(row['gini_rasio'].toString())),
                                ]))
                            .toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
