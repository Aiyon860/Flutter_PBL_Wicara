import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_color.dart';

void main() {
  runApp(MaterialApp(
    home: const AduanPage(),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: CustomColor.primaryColor),
      useMaterial3: true,
      fontFamily: "Poppins",
    ),
  ));
}

class AduanModel {
  final String? nomor;
  final String? status;
  final String? judul;
  final String? deskripsi;
  final String? tanggalUpload;
  final String? imagePath;

  AduanModel({
    this.nomor,
    this.status,
    this.judul,
    this.deskripsi,
    this.tanggalUpload,
    this.imagePath,
  });

  factory AduanModel.fromJson(Map<String, dynamic> json) {
    return AduanModel(
      nomor: json['nomor'] as String?,
      status: json['status'] as String?,
      judul: json['judul'] as String? ?? 'Tidak ada judul',
      deskripsi: json['deskripsi'] as String? ?? 'Tidak ada deskripsi',
      tanggalUpload: json['tanggalUpload'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }
}

class AduanPage extends StatefulWidget {
  const AduanPage({Key? key}) : super(key: key);

  @override
  _AduanPageState createState() => _AduanPageState();
}

class _AduanPageState extends State<AduanPage> {
  List<AduanModel> _allAduan = [];
  List<AduanModel> _filteredAduan = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchPengaduan() async {
    try {
      // Mendapatkan token yang tersimpan di SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan di SharedPreferences');
      }

      // Menggunakan POST request untuk mengirim token
      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2/wicara/backend/api/mobile/ambil_pengaduan_app.php'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'token': token},
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Connection timed out');
      });

      // Memeriksa status response dari server
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          setState(() {
            _allAduan = (responseData['data'] as List)
                .map((data) => AduanModel.fromJson(data))
                .toList();
            _filteredAduan = _allAduan; // Set initial display
          });
        } else {
          print("Error: ${responseData['message'] ?? 'Unknown error'}");
          throw Exception('Failed to load data from database');
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        throw Exception('Failed to load data due to server error');
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      print('Token yang tersimpan kehilangan: $token');
    } else {
      print('Tidak ada token yang tersimpan');
    }
  }

//   Future<void> kirimToken() async {
//   var url = Uri.parse('http://10.0.2.2/tailwindpbl/src/backend/get_pengaduan.php');

//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString('token'); // Ambil token yang tersimpan

//   final response = await http.post(
//     url,
//     headers: {"Content-Type": "application/x-www-form-urlencoded"},
//     body: {'token': token ?? ''},
//   );

//   print("Response status: ${response.statusCode}");
//   print("Response body: ${response.body}");
// }

  @override
  void initState() {
    super.initState();
    //kirimToken();
    fetchPengaduan();
    _searchController.addListener(_onSearchChanged);
    checkToken();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAduan = _allAduan.where((aduan) {
        return aduan.judul!.toLowerCase().contains(query) ||
            aduan.deskripsi!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aduan Saya',
            style: TextStyle(color: Colors.white, fontSize: 16.0)),
        backgroundColor: CustomColor.primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ketikkan Nama Aduan',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredAduan.isEmpty
                  ? const Center(child: Text('Tidak ada data tersedia.'))
                  : ListView.builder(
                      itemCount: _filteredAduan.length,
                      itemBuilder: (context, index) {
                        final aduan = _filteredAduan[index];
                        return AduanCard(
                          nomor: aduan.nomor ?? '',
                          status: aduan.status ?? 'Status tidak diketahui',
                          judul: aduan.judul ?? 'Tidak ada judul',
                          deskripsi: aduan.deskripsi ?? 'Tidak ada deskripsi',
                          tanggalUpload:
                              aduan.tanggalUpload ?? 'Tanggal tidak tersedia',
                          imagePath: aduan.imagePath,
                        );
                      },
                    ),
            ),
            Container(
              height: 10,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0),
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewAduanSaya(
    int index,
    String judul,
    String jenisAduan,
    String tanggal,
    String status,
    String lampiran,
  ) {
    Color selectedColor;

    if (status == "Selesai") {
      selectedColor = CustomColor.selesaiColor;
    } else if (status == "Diproses") {
      selectedColor = CustomColor.goldColor;
    } else if (status == "Ditolak" || status == "Dibatalkan") {
      selectedColor = CustomColor.requiredColor;
    } else {
      selectedColor = CustomColor.liatAduanSayaFontColor;
    }

    String judulCapitalized = judul;
    List<String> judulSplitted = judul.split(' ');

    if (judulSplitted.length > 1) {
      judulCapitalized =
          judulSplitted.map((word) => capitalizeFirstLetter(word)).join(' ');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 6,
      decoration: BoxDecoration(
          color: CustomColor.liatAduanSayaBgColor,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7.5,
              offset: const Offset(0, 2),
            )
          ]),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("No. $index"),
              ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 5, minHeight: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 14,
                        color: selectedColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ))
            ],
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Image.asset(
              "images/ac.png",
              height: MediaQuery.of(context).size.height / 10,
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judulCapitalized,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                Text(jenisAduan,
                    style: const TextStyle(
                      color: CustomColor.liatAduanSayaFontColor,
                    )),
                Row(
                  children: [
                    const Text("Tanggal Upload",
                        style: TextStyle(
                          color: CustomColor.liatAduanSayaFontColor,
                        )),
                    const SizedBox(width: 5),
                    Text(
                      formatDate(tanggal),
                    ),
                  ],
                )
              ],
            )
          ]),
        ]),
      ),
    );
  }

  String formatDate(String mysqlDatetime) {
    DateTime parsedDate = DateTime.parse(mysqlDatetime);
    String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
    return formattedDate;
  }

  String capitalizeFirstLetter(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }
}

class AduanCard extends StatelessWidget {
  final String nomor;
  final String status;
  final String judul;
  final String deskripsi;
  final String tanggalUpload;
  final String? imagePath;

  const AduanCard({
    Key? key,
    required this.nomor,
    required this.status,
    required this.judul,
    required this.deskripsi,
    required this.tanggalUpload,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null && imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imagePath!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 60,
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(nomor,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(status, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(judul,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(deskripsi, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Tanggal Upload $tanggalUpload',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
