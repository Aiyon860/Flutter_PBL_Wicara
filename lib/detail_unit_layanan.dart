import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api.dart';
import 'custom_color.dart';
import 'images_default.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UNIT LAYANAN',
      home: UnitLayananScreen(idInstansi: '5'), // Ganti '3' dengan ID instansi yang diinginkan
    );
  }
}

class UnitLayananScreen extends StatefulWidget {
  final String idInstansi;

  const UnitLayananScreen({required this.idInstansi, super.key});

  @override
  _UnitLayananScreenState createState() => _UnitLayananScreenState();
}

class _UnitLayananScreenState extends State<UnitLayananScreen> {
  Map<String, dynamic>? instansiData;

  // Fungsi untuk menghitung waktu relatif
  String _timeAgo(String uploadTime) {
    final now = DateTime.now();
    final uploadDate = DateTime.parse(uploadTime);
    final difference = now.difference(uploadDate);

    if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} bulan yang lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Fungsi untuk mengambil data dari API
  Future<void> fetchDetailUnitLayanan() async {
    try {
      final url = Uri.parse(ApiWicara.fetchDetailUnitLayananUrl + widget.idInstansi);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          instansiData = json.decode(response.body);
        });
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDetailUnitLayanan();
  }

  @override
  Widget build(BuildContext context) {
    if (instansiData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('UNIT LAYANAN', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final instansi = instansiData!['instansi'] ?? {};
    final ulasanList = List<Map<String, dynamic>>.from(instansiData!['ulasan'] ?? []);

    // Menghitung rata-rata rating
    final double averageRating = ulasanList.isNotEmpty
        ? ulasanList.fold(0.0, (sum, ulasan) => sum + (ulasan['skala_bintang']?.toDouble() ?? 0)) / ulasanList.length
        : 0.0;

    final int averageRatingInt = averageRating.toInt();

    return Scaffold(
      backgroundColor: CustomColor.darkBlue,
      appBar: AppBar(
        backgroundColor: CustomColor.darkBlue,
        title: const Text(
            'UNIT LAYANAN',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
            ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Instansi
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: instansi["image_exist"]
              ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                        instansi['gambar_instansi'],
                        height: MediaQuery.of(context).size.height / 3,
                        width: double.infinity,
                        fit: BoxFit.cover,
                  )
                )
              : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white, // Border color
                    width: 1.0, // Border width
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                      DefaultImage.detailUnitLayananPath,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 4,
                      fit: BoxFit.cover,
                    ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: CustomColor.darkBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Instansi
                        Text(
                          instansi['nama_instansi'] ?? 'Nama Instansi Tidak Tersedia',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Rating Bintang
                        Row(
                          children: [
                            Text(
                              '${averageRating.toStringAsFixed(0)} / 5',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(5, (index) {
                                if (index < averageRatingInt) {
                                  return const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  );
                                } else {
                                  return const Icon(
                                    Icons.star_border,
                                    color: Colors.amber,
                                  );
                                }
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ulasanList.length} Review${ulasanList.length > 1 ? 's' : ''}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          instansi['deskripsi'] ?? 'Deskripsi Tidak Tersedia',
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        Text(
                          ulasanList.length > 1 ? 'Semua Ulasan' : 'Tidak Ada Ulasan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...ulasanList.map((ulasan) {
                          // Format nama untuk anonim
                          String displayName = ulasan['anonim'] == 1
                              ? '${ulasan['nama']?.substring(0, 1)}*****'
                              : ulasan['nama'] ?? 'Unknown';

                          // Hitung waktu relatif
                          String relativeTime = _timeAgo(ulasan['tanggal'] ?? '');

                          final profileName = ulasan['profile'] ?? ''; // Ambil nama file dari database
                          final profilePictureUrl = ApiWicara.fetchProfilePictureUrl + profileName;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    relativeTime,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Profil dan nama user
                                  Row(
                                    children: [
                                      ClipOval(
                                        child: Image.network(
                                          profilePictureUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 40,
                                              height: 40,
                                              color: Colors.grey,
                                              child: const Icon(Icons.person, color: Colors.white),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          // Rating Bintang di bawah nama pengguna
                                          Row(
                                            children: List.generate(5, (index) {
                                              if (index < ulasan['skala_bintang'].floor()) {
                                                return const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 20,
                                                );
                                              } else {
                                                return const Icon(
                                                  Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 20,
                                                );
                                              }
                                            }),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  Text(ulasan['isi_komentar'] ?? 'Komentar Tidak Tersedia'),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
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
