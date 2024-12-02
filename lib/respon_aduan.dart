import 'package:flutter/material.dart';
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
      home: const ResponAduan(),
    );
  }
}

class ResponAduan extends StatelessWidget {
  const ResponAduan({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context, MaterialPageRoute(
                      builder: (context) =>
                          const HomeScreen(), // Navigasi ke halaman ketiga
                    ),);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon PNG
                    Image.asset(
                      'images/checklist.png', // Path menuju file PNG Anda
                      width: screenSize.width *
                          0.35, // Ukuran lebar icon responsif
                      height: screenSize.height *
                          0.2, // Ukuran tinggi icon responsif
                    ),
                    const SizedBox(width: 10), // Spasi antara icon dan teks
                    // Teks "Terima Kasih" dan "Aduan Anda berhasil dikirim"
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenSize.height * 0.05),
                          Text(
                            'Terima Kasih',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.07, // Responsif
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2879fe), // Warna biru
                            ),
                            softWrap: true,
                            maxLines: 2,
                          ),
                          const SizedBox(
                              height: 5), // Spasi antara teks atas dan bawah
                          Text(
                            'Aduan Anda berhasil dikirim',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.04, // Responsif
                              color: Colors.black, // Warna teks biasa
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aduan Anda telah berhasil dikirim.',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04, // Responsif
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2), // Spasi antara teks atas dan bawah
                  Text('Kami akan memverifikasi laporan Anda dalam ',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.04, // Responsif
                        color: Colors.black,
                      )),
                  const SizedBox(height: 15),
                  Text('Terima kasih atas partisipasi Anda, harap ',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.04, // Responsif
                        color: Colors.black,
                      )),
                  const SizedBox(height: 2), // Spasi antara teks atas dan bawah
                  Text('menunggu konfirmasi lebih lanjut.',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.04, // Responsif
                        color: Colors.black,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 36),
            Container(
              width: double.infinity, // Tombol melebar sesuai layar
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Aksi saat tombol ditekan
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const HomeScreen(), // Navigasi ke halaman ketiga
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2879fe), // Warna tombol biru
                  padding: EdgeInsets.symmetric(
                      vertical:
                          screenSize.height * 0.02), // Padding dalam tombol
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Lihat Aduan Saya',
                  style: TextStyle(
                    color: Colors.white, // Warna teks tombol putih
                    fontSize: screenSize.width * 0.04, // Responsif
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
