import 'package:flutter/material.dart';
import 'barang_salah.dart'; // Impor layar 'Barang Salah'
import 'barang_benar.dart'; // Impor layar 'Barang Ditemukan'

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: KonfirmPenemuanScreen(),
    );
  }
}

class KonfirmPenemuanScreen extends StatelessWidget {
  const KonfirmPenemuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Penemuan'),
        backgroundColor: Colors.blue, // Mengubah warna AppBar menjadi biru
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Apakah barang ini milik Anda?'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigasi ke layar Barang Salah
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangSalahScreen()));
                },
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Warna background tombol
              ),
                child: const Text('TIDAK'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigasi ke layar Barang Ditemukan
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangBenarScreen()));
                },
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Warna background tombol
              ),
                child: const Text('YA'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Menambahkan informasi penemu
          const Icon(Icons.info, size: 50), // Ikon informasi
          const SizedBox(height: 10),
          const Text('Nama Penemu: '), // Nama penemu
          const SizedBox(height: 10),
          const Text('No. WhatsApp: '), // Nomor telepon
          const SizedBox(height: 10),
          const Text('Deskripsi: Tas ransel hitam'), // Deskripsi
        ],
      ),
    );
  }
}
