import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:poverty_lens/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Test', () {
    testWidgets('Navigasi dan menampilkan data lembaga',
        (WidgetTester tester) async {
      // Menjalankan aplikasi
      app.main();
      await tester.pumpAndSettle();

      // Memverifikasi apakah layar Home ditampilkan
      expect(find.text('Hai, Selamat Datang Povers!'), findsOneWidget);

      // Navigasi ke layar Lembaga
      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();

      // Verifikasi daftar lembaga ditampilkan
      expect(find.text('Baznas'), findsOneWidget);
      expect(find.text('Kementerian Sosial Republik Indonesia'), findsOneWidget);

      // Navigasi ke detail lembaga
      await tester.tap(find.text('Baznas'));
      await tester.pumpAndSettle();

      // Verifikasi detail lembaga ditampilkan
      expect(find.text('Badan Amil Zakat Nasional'), findsOneWidget);
      expect(find.text('Gedung Menara Taspen Lt. 1, Jl. Jend. Sudirman Kav. 2, Jakarta'),
          findsOneWidget);
    });
  });
}
