import 'package:flutter/material.dart';

class PindaiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(
          'Pindai Wilayah',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Masukkan Gambar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Koordinat',
                hintText: 'ambil dari maps',
                suffixIcon: Icon(Icons.location_pin),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField('Input populasi penduduk'),
            SizedBox(height: 20),
            _buildTextField('Deskripsi Area'),
            SizedBox(height: 20),
            _buildTextField('Bantuan yang dibutuhkan'),
            SizedBox(height: 20),
            _buildTextField('Tahun atau Tanggal pengambilan gambar'),
            SizedBox(height: 20),
            _buildTextField('Kondisi Lingkungan'),
            SizedBox(height: 20),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tulis laporan Anda di sini..',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {},
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
