import 'package:flutter/material.dart';
import 'custom_color.dart';
import 'dashboard_kehilangan.dart';

class BarangBenarScreen extends StatefulWidget {
  final String namaPenemu;
  final String nomorTelepon;

  const BarangBenarScreen({
    super.key,
    required this.namaPenemu,
    required this.nomorTelepon,
  });

  @override
  State<BarangBenarScreen> createState() => _BarangBenarScreenState();
}

class _BarangBenarScreenState extends State<BarangBenarScreen> {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                Icons.check,
                color: Colors.green,
                size: 200,
              ), // Ikon Close
            ),
            const SizedBox(height: 20),
            const Text(
              'BARANG DITEMUKAN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Mohon periksa notifikasi Anda untuk menerima informasi lebih lanjut dari pihak yang menemukan barang Anda',
              style: TextStyle(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Penemu Barang Anda adalah',
                        style: TextStyle(
                          color: Color(0xFF191919),
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nama Penemu',
                        style: TextStyle(
                          color: Color(0xFFA5A5A5),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.namaPenemu, // Dummy data
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'No Telepon',
                        style: TextStyle(
                          color: Color(0xFFA5A5A5),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.nomorTelepon, // Dummy data
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            TextSpan(
                              text: " Jangan lupa simpan informasi penemu bila Anda ingin menghubunginya",
                              style: TextStyle(
                                color: Color(0xFFA5A5A5),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Kembali ke dashboard
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LostItemsScreen()),
                );
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
