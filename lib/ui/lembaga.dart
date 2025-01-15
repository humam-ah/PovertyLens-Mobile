import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'detail_lembaga.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LembagaScreen extends StatefulWidget {
  final http.Client? httpClient;

  const LembagaScreen({super.key, this.httpClient});

  @override
  _LembagaScreenState createState() => _LembagaScreenState();
}

class _LembagaScreenState extends State<LembagaScreen> {
  late http.Client _client;
  List<dynamic> _lembagaList = [];
  List<dynamic> _filteredLembagaList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _client = widget.httpClient ?? http.Client();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLembagaData();
    });
  }

  Future<void> _fetchLembagaData() async {
    final url = Uri.parse(
        'https://povertylens.my.id/api/lembaga'); 
    try {
      final response = await (widget.httpClient ?? http.Client()).get(url);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _lembagaList = data;
          _filteredLembagaList = _lembagaList;
          _isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _filterLembaga(String query) {
    final filteredList = _lembagaList.where((lembaga) {
      final namaLembaga = lembaga['nama'].toLowerCase();
      final input = query.toLowerCase();
      return namaLembaga.contains(input);
    }).toList();

    setState(() {
      _filteredLembagaList = filteredList;
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cari Lembaga'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(hintText: 'Masukkan nama lembaga'),
            onChanged: (query) => _filterLembaga(query),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _searchController.clear();
                _filterLembaga('');
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cari'),
            ),
          ],
        );
      },
    );
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
            'Daftar Lembaga',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: _showSearchDialog,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 5,
                  ),
                  itemCount: _filteredLembagaList.length,
                  itemBuilder: (context, index) {
                    final lembaga = _filteredLembagaList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailLembagaScreen(
                              lembagaId: lembaga['id'].toString(),
                              lembagaName: lembaga['nama'],
                              logoUrl: 'https://povertylens.my.id${lembaga['logo_url']}',
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                   color: const Color.fromARGB(255, 217, 217, 217),
                                ),
                                margin: const EdgeInsets.only(left: 8),
                                width: 60,
                                height: 60,
                                child: CachedNetworkImage(
                                  imageUrl:
                                    'https://povertylens.my.id${lembaga['logo_url']}',
                                  height: 16,
                                  width: 16,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(padding: EdgeInsets.only(top: 8.0, left: 8.0)),
                                    Text(
                                      lembaga['nama'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 10,),
                                    const Text(
                                      "selengkapnya",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
    );
  }
}
