import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:poverty_lens/ui/home.dart';
import 'package:poverty_lens/ui/chatbot.dart';
import 'package:poverty_lens/ui/pindai.dart';
import 'package:poverty_lens/ui/lembaga.dart';
import 'package:poverty_lens/ui/rekap_data.dart';

void main() {
  testWidgets('Navigasi antar halaman berfungsi', (WidgetTester tester) async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/data') {
        return http.Response('{"data": "Mocked Response"}', 200);
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(httpClient: client),
      ),
    );

    // Verifikasi halaman awal
    expect(find.byType(HomeScreenContent), findsOneWidget);

    // Navigasi ke halaman ChatPage
    await tester.tap(find.byKey(Key('chatbot-icon')));
    await tester.pumpAndSettle();

    expect(find.byType(ChatPage), findsOneWidget);

    // Navigasi ke halaman PindaiScreen
    await tester.tap(find.byKey(Key('pindai-icon')));
    await tester.pumpAndSettle();

    expect(find.byType(PindaiScreen), findsOneWidget);

    // Navigasi ke halaman LembagaScreen
    await tester.tap(find.byKey(Key('lembaga-icon')));
    await tester.pumpAndSettle();

    expect(find.byType(LembagaScreen), findsOneWidget);

    // Navigasi ke halaman RekapDataScreen
    await tester.tap(find.byKey(Key('rekap-icon')));
    await tester.pumpAndSettle();

    expect(find.byType(RekapDataScreen), findsOneWidget);

    // Navigasi kembali ke HomeScreenContent
    await tester.tap(find.byKey(Key('home-icon')));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreenContent), findsOneWidget);
  });
}

