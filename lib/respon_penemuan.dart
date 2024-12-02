import 'package:flutter/material.dart';

// Impor layar konfirmasi penemuan

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ResponPenemuanScreen(),
    );
  }
}

class ResponPenemuanScreen extends StatelessWidget {
  const ResponPenemuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kirim Bukti Penemuan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color(0xFF2879FE), // Warna AppBar
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, color: Color(0xFF2879FE), size: 100), // Icon mirip dengan gambar di referensi
            const SizedBox(height: 10),
            const Text(
              'TERIMA KASIH',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 5), // Jarak 0.5 cm
            const Text(
              'Laporan Anda berhasil kami terima dan akan segera kami sampaikan kepada pemilik',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF858585),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '* Data Informasi Anda telah kami Simpan dan akan kami bagikan kepada pemilik',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                color: Color(0xFFA5A5A5),
                fontStyle: FontStyle.italic,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Kembali ke halaman konfirmasi penemuan
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyApp()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2879FE), // Warna background tombol
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
