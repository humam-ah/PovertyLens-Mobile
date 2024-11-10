import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poverty_lens/temp/background.dart';
import 'detail_lembaga.dart';

class LembagaScreen extends StatefulWidget {
  @override
  _LembagaScreenState createState() => _LembagaScreenState();
}

class _LembagaScreenState extends State<LembagaScreen> {
  List<dynamic> _lembagaList = [];
  List<dynamic> _filteredLembagaList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLembagaData();
  }

  Future<void> _fetchLembagaData() async {
    final url = Uri.parse('http://localhost:8000/3'); 
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _lembagaList = data['data'];
          _filteredLembagaList = _lembagaList; 
          _isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
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
          title: Text('Cari Lembaga'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: 'Masukkan nama lembaga'),
            onChanged: (query) => _filterLembaga(query),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _searchController.clear();
                _filterLembaga('');
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cari'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(25, 254, 1, 84),
        title: Text(
          'Daftar Lembaga',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: _showSearchDialog,
            ),
          ),
        ],
      ),
      body: CustomBackground(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3,
                  ),
                  itemCount: _filteredLembagaList.length,
                  itemBuilder: (context, index) {
                    final lembaga = _filteredLembagaList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailLembagaScreen(
                              lembagaId: lembaga['id'],
                              lembagaName: lembaga['nama'],
                              logoUrl: lembaga['logo_url'],
                            ),
                          ),
                        );
                      },
        
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Image.asset(
                                '${lembaga['logo_url']}', 
                                height: 40,
                                width: 40,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  lembaga['nama'],
                                  style: TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
