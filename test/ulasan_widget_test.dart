import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:poverty_lens/ui/home.dart';
import 'ulasan_widget_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('HomeScreen Widget Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      // Stub untuk GET request
      when(mockClient
              .get(Uri.parse('https://povertylens.my.id/api/data-kemiskinan')))
          .thenAnswer((_) async => http.Response('{"data": []}', 200));

      // Stub untuk POST request (contoh, jika digunakan)
      when(mockClient.post(
        Uri.parse('https://povertylens.my.id/api/data-kemiskinan'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Success', 200));
    });

    testWidgets('Menampilkan pesan error jika field kosong',
        (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue =
          Size(800, 1600); // Sesuaikan ukuran sesuai kebutuhan
      addTearDown(() => tester.binding.window.clearPhysicalSizeTestValue());
      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(httpClient: mockClient),
      ));

      // Cari tombol Kirim
      final kirimButton = find.text('Kirim');

      // Tekan tombol Kirim
      await tester.ensureVisible(kirimButton);
      await tester.tap(kirimButton);

      // Tunggu animasi selesai
      await tester.pump();

      // Periksa apakah Snackbar dengan pesan error muncul
      expect(find.text('Semua field harus diisi!'), findsOneWidget);
    });

    testWidgets('Mengirim ulasan berhasil', (WidgetTester tester) async {
      // Mock respons HTTP dengan status 200
      when(mockClient.post(
        any,
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Success', 200));

      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(httpClient: mockClient),
      ));

      // Isi field Email dan Komentar
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(
          find.byType(TextField).last, 'Ulasan ini untuk testing.');

      // Tekan tombol Kirim
      final kirimButton = find.text('Kirim');
      await tester.tap(kirimButton);

      // Tunggu animasi selesai
      await tester.pump();

      // Periksa apakah Snackbar dengan pesan sukses muncul
      expect(find.text('Ulasan berhasil dikirim!'), findsOneWidget);

      // Pastikan field dikosongkan
      expect(find.text('test@example.com'), findsNothing);
      expect(find.text('Ulasan ini untuk testing.'), findsNothing);
    });

    testWidgets('Mengirim ulasan gagal', (WidgetTester tester) async {
      // Mock respons HTTP dengan status 500
      when(mockClient.post(
        any,
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 500));

      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(httpClient: mockClient),
      ));

      // Isi field Email dan Komentar
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(
          find.byType(TextField).last, 'Ulasan ini untuk testing.');

      // Tekan tombol Kirim
      final kirimButton = find.text('Kirim');
      await tester.tap(kirimButton);

      // Tunggu animasi selesai
      await tester.pump();

      // Periksa apakah Snackbar dengan pesan gagal muncul
      expect(find.text('Gagal mengirim ulasan!'), findsOneWidget);
    });
  });
}
