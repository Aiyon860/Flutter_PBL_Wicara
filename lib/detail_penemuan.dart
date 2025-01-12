import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/barang_benar.dart';
import 'package:flutter_mobile_pbl/barang_salah.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'custom_color.dart';
import 'dashboard_kehilangan.dart';

class DetailPenemuanPage extends StatelessWidget {
  final String title;
  final String description;
  final String nomor;
  final String nomorTelepon;
  final String nama;
  final String date;
  final String imagePath;
  final String status;
  final bool showButtons; // Tambahkan ini

  const DetailPenemuanPage({
    super.key,
    required this.title,
    required this.description,
    required this.nomor,
    required this.nomorTelepon,
    required this.nama,
    required this.date,
    required this.imagePath,
    required this.status,
    required this.showButtons // Tambahkan ini
  });

  Future<void> responTidak() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiWicara.respondNoTemuanUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'token': token,
          'id_penemuan': nomor,
          'konfirmasi': "TIDAK"
        },
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Connection timed out');
      });

      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to send data. HTTP Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Error sending data: $e");
    }
  }

  Future<void> responYa() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiWicara.respondYesTemuanUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'token': token,
          'id_penemuan': nomor,
          'konfirmasi': "YA"
        },
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Connection timed out');
      });

      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to send data. HTTP Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Error sending data: $e");
    }
  }

  Future<void> responSelesai() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiWicara.changeKehilanganStatusUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'token': token,
          'id_penemuan': nomor,
          'is_penemuan_from_pemilik': "false",
        },
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Connection timed out');
      });

      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to send data. HTTP Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Error sending data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.darkBlue,
      appBar: AppBar(
        title: Text(
          'Detail Penemuan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: CustomColor.darkBlue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imagePath,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          width: 400,
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      capitalizeFirstLetter(title),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Deskripsi:',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      description,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nama Pemilik:',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      nama,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tanggal upload:',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      date,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: (status == "Belum Dikonfirmasi"
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                  width: MediaQuery.of(context).size.width / 2.75,
                  child: ElevatedButton(
                  onPressed: () {
                  // Logika tombol batalkan
                  Future.delayed(const Duration(milliseconds: 100), () async {
                    await responTidak();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BarangSalahScreen()),
                    );
                  });
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Set custom border radius
                  ),
                  ),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(
                  Icons.close,
                  color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                  'TIDAK',
                  style: TextStyle(color: Colors.white),
                  ),
                  ],
                  )
                  ),
                  ),
                  ),
                  Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                  width: MediaQuery.of(context).size.width / 2.75,
                  child: ElevatedButton(
                  onPressed: () async {
                  // Logika tombol batalkan
                    await responYa();
                    Future.delayed(const Duration(milliseconds: 100), () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BarangBenarScreen(
                          namaPenemu: nama,
                          nomorTelepon: nomorTelepon,
                        )),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Set custom border radius
                  ),
                  ),
                  child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(
                  Icons.check,
                  color: Colors.white,
                  ),
                  SizedBox(width: 6),
                  Text(
                  'YA',
                  style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  ),
                  ),
                  ],
                  )
                  ),
                  ),
                  ),
                ],
              )
                : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2.75,
                      child: ElevatedButton(
                          onPressed: () {
                            // Logika tombol batalkan
                            Future.delayed(const Duration(milliseconds: 100), () async {
                              await responSelesai();
                              Future.delayed(const Duration(milliseconds: 100), () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LostItemsScreen()),
                                );
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Set custom border radius
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Selesai',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                      ),
                    ),
                  ),
                  ],
                )
            ),
            )
        ],
      ),
    );
  }

  String capitalizeFirstLetter(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }
}