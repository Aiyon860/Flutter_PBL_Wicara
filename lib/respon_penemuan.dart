import 'package:flutter/material.dart';
import 'custom_color.dart';

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
      backgroundColor: CustomColor.darkBlue,
      appBar: AppBar(
        leading: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 30,
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'TERIMA KASIH',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Laporan Anda berhasil kami terima dan akan segera kami sampaikan kepada korban',
              style: TextStyle(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Kembali ke dashboard
                Navigator.pushNamed(context, '/dashboard_kehilangan');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.goldColor, // Warna background tombol sama dengan AppBar
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Kembali ke Dashboard',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
