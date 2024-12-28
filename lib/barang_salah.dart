import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/dashboard_kehilangan.dart';

import 'custom_color.dart';

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
      backgroundColor: CustomColor.darkBlue,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30,
          ), onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LostItemsScreen()),
          );
        },
        ),
        centerTitle: true,
        title: const Text(
          'Konfirmasi Penemuan',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
          ), // Warna teks AppBar putih
        ),
        backgroundColor: Colors.transparent, // Warna latar belakang AppBar
        iconTheme: const IconThemeData(color: Colors.white), // Warna ikon AppBar putih
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Colors.white,
              shadowColor: Colors.grey.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 200,
              ), // Ikon Close
            ),
            const SizedBox(height: 20),
            const Text(
                'BARANG SALAH',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                ),
            ), // Judul
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Laporan Anda akan diperbarui dan pencarian barang akan dilanjutkan untuk menemukan hasil yang lebih akurat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                ), // Warna teks abu-abu
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Tutup layar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LostItemsScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: CustomColor.goldColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), // Radius 50%
                ),
              ),
              child: const Text(
                'Kembali ke Dashboard',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                ), // Warna teks abu-abu
              ),
            ),
          ],
        ),
      ),
    );
  }
}
