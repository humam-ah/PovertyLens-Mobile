import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:poverty_lens/services/lembaga_service.dart'; 

void main() {
  late MockClient client;
  late LembagaService service;

  setUp(() {
    client = MockClient((request) async {
      if (request.url.toString() == 'http://127.0.0.1:5000/lembaga') {
        return http.Response(jsonEncode([
          {"id": 1, "nama": "Baznas", "logo_url": "https://example.com/logo_a.png"},
          {"id": 2, "nama": "Kementerian Sosial Republik Indonesia", "logo_url": "https://example.com/logo_b.png"},
        ]), 200);
      }
      return http.Response('Not Found', 404);
    });

    service = LembagaService(client: client);
  });

  group('LembagaService', () {
    test('fetchLembagaData returns data on successful response', () async {
      final result = await service.fetchLembagaData('http://127.0.0.1:5000/lembaga');

      // Log the result for debugging
      print('Fetched Records: $result');

      // Assertions
      expect(result, isA<List<dynamic>>());
      expect(result.length, 2);
      expect(result[0]['nama'], 'Baznas');
      expect(result[1]['nama'], 'Kementerian Sosial Republik Indonesia');
    });

    test('fetchLembagaData throws exception on failed response', () async {
      expect(
        () async => await service.fetchLembagaData('http://127.0.0.1:5000/invalid'),
        throwsException,
      );
    });
  });
}
