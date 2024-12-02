import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BarangBenarScreen(),
    );
  }
}

class BarangBenarScreen extends StatelessWidget {
  const BarangBenarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Ditemukan'),
        backgroundColor: const Color(0xFF2879FE),
        foregroundColor: Colors.white, // Menetapkan warna teks di AppBar menjadi putih
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, color: Color(0xFF2879FE), size: 100), // Icon mirip dengan gambar di referensi
            const SizedBox(height: 20),
            const Text(
              'BARANG DITEMUKAN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Mohon periksa notifikasi Anda untuk menerima informasi lebih lanjut dari pihak yang menemukan barang Anda',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Color(0xFF858585),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFA5A5A5)),
                borderRadius: BorderRadius.zero,
              ),
              child: const Text(
                'Penemu Barang Anda adalah',
                style: TextStyle(
                  color: Color(0xFF191919),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nama Penemu',
                style: TextStyle(
                  color: Color(0xFFA5A5A5),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '[Nama Penemu]', // Dummy data
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No Telepon',
                style: TextStyle(
                  color: Color(0xFFA5A5A5),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '[No Telepon]', // Dummy data
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                '*Jangan lupa simpan informasi penemu bila Anda ingin menghubunginya',
                style: TextStyle(
                  color: Color(0xFFA5A5A5),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Kembali ke dashboard
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2879FE), // Warna background tombol sama dengan AppBar
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Kembali ke Dashboard',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
