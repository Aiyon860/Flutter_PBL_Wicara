import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/dashboard_pengaduan.dart';
import 'custom_color.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      home: const ResponKehilangan(),
    );
  }
}

class ResponKehilangan extends StatelessWidget {
  const ResponKehilangan({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: CustomColor.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/dashboard_kehilangan');
          },
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                'Laporan Anda berhasil dikirim',
                style: TextStyle(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Kami akan memverifikasi laporan Anda da  lam waktu maksimal 3 hari. Terima kasih atas partisipasi Anda, harap menunggu konfirmasi lebih lanjut.',
                style: TextStyle(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
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
                    'Lihat Laporan Kehilangan Saya',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
