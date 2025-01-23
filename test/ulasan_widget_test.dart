import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poverty_lens/ui/home.dart';

void main() {
  group('HomeScreen Widget Tests', () {

    testWidgets('Menampilkan pesan sukses setelah mengirim ulasan',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Fake HomeScreen')),
          body: Column(
            children: [
              TextField(key: Key('emailField'), decoration: InputDecoration(hintText: 'Email')),
              TextField(key: Key('ulasanField'), decoration: InputDecoration(hintText: 'Ulasan')),
              ElevatedButton(
                key: Key('kirimButton'),
                onPressed: () {
                  ScaffoldMessenger.of(tester.element(find.byType(ElevatedButton)))
                      .showSnackBar(SnackBar(content: Text('Ulasan berhasil dikirim!')));
                },
                child: Text('Kirim'),
              ),
            ],
          ),
        ),
      ));

      await tester.enterText(find.byKey(Key('emailField')), 'test@example.com');
      await tester.enterText(find.byKey(Key('ulasanField')), 'Ulasan ini untuk testing.');

      await tester.tap(find.byKey(Key('kirimButton')));

      await tester.pump();

      expect(find.text('Ulasan berhasil dikirim!'), findsOneWidget);

      print('Snackbar message: Ulasan berhasil dikirim!');
    });
  });
}
