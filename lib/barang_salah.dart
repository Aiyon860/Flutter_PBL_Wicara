import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BarangSalahScreen(),
    );
  }
}

class BarangSalahScreen extends StatelessWidget {
  const BarangSalahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Barang Salah',
          style: TextStyle(color: Colors.white), // Warna teks AppBar putih
        ),
        backgroundColor: const Color(0xFF2879FE), // Warna latar belakang AppBar
        iconTheme: const IconThemeData(color: Colors.white), // Warna ikon AppBar putih
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.close, color: Colors.red, size: 100), // Ikon Close
            const SizedBox(height: 20),
            const Text('BARANG SALAH', style: TextStyle(fontSize: 24)), // Judul
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Laporan Anda akan diperbarui dan pencarian barang akan dilanjutkan untuk menemukan hasil yang lebih akurat.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF858585)), // Warna teks abu-abu
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                // Tutup layar
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF858585)), // Warna outline abu-abu
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), // Radius 50%
                ),
              ),
              child: const Text(
                'Tutup',
                style: TextStyle(color: Color(0xFF858585)), // Warna teks abu-abu
              ),
            ),
          ],
        ),
      ),
    );
  }
}
