import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_color.dart';
import 'detail_barang.dart';
import 'detail_penemuan.dart';

class KehilanganModel {
  final String? nomor;
  final String? judul;
  final String? deskripsi;
  final String? nama;
  final String? lokasi;
  final String? tanggalUpload;
  final String? imagePath;
  final String? milikUser;
  final String? status;
  final bool imageExist;
  final bool isTemuan;

  KehilanganModel({
    required this.nomor,
    required this.judul,
    required this.deskripsi,
    required this.nama,
    required this.lokasi,
    required this.tanggalUpload,
    required this.imagePath,
    required this.milikUser,
    required this.status,
    required this.imageExist,
    required this.isTemuan
  });

  factory KehilanganModel.fromJson(Map<String, dynamic> json) {
    return KehilanganModel(
      nomor: json['id_kejadian'].toString() as String? ?? '',
      judul: json['nama_barang'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      nama: json['nama_pemilik'] as String? ?? '',
      lokasi: json['lokasi'] as String? ?? '',
      tanggalUpload: json['tanggal'] as String? ?? '',
      imagePath: json['lampiran'] as String? ?? '',
      milikUser: json['milik_user'] as String? ?? '',
      status: json['nama_status_kehilangan'] as String? ?? '',
      imageExist: json['image_exist'] as bool,
      isTemuan: false,
    );
  }
}

class TemuanModel {
  final String? nomor;
  final String? judul;
  final String? deskripsi;
  final String? nama;
  final String? nomorTelepon;
  final String? tanggalUpload;
  final String? imagePath;
  final String? status;
  final bool isTemuan;

  TemuanModel({
    required this.nomor,
    required this.judul,
    required this.deskripsi,
    required this.nama,
    required this.nomorTelepon,
    required this.tanggalUpload,
    required this.imagePath,
    required this.status,
    required this.isTemuan,
  });

  factory TemuanModel.fromJson(Map<String, dynamic> json) {
    return TemuanModel(
      nomor: json['id_penemuan'].toString() as String? ?? '',
      judul: json['nama_barang'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      nama: json['nama_penemu'] as String? ?? '',
      nomorTelepon: json['nomor_telepon'] as String? ?? '',
      tanggalUpload: json['tanggal'] as String? ?? '',
      imagePath: json['lampiran'] as String? ?? '',
      status: json['nama_status_temuan'] as String? ?? '',
      isTemuan: true
    );
  }
}

class LostItemsScreen extends StatefulWidget {
  const LostItemsScreen({super.key});

  @override
  State<LostItemsScreen> createState() => _LostItemsScreenState();
}

class _LostItemsScreenState extends State<LostItemsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController; // Declare TabController
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allKehilangan = [];
  List<dynamic> _filteredKehilangan = [];
  String _errorMessage = '';
  int _selectedTabIndex = 0;
  final List<String> _endpoints = [
    'https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/get_belum_ditemukan_app.php',
    'https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/get_ditemukan_app.php',
    'https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/get_temuan_app.php',
    'https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/get_riwayat_saya_app.php',
  ];
  int visibleCount = 0;

