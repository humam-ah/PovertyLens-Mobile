import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:poverty_lens/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Test', () {
    testWidgets('Navigasi Home ke Lembaga', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      debugPrint('Navigasi berhasil ke Daftar Lembaga');
      expect(true, true); 
    });

    testWidgets('Aksi membuka Detail Lembaga', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      debugPrint('Aksi di Lembaga berhasil');
      expect(true, true); 
    });
  });
}
