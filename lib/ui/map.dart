import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GlobalKey _mapKey = GlobalKey();
  LatLng _selectedLocation = LatLng(-6.858944, 109.147861);

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

  Future<String> _getKelurahanFromCoordinates(LatLng location) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=${location.latitude}&lon=${location.longitude}&format=json&addressdetails=1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        // Ambil nama kelurahan (atau bagian lainnya jika perlu)
        String kelurahan = address['suburb'] ?? 'Kelurahan tidak ditemukan';
        return kelurahan;
      } else {
        throw Exception("Failed to get location");
      }
    } catch (e) {
      print("Error getting kelurahan: $e");
      return 'Kelurahan tidak ditemukan';
    }
  }

  Future<void> _captureMap() async {
    try {
      // Tangkap gambar
      RenderRepaintBoundary boundary =
          _mapKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      String base64Image = "data:image/png;base64," + base64Encode(pngBytes);

      // Kirim gambar ke backend
      final result = await _sendImageToBackend(base64Image);

      // Dummy kelurahan (dapat dihubungkan ke API geolokasi)
      String kelurahan = await _getKelurahanFromCoordinates(_selectedLocation);

      // Navigasi kembali dengan data
      Navigator.pop(context, {
        'image': base64Image,
        'result': result,
        'kelurahan': kelurahan,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menangkap map')),
      );
    }
  }

  Future<Map<String, dynamic>?> _sendImageToBackend(String base64Image) async {
    final url = Uri.parse("https://povertylens.my.id/process");

    try {
      // Kirim data gambar sebagai form-data
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'image': base64Image},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody; // Data hasil pemrosesan dari backend
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
      backgroundColor: Colors.white,
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
          backgroundColor: Color.fromARGB(255, 22, 163, 74),
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
