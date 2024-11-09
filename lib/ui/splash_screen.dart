import 'package:flutter/material.dart';
import 'home.dart'; // Import halaman utama

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 186, 255, 218),
      body: Center(
        child: Image.asset(
          'images/logo-color.png', 
          width: 150, 
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
