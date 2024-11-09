import 'package:flutter/material.dart';
import 'ui/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PovertyLens',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Atur SplashScreen sebagai halaman utama
    );
  }
}
