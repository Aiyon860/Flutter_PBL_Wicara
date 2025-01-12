import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/dashboard_kehilangan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'custom_color.dart';

class DetailBarangPage extends StatelessWidget {
  final String isOwner;
  final String title;
  final String description;
  final String nomor;
  final String nama;
  final String date;
  final bool imageExist;
  final String imagePath;
  final bool showButtons; // Tambahkan ini

  const DetailBarangPage({
    super.key,
    required this.isOwner,
    required this.title,
    required this.description,
    required this.nomor,
    required this.nama,
    required this.date,
    required this.imageExist,
    required this.imagePath,
    required this.showButtons, // Tambahkan ini
  });

  Future<void> changeStatusToFound() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiWicara.changeKehilanganStatusUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'token': token,
          'id_kejadian': nomor,
          'is_penemuan_from_pemilik': "true",
        },
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Connection timed out');
      });

      if (response.statusCode == 200) {
        print(response.body);
      } else {
        throw Exception('Failed to send data. HTTP Status: ${response.statusCode}');
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
        title: const Text(
          'Detail Barang',
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
          if (showButtons) // Tampilkan tombol hanya jika `showButtons` true
            Align(
              alignment: Alignment.center,
              child: isOwner == '1'
                  ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {
                          // Logika tombol batalkan
                          Future.delayed(const Duration(milliseconds: 100), () async {
                            print("Batalkan Ditekan");
                            await changeStatusToFound();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LostItemsScreen()),
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
                              'Batalkan',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                      ),
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                      onPressed: () {
                        // Logika tombol batalkan
                        Future.delayed(const Duration(milliseconds: 100), () {
                          print("Upload Ditekan");
                          Navigator.pushNamed(
                            context,
                            '/form_penemuan',
                            arguments: { 'id_kejadian': nomor },
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.goldColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Set custom border radius
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_upload_outlined,
                            color: Colors.black,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Upload',
                            style: TextStyle(
                                color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                                    ),
                                  ),
                  ),
            ),
        ],
      ),
    );
  }

  String capitalizeFirstLetter(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }
}