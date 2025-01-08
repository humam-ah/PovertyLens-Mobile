import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
} 

class _MapScreenState extends State<MapScreen> {
  final GlobalKey _mapKey = GlobalKey();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Mengunci orientasi ke landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    // Mengembalikan orientasi ke default (potrait dan landscape)
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _captureAndProcessMap() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Tangkap peta sebagai gambar
      RenderRepaintBoundary boundary =
          _mapKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      print('a');

      // Kompres gambar sebelum dikirim
      Uint8List? compressedImage = await FlutterImageCompress.compressWithList(
        pngBytes,
        quality: 70, // Ubah kualitas gambar (0-100)
      );

      print('b');

      String base64Image = base64Encode(compressedImage);

      print('c');

      // Kirim gambar ke backend untuk diproses
      final response = await http.post(
        // Uri.parse('https://sound-prompt-crawdad.ngrok-free.app/process'),
        Uri.parse('http://127.0.0.1:5000/process'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'image': 'data:image/png;base64,$base64Image'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);

        // Contoh tambahan untuk kelurahan (jika diperlukan)
        result['kelurahan'] = 'Contoh Kelurahan';

        // Kembali ke layar sebelumnya dengan hasil
        Navigator.pop(context, result);
      } else {
        throw Exception('Gagal memproses gambar: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memproses gambar: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(),
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          )),
          backgroundColor: const Color.fromARGB(255, 208, 232, 197),
          title: const Text(
            'PovertyMaps',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Ambil Wilayah yang ingin di Capture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              RepaintBoundary(
                key: _mapKey,
                child: Container(
                  width: 400,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(-6.858944, 109.147861), // Pusat peta
                      zoom: 16.0, // Skala zoom awal
                      maxZoom: 16.0, // Zoom maksimum
                      minZoom: 16.0, // Zoom minimum (tetap)
                      maxBounds: LatLngBounds(
                        LatLng(-6.8985, 109.0741), // Sudut barat daya
                        LatLng(-6.8441, 109.1616), // Sudut timur laut
                      ),
                      interactiveFlags: InteractiveFlag.drag |
                          InteractiveFlag.flingAnimation, // Hanya geser
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(-6.858944, 109.147861),
                            width: 40,
                            height: 40,
                            builder: (context) => const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_isProcessing)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: CircularProgressIndicator(),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _captureAndProcessMap,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text("Capture dan Proses"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
