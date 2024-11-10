import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  const CustomBackground({Key? key, required this.child}) : super(key: key);

  final Widget child; // Widget anak untuk konten di atas background

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Latar belakang warna gradien pertama (Hijau kabur)
        Positioned(
          top: 150,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.green.withOpacity(0.3),
                  Colors.transparent,
                ],
                radius: 0.6,
              ),
            ),
          ),
        ),
        // Latar belakang warna gradien kedua (Ungu kabur)
        Positioned(
          top: 0,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.transparent,
                ],
                radius: 0.6,
              ),
            ),
          ),
        ),
        // Latar belakang warna gradien ketiga (Hijau muda kabur)
        Positioned(
          bottom: -100,
          left: 0,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.lightGreen.withOpacity(0.3),
                  Colors.transparent,
                ],
                radius: 0.6,
              ),
            ),
          ),
        ),
        // Konten yang berada di atas background
        child,
      ],
    );
  }
}
