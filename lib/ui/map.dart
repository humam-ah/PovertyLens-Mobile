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
        ui.Image image = await boundary.toImage(pixelRatio: 2.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        String base64Image = base64Encode(pngBytes);

        await _sendImageToBackend(base64Image);

        // Simpan gambar ke file lokal
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/map_screenshot.png';
        File file = File(filePath);
        await file.writeAsBytes(pngBytes);

        // Berikan feedback bahwa tangkapan layar berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Map berhasil disimpan di $filePath')),
        );
      }
    } catch (e) {
      print('Error capturing map: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menangkap map')),
      );
    }
  }

  Future<void> _sendImageToBackend(String base64Image) async {
    final url = Uri.parse("https://sound-prompt-crawdad.ngrok-free.app/process");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "image": base64Image,
        },
      );
      print('Sending request to: $url');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["error"] != null) {
          throw Exception(data["error"]);
        }

        // Tampilkan hasil overlay dan persentase
        _showResult(data);
      } else {
        throw Exception("Gagal mengirim gambar: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending image to backend: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memproses gambar')),
      );
    }
  }

  void _showResult(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Hasil Proses Gambar"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Image.memory(
                  base64Decode(data["overlay_image"]),
                  width: 300,
                  height: 300,
                ),
                SizedBox(height: 20),
                ...data["percentages"].entries.map((entry) {
                  final category = entry.key;
                  final percentage = entry.value;
                  return Text("$category: ${percentage.toStringAsFixed(2)}%");
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tutup"),
            ),
          ],
        );
      },
    );
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
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
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
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}
