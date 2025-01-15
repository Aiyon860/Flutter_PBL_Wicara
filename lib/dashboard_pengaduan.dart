import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/home.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
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
  final String nomor;
  final String status;
  final String jenisAduan;
  final String judul;
  final String deskripsi;
  final String tanggalUpload;
  final String imagePath;
  final bool imageExist;

  AduanModel({
    required this.nomor,
    required this.status,
    required this.jenisAduan,
    required this.judul,
    required this.deskripsi,
    required this.tanggalUpload,
    required this.imagePath,
    required this.imageExist,
  });

  factory AduanModel.fromJson(Map<String, dynamic> json) {
    return AduanModel(
      nomor: json['nomor'] as String,
      status: json['status'] as String,
      jenisAduan: json["jenisAduan"] as String,
      judul: json['judul'] as String,
      deskripsi: json['deskripsi'] as String,
      tanggalUpload: json['tanggalUpload'] as String,
      imagePath: json['imagePath'] as String,
      imageExist: json['imageExist'] as bool,
    );
  }
}

class AduanPage extends StatefulWidget {
  const AduanPage({super.key});

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
        Uri.parse(ApiWicara.fetchPengaduanAllUrl),
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
        return aduan.judul.toLowerCase().contains(query) ||
            aduan.deskripsi.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.bgColorHome,
      appBar: AppBar(
        title: const Text('Aduan Saya',
            style: TextStyle(color: Colors.white, fontSize: 16.0)),
        backgroundColor: CustomColor.darkBlue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: CustomColor.darkBlue,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Aduan',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _filteredAduan.isEmpty
                ? const Center(child: Text('Tidak ada data tersedia.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredAduan.length,
                    itemBuilder: (context, index) {
                      final aduan = _filteredAduan[index];
                      return _buildPreviewAduanSaya(
                          index + 1,
                          aduan.judul,
                          aduan.jenisAduan,
                          aduan.tanggalUpload,
                          aduan.status,
                          aduan.imagePath,
                          aduan.imageExist,
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
    );
  }

  Widget _buildPreviewAduanSaya(
    int index,
    String judul,
    String jenisAduan,
    String tanggal,
    String status,
    String lampiran,
      bool imageExist,
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
      decoration: BoxDecoration(
          color: CustomColor.liatAduanSayaBgColor,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color
            blurRadius: 6, // How much to blur the shadow
            offset: const Offset(0, 4), // Offset x and y
          )],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
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
            ClipRRect(
              borderRadius: BorderRadius.circular(10), // Set the border radius
              child: imageExist
                  ? Image.network(
                "$lampiran",
                height: MediaQuery.of(context).size.height / 15,
                width: MediaQuery.of(context).size.width / 6.5,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                "images/aduan_kehilangan_picture_default.png",
                height: MediaQuery.of(context).size.height / 15,
                width: MediaQuery.of(context).size.width / 6.5,
                fit: BoxFit.cover,
              ),
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