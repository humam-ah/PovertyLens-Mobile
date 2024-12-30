import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mysql1/mysql1.dart';

class DatabaseService {
  Future<MySqlConnection> getConnection() async {
    // Muat file sertifikat dari aset
    final cert = await rootBundle.load('assets/ssl/isrgrootx1.pem');
    final sslCert = SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificatesBytes(cert.buffer.asUint8List());

    // Konfigurasi koneksi MySQL
    final settings = ConnectionSettings(
      host: 'gateway01.ap-southeast-1.prod.aws.tidbcloud.com',
      port: 4000,
      user: '21wQtGdq5xU1Jzz.root',
      password: '2KXHciu6kxinKNEW',
      db: 'povertylens',
      useSSL: true, // Aktifkan SSL
    );

    return await MySqlConnection.connect(settings);
  }

  Future<List<Map<String, dynamic>>> fetchLembagaData() async {
    final conn = await getConnection();
    final results = await conn.query('SELECT id, nama, logo_url FROM lembaga');

    List<Map<String, dynamic>> data = results
        .map((row) => {
              'id': row['id'],
              'nama': row['nama'],
              'logo_url': row['logo_url'],
            })
        .toList();

    await conn.close();
    return data;
  }
}