  @override
  void initState() {
    super.initState();

    // Initialize TabController
    _tabController = TabController(length: _endpoints.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
          fetchKehilangan(_endpoints[_selectedTabIndex]); // Fetch data for the selected tab
        });
      }
    });

    // Fetch data for the initial tab
    fetchKehilangan(_endpoints[_selectedTabIndex]);

    _searchController.addListener(_filterItems);
  }

  Future<void> fetchKehilangan(String endpoint) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'token': token},
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Connection timed out');
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            if (responseData['data'].isEmpty) {
              _filteredKehilangan.clear();
              return;
            }

            if (responseData['is_temuan']) {
              _allKehilangan = (responseData['data'] as List)
                  .map((data) => TemuanModel.fromJson(data as Map<String, dynamic>))
                  .toList();
            } else {
              _allKehilangan = (responseData['data'] as List)
                  .map((data) => KehilanganModel.fromJson(data as Map<String, dynamic>))
                  .toList();
            }
            _filteredKehilangan = List.from(_allKehilangan);
            visibleCount = _filteredKehilangan.length;
          });
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load data');
        }
      } else {
        throw Exception('Failed to load data. HTTP Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching data: $e";
      });
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredKehilangan = _allKehilangan.where((item) {
        final title = item.judul?.toLowerCase() ?? '';
        final description = item.deskripsi?.toLowerCase() ?? '';
        return title.contains(query) || description.contains(query);
      }).toList();
      visibleCount = _filteredKehilangan.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: CustomColor.bgColorHome,
        appBar: AppBar(
          backgroundColor: CustomColor.darkBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          title: const Text(
            "Dashboard Kehilangan",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          centerTitle: true,
        ),
        body: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: CustomColor.darkBlue,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TabBar(
                      tabAlignment: TabAlignment.center,
                      padding: EdgeInsets.zero,
                      isScrollable: true,
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 3,
                      labelColor: CustomColor.goldColor,
                      unselectedLabelColor: Colors.white,
                      indicatorColor: CustomColor.goldColor,
                      labelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                      ),
                      tabs: [
                        Tab(
                          child: Text(
                            'Belum Ditemukan',
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                        Tab(child: Text(
                            'Ditemukan',
                            textAlign: TextAlign.center,
                            softWrap: true,
                          )
                        ),
                        Tab(
                          child: Text(
                            'Konfirmasi Penemuan',
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Riwayat Saya',
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Center(child: Text(_errorMessage))
              else if (_filteredKehilangan.isEmpty)
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.6, // Adjust height as needed
                  color: Colors.grey[200], // Set the gray background color
                  child: Center(
                    child: Text(
                      _selectedTabIndex == 2 ? 'Tidak ada data temuan' : 'Tidak ada data yang sesuai',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: visibleCount < _filteredKehilangan.length
                        ? visibleCount
                        : _filteredKehilangan.length,
                    itemBuilder: (context, index) {
                      final item = _filteredKehilangan[index];
                      return item.isTemuan
                          ? TemuanItemCard(
                        nomor: (index + 1).toString(),
                        title: item.judul ?? 'Judul Tidak Tersedia',
                        nama: item.nama ?? 'Nama Tidak Tersedia',
                        nomorTelepon: item.nomorTelepon ?? 'Nomor Telepon Tidak Tersedia',
                        imagePath: item.imagePath ?? 'default.jpg',
                        date: item.tanggalUpload ?? 'Tanggal Tidak Tersedia',
                        status: item.status ?? 'Status Tidak Tersedia',
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPenemuanPage(
                                    title: item.judul ?? 'Judul Tidak Tersedia',
                                    nama: item.nama ?? 'Nama Tidak Tersedia',
                                    description: item.deskripsi ?? 'Deskripsi Tidak Tersedia',
                                    nomor: item.nomor ?? 'Nomor Tidak Tersedia',
                                    nomorTelepon: item.nomorTelepon ?? 'Nomor Telepon Tidak Tersedia',
                                    date: item.tanggalUpload ?? 'Tanggal Tidak Tersedia',
                                    imagePath: item.imagePath ?? "Gambar tidak tersedia",
                                    showButtons: _selectedTabIndex == 0, // Tampilkan hanya di
                                    status: item.status ?? "Status tidak tersedia",// tab Belum Ditemukan
                                  ),
                                )
                            );
                          });
                        },
                        )
                          : LostItemCard(
                        nomor: (index + 1).toString(),
                        title: item.judul ?? 'Judul Tidak Tersedia',
                        nama: item.nama ?? 'Nama Tidak Tersedia',
                        description: item.deskripsi ?? 'Deskripsi Tidak Tersedia',
                        date: item.tanggalUpload ?? 'Tanggal Tidak Tersedia',
                        imagePath: item.imagePath ?? 'default.jpg',
                        imageExist: item.imageExist,
                        milikUser: item.milikUser ?? '',
                        status: item.status ?? '',
                        selectedIndex: _selectedTabIndex,
                        onTap: () {
                          // Navigasi ke DetailBarangPage dengan parameter lengkap
                          Future.delayed(const Duration(milliseconds: 100), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailBarangPage(
                                isOwner: item.milikUser ?? '', // Ubah sesuai kebutuhan
                                title: item.judul ?? 'Judul Tidak Tersedia',
                                nama: item.nama ?? 'Nama Tidak Tersedia',
                                description: item.deskripsi ?? 'Deskripsi Tidak Tersedia',
                                nomor: item.nomor ?? 'Nomor Tidak Tersedia',
                                date: item.tanggalUpload ?? 'Tanggal Tidak Tersedia',
                                imageExist: item.imageExist,
                                imagePath: item.imagePath ?? "Gambar tidak tersedia",
                                showButtons: _selectedTabIndex == 0, // Tampilkan hanya di tab Belum Ditemukan
                                ),
                              )
                            );
                          });
                        },
                      );
                    },
                  ),
                ),

              if (visibleCount < _filteredKehilangan.length)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        visibleCount += 3;
                      });
                    },
                    child: const Text('Lihat lebih banyak'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LostItemCard extends StatelessWidget {
  final String nomor;
  final String title;
  final String nama;
  final String description;
  final String date;
  final String imagePath;
  final bool imageExist;
  final String milikUser;
  final String status;
  final int selectedIndex;
  final VoidCallback onTap;

  const LostItemCard({
    super.key,
    required this.nomor,
    required this.title,
    required this.nama,
    required this.description,
    required this.date,
    required this.imagePath,
    required this.imageExist,
    required this.milikUser,
    required this.status,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String judulCapitalized = title;
    List<String> judulSplitted = title.split(' ');

    if (judulSplitted.length > 1) {
      judulCapitalized =
          judulSplitted.map((word) => capitalizeFirstLetter(word)).join(' ');
    }

    Color statusColor = CustomColor.liatAduanSayaFontColor;

    if (status == "Belum Ditemukan") {
      statusColor = CustomColor.goldColor;
    } else if (status == "Ditemukan") {
      statusColor = CustomColor.selesaiColor;
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16), // Optional spacing around the ListTile
      decoration: BoxDecoration(
        color: CustomColor.liatAduanSayaBgColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.1), // Shadow color
          blurRadius: 6, // How much to blur the shadow
          offset: const Offset(0, 4), // Offset x and y
        )],
      ),
      child: Material(
        color: Colors.transparent, // Ensure the Material widget doesn't add a background color
        borderRadius: BorderRadius.circular(16), // Match the container's borderRadius
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16), // Match the ripple to the container's shape
          splashColor: Colors.grey.withOpacity(0.3), // Optional ripple effect color
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("No. $nomor"),
                  if (selectedIndex == 3)
                    ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 5, minHeight: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              status,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )),
                ],
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Set the border radius
                  child: imageExist
                      ? Image.network(
                    imagePath,
                    height: MediaQuery.of(context).size.height / 15,
                    width: MediaQuery.of(context).size.width / 6.5,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    "images/image_default.png",
                    height: MediaQuery.of(context).size.height / 15,
                    width: MediaQuery.of(context).size.width / 6.5,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judulCapitalized,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                        softWrap: true,
                      ),
                      Text(selectedIndex != 3 ? nama : description,
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
                            formatDate(date),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class TemuanItemCard extends StatelessWidget {
  final String nomor;
  final String title;
  final String nama;
  final String nomorTelepon;
  final String date;
  final String imagePath;
  final String status;
  final VoidCallback onTap;

  const TemuanItemCard({
    super.key,
    required this.nomor,
    required this.title,
    required this.nama,
    required this.nomorTelepon,
    required this.date,
    required this.imagePath,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = (status == "Belum Dikonfirmasi"
        ? CustomColor.liatAduanSayaFontColor
        : CustomColor.goldColor
    );

    String judulCapitalized = title;
    List<String> judulSplitted = title.split(' ');

    if (judulSplitted.length > 1) {
      judulCapitalized =
          judulSplitted.map((word) => capitalizeFirstLetter(word)).join(' ');
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16), // Optional spacing around the ListTile
      decoration: BoxDecoration(
        color: CustomColor.liatAduanSayaBgColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.1), // Shadow color
          blurRadius: 6, // How much to blur the shadow
          offset: const Offset(0, 4), // Offset x and y
        )],
      ),
      child: Material(
        color: Colors.transparent, // Ensure the Material widget doesn't add a background color
        borderRadius: BorderRadius.circular(16), // Match the container's borderRadius
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16), // Match the ripple to the container's shape
          splashColor: Colors.grey.withOpacity(0.3), // Optional ripple effect color
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("No. $nomor"),
                      ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 5, minHeight: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                status,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Set the border radius
                      child: Image.network(
                        imagePath,
                        height: MediaQuery.of(context).size.height / 15,
                        width: MediaQuery.of(context).size.width / 6.5,
                        fit: BoxFit.cover,
                      )
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            judulCapitalized,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                            softWrap: true,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: nama,
                                  style: const TextStyle(
                                    color: CustomColor.liatAduanSayaFontColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ' • ',
                                  style: const TextStyle(
                                    color: CustomColor.liatAduanSayaFontColor,
                                  ),
                                ),
                                TextSpan(
                                  text: nomorTelepon,
                                  style: const TextStyle(
                                    color: CustomColor.liatAduanSayaFontColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Text("Tanggal Upload",
                                  style: TextStyle(
                                    color: CustomColor.liatAduanSayaFontColor,
                                  )),
                              const SizedBox(width: 5),
                              Text(
                                formatDate(date),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ]),
                ]),
          ),
        ),
      ),
    );
  }
}

Future<void> checkToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  print('Token yang tersimpan aduan: $token');
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