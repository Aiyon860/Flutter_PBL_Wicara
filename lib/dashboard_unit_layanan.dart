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
  final String idInstansi;
  final String namaInstansi;
  final String website;
  final String rataRataRating;
  final String totalRating;
  final String gambarInstansi;

  UnitLayanan({
    required this.idInstansi,
    required this.namaInstansi,
    required this.website,
    required this.rataRataRating,
    required this.totalRating,
    required this.gambarInstansi,
  });

  factory UnitLayanan.fromJson(Map<String, dynamic> json) {
    return UnitLayanan(
      idInstansi: json["id_instansi"] as String? ?? "ID Instansi Tidak Tersedia",
      namaInstansi: json["nama_instansi"] as String? ?? "Nama Instansi Tidak Tersedia",
      website: json["website"] as String? ?? "-",
      rataRataRating: json["rata_rata_rating"] as String? ?? "0",
      totalRating: json["total_rating"] as String? ?? "0",
      gambarInstansi: json["gambar_instansi"] as String? ?? "Gambar Tidak Tersedia",
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
          'https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/ambil_data_unit_layanan_app.php'),
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
      backgroundColor: CustomColor.bgColorHome,
      appBar: AppBar(
        title: const Text(
            'UNIT LAYANAN',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
            ),
        ),
        backgroundColor: CustomColor.darkBlue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
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
                      hintText: 'Cari Unit Layanan',
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
            child: _filteredUnitLayanan.isEmpty
                ? const Center(child: Text('Tidak ada data tersedia.'))
                : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  physics: const BouncingScrollPhysics(),
                    itemCount: _filteredUnitLayanan.length,
                    itemBuilder: (context, index) {
                      final unit = _filteredUnitLayanan[index];
                      return _buildUnitLayananPreview(
                              unit.idInstansi,
                              unit.namaInstansi,
                              unit.website,
                              int.parse(unit.rataRataRating),
                              unit.totalRating,
                              unit.gambarInstansi
                            );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitLayananPreview(
      String index,
      String nama,
      String website,
      int rataRataRating,
      String totalRating,
      String lampiran
  ) {
    return InkWell(
      onTap: () {
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UnitLayananScreen(idInstansi: index.toString()),
            ),
          );
        });
      },
      child: Container(
          margin: const EdgeInsets.only(bottom: 15.0),
          width: double.infinity,
          height: (MediaQuery.of(context).size.height / 3),
          decoration: BoxDecoration(
              color: CustomColor.liatAduanSayaBgColor,
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.1), // Shadow color
                blurRadius: 6, // How much to blur the shadow
                offset: const Offset(0, 4), // Offset x and y
              )],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.network(
                        "https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/assets/images/instansi/$lampiran",
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 4,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "images/default_unit_layanan_pic.png",
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 4,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                  ),
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
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          CustomColor.darkBlue.withOpacity(0.6),
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
                          '$rataRataRating/5',
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
                                  index < rataRataRating ? Icons.star : Icons.star_border,
                                  color: CustomColor.goldColor,
                                  size: 20,
                                );
                              }),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$totalRating Review' + (int.parse(totalRating) > 1 ? 's' : ''),
                              style: const TextStyle(
                                fontSize: 16,
                                color: CustomColor.liatAduanSayaFontColor,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.goldColor,
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8), // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Optional: Adjust button shape
                        ),
                      ),
                      onPressed: () {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UnitLayananScreen(idInstansi: index.toString()),
                            ),
                          );
                        });
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min, // Minimizes the width of the button
                        children: [
                          const Text(
                            "Detail",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16, // Optional: Adjust font size
                            ),
                          ),
                          const SizedBox(width: 4), // Adjust spacing between Text and Icon
                          const Icon(
                            Icons.chevron_right_outlined,
                            color: Colors.black,
                            size: 20, // Adjust size of the icon
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ],
          )),
    );
  }
}