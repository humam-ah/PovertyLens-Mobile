// Future<void> _fetchLembagaData() async {
  //   final url = Uri.parse('http://phbtegal.com:5013/lembaga');
  //   final headers = {
  //     'API-Key': '64fb3b903fbd44122f9ba6ac6a5c92d7',
  //   };

  //   try {
  //     final response = await http.get(url, headers: headers);

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       setState(() {
  //         _lembagaList = data;
  //         _filteredLembagaList = _lembagaList;
  //         _isLoading = false;
  //       });
  //     } else {
  //       print('Failed to load data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

import 'dart:convert';
import 'package:http/http.dart' as http;

class LembagaService {
  final http.Client client;

  LembagaService({required this.client});

  Future<List<dynamic>> fetchLembagaData(String url) async {
    try {
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}
