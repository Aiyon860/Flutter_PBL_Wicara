import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_color.dart';
import 'detail_unit_layanan.dart';

void main() {
  runApp(MaterialApp(
    home: const DashboardUnitLayananPage(),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: CustomColor.primaryColor),
      useMaterial3: true,
      fontFamily: "Poppins",
    ),
  ));
}

class UnitLayanan {
  final String namaInstansi;
  final String website;
  final String rataRataRating;
  final String totalRating;

  UnitLayanan({
    required this.namaInstansi,
    required this.website,
    required this.rataRataRating,
    required this.totalRating,
  });

  factory UnitLayanan.fromJson(Map<String, dynamic> json) {
    return UnitLayanan(
      namaInstansi: json["nama_instansi"] as String,
      website: json["website"] as String,
      rataRataRating: json["rata_rata_rating"] as String,
      totalRating: json["total_rating"] as String,
    );
  }
}

class DashboardUnitLayananPage extends StatefulWidget {
  const DashboardUnitLayananPage({super.key});

  @override
  DashboardUnitLayananPageState createState() => DashboardUnitLayananPageState();
}

class DashboardUnitLayananPageState extends State<DashboardUnitLayananPage> {
  List _filteredUnitLayanan = [];
  final TextEditingController _searchController = TextEditingController();
  List unitLayanan = [];

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
    _searchController.addListener(_onSearchChanged);
    checkToken();
    fetchDataUnitLayanan();
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
      _filteredUnitLayanan = unitLayanan.where((unit) {
        return unit.namaInstansi.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<bool> fetchDataUnitLayanan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan di SharedPreferences');
    }

    final response = await http.post(
      Uri.parse(
          'http://10.0.2.2/wicara/backend/api/mobile/ambil_data_unit_layanan_app.php'),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'token': token},
    ).timeout(const Duration(seconds: 5), onTimeout: () {
      throw Exception('Connection timed out');
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        setState(() {
          unitLayanan = (responseData['data'] as List)
              .map((data) => UnitLayanan.fromJson(data))
              .toList();
          _filteredUnitLayanan = unitLayanan; // Set initial display
        });
      } else {
        print("Error: ${responseData['message'] ?? 'Unknown error'}");
        throw Exception('Failed to load data from database');
      }
      return true;
    } else {
      print('Error: ${response.statusCode}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating Unit Layanan',
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
                hintText: 'Ketikkan Nama Unit Layanan',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredUnitLayanan.isEmpty
                  ? const Center(child: Text('Tidak ada data tersedia.'))
                  : ListView.builder(
                      itemCount: _filteredUnitLayanan.length,
                      itemBuilder: (context, index) {
                        final unit = _filteredUnitLayanan[index];
                        return _buildUnitLayananPreview(
                                unit.namaInstansi,
                                unit.website,
                                unit.rataRataRating,
                                unit.totalRating,
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

  Widget _buildUnitLayananPreview(
    String nama, 
    String website,
    String rataRataRating,
    String totalRating
  ) {
    String imagePath;

    if (nama == "UPA TIK") {
      imagePath = "images/upttik.png";
    } else if (nama == "UPA Perpustakaan") {
      imagePath = "images/perpus.jpg";
    } else {
      imagePath = "images/poliklinik.png";
    }

    return Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          width: double.infinity,
          height: (MediaQuery.of(context).size.height / 3),
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
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image(
                        image: ExactAssetImage(imagePath),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 4,
                        fit: BoxFit.cover,
                      )),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          CustomColor.darkBlue.withOpacity(0.5),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 10,
                      left: 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                          Text(
                            website,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          )
                        ],
                      ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${double.parse(rataRataRating)}/5.0',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Column(
                          children: [
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < double.parse(rataRataRating).floor() ? Icons.star : Icons.star_border,
                                  color: CustomColor.goldColor,
                                  size: 20,
                                );
                              }),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${int.parse(totalRating)} Reviews',
                              style: const TextStyle(
                                fontSize: 16,
                                color: CustomColor.liatAduanSayaFontColor,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ServiceUnitPage()),
                        );
                      },
                      child: const Row(
                        children: [
                          Text("Detail",
                              style: TextStyle(
                                color: Colors.black,
                              )),
                          Icon(
                            Icons.chevron_right_outlined,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ));
  }
}