import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:poverty_lens/ui/lembaga.dart';
import 'package:http/http.dart' as http;


void main() {
  late http.Client mockClient;

  setUp(() {
    HttpOverrides.global = TestHttpOverrides();
    mockClient = MockClient((request) async {
      print('MockClient menerima request ke: ${request.url}');
      if (request.url.toString() == 'http://127.0.0.1:5000/lembaga') {
        print('Mengembalikan respons mock dengan status 200');
        return http.Response(
            jsonEncode([
              {
                "id": 1,
                "nama": "Baznas",
                "logo_url": "/static/images/lembaga/baznas.png"
              },
              {
                "id": 2,
                "nama": "Kementerian Sosial",
                "logo_url": "/static/images/lembaga/kemensos.png"
              },
            ]),
            200);
      }
      print('Mengembalikan respons mock dengan status 404');
      return http.Response('Not Found', 404);
    });
  });

  group('LembagaScreen Widget Test', () {
    testWidgets('Menampilkan loading indicator saat data sedang dimuat',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(MaterialApp(home: LembagaScreen(httpClient: mockClient)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Menampilkan data lembaga setelah fetch berhasil',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(MaterialApp(home: LembagaScreen(httpClient: mockClient)));
      await tester.pumpAndSettle(Duration(seconds: 10));

      expect(find.byType(Card), findsNWidgets(2));
    });
  });
}
