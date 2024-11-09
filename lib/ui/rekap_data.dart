import 'package:flutter/material.dart';

class RekapDataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rekap Data',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terakhir Diperbarui : 25 Januari 2024',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text('2021 - 2023'),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.download, color: Colors.black),
                      SizedBox(width: 5),
                      Text('Download', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Wilayah Inflasi')),
                    DataColumn(label: Text('Garis Kemiskinan (Rp/Kapita/Bulan)')),
                    DataColumn(label: Text('2021')),
                    DataColumn(label: Text('2022')),
                    DataColumn(label: Text('2023')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Kota Tegal')),
                      DataCell(Text('523.413,000')),
                      DataCell(Text('565.826,000')),
                      DataCell(Text('565.826,000')),
                      DataCell(Text('565.826,000')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Jawa Tengah')),
                      DataCell(Text('409.193,000')),
                      DataCell(Text('438.833,000')),
                      DataCell(Text('438.833,000')),
                      DataCell(Text('438.833,000')),
                    ]),
                    // Tambahkan lebih banyak DataRow sesuai dengan data Anda
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
