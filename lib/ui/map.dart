import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GlobalKey _mapKey = GlobalKey();

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

  Future<void> _captureMap() async {
    try {
      RenderRepaintBoundary boundary =
          _mapKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

      if (boundary != null) {
        ui.Image image = await boundary.toImage(
            pixelRatio: 1.0); // Atur pixelRatio sesuai kebutuhan
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Kirim gambar langsung ke backend
        final result = await _sendImageToBackend(pngBytes);

        // Navigasi kembali ke PindaiScreen dengan hasil capture
        Navigator.pop(context, {
          'image': base64Encode(pngBytes), // Kirim gambar sebagai Base64
          'result': result,               // Kirim hasil dari backend jika ada
        });
      }
    } catch (e) {
      print('Error capturing map: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menangkap map')),
      );
    }
  }

  Future<Map<String, dynamic>?> _sendImageToBackend(
      Uint8List imageBytes) async {
    final url =
        Uri.parse("https://sound-prompt-crawdad.ngrok-free.app/process");

    try {
      // Buat file sementara untuk dikirim
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/temp_image.png';
      final tempFile = File(filePath);
      await tempFile.writeAsBytes(imageBytes);

      // Kirim sebagai multipart request
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', tempFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        return data; // Data hasil pemrosesan dari backend
      } else {
        throw Exception("Gagal mengirim gambar: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending image to backend: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memproses gambar')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          )),
          backgroundColor: Color.fromARGB(255, 208, 232, 197),
          title: Text(
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
              SizedBox(
                height: 20,
              ),
              Text(
                'Ambil Wilayah yang ingin di Capture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              RepaintBoundary(
                key: _mapKey,
                child: Container(
                  width: 400,
                  height: 300,
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
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(-6.858944, 109.147861),
                            width: 40,
                            height: 40,
                            builder: (context) => Icon(
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _captureMap,
                child: Text('Capture Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
