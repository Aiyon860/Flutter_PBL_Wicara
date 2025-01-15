import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'custom_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotifikasiScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotifikasiScreen extends StatefulWidget {
  @override
  _NotifikasiScreenState createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  String filter = "Pengaduan";
  bool hasPengaduan = false; // Add this flag to track Pengaduan data availability
  bool hasKehilangan = false; // Add this flag to track Pengaduan data availability
  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> filteredNotifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifikasi();
  }

  Future<void> fetchNotifikasi() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan di SharedPreferences');
      }

      final response = await http.post(
        Uri.parse(ApiWicara.fetchNotificationAllUrl),
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
            _allNotifications = (responseData['data'] as List)
                .map((data) => NotificationModel.fromJson(data))
                .toList();

            hasPengaduan = _allNotifications.any((notif) => notif.kodeNotif == 'A');
            hasKehilangan = _allNotifications.any((notif) => notif.kodeNotif != 'A');
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

  @override
  Widget build(BuildContext context) {
    setState(() {
      filteredNotifications = _allNotifications
          .where((notification) => (filter == "Pengaduan" && notification.kodeNotif == 'A') ||
          (filter == "Kehilangan" && notification.kodeNotif != 'A'))
          .toList();

      if (!hasPengaduan && filter == "Pengaduan") {
        filteredNotifications.clear();
      } else if (!hasKehilangan && filter == "Kehilangan") {
        filteredNotifications.clear();
      }
    });

    return Scaffold(
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
          "Notifikasi",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TabBarSection(
            onTabChanged: (newFilter) {
              setState(() {
                filter = newFilter;
              });
            },
          ),
          const SizedBox(height: 10),
          filteredNotifications.isNotEmpty
            ? Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: filteredNotifications.length,
                itemBuilder: (context, index) {
                  final notification = filteredNotifications[index];
                  return NotificationTile(
                    idKejadian: notification.idKejadian,
                    judulAduan: notification.judulAduan,
                    namaBarang: notification.namaBarang,
                    kodeNotif: notification.kodeNotif,
                    gambar: notification.gambar,
                    imageExist: notification.imageExist,
                    isViewed: notification.isViewed,
                    status: notification.status,
                    tanggal: notification.tanggal,
                    jenisAduan: notification.jenisAduan,
                  );
                },
              ),
            )
            : Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    "Tidak ada data $filter",
                  style: TextStyle(
                    color: CustomColor.liatAduanSayaFontColor,
                  )
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const FilterButton({
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFB903) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(0xFFFFB903) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class TabBarSection extends StatelessWidget {
  final ValueChanged<String> onTabChanged;

  const TabBarSection({required this.onTabChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        color: CustomColor.darkBlue,
        child: TabBar(
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
          onTap: (index) {
            onTabChanged(index == 0 ? "Pengaduan" : "Kehilangan");
          },
          tabs: const [
            Tab(
              child: Text(
                'Pengaduan',
                textAlign: TextAlign.center,
              ),
            ),
            Tab(
              child: Text(
                'Kehilangan',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class NotificationModel {
  final int idKejadian;
  final String? judulAduan;
  final String? namaBarang;
  final String kodeNotif;
  final String gambar;
  final bool imageExist;
  final bool isViewed;
  final String status;
  final String tanggal;
  final String? jenisAduan;

  const NotificationModel({
    required this.idKejadian,
    this.judulAduan,
    this.namaBarang,
    required this.kodeNotif,
    required this.gambar,
    required this.imageExist,
    required this.isViewed,
    required this.status,
    required this.tanggal,
    this.jenisAduan,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idKejadian: json['id_kejadian'] as int,
      judulAduan: json['judul'] as String? ?? "Judul tidak tersedia",
      namaBarang: json['nama_barang'] as String? ?? "Nama barang tidak tersedia",
      kodeNotif: json['kode_notif'] as String? ?? "Kode tidak tersedia",
      gambar: json['gambar'] as String? ?? "",
      imageExist: json["image_exist"] as bool? ?? false,
      isViewed: (json['is_viewed'] as int) == 1,
      status: json['status'] as String? ?? "Status tidak tersedia",
      tanggal: json['tanggal'] as String? ?? "Tanggal tidak tersedia",
      jenisAduan: json["jenis_aduan"] as String? ?? "Jenis tidak tersedia",
    );
  }
}

class NotificationTile extends StatelessWidget {
  final int idKejadian;
  final String? judulAduan;
  final String? namaBarang;
  final String kodeNotif;
  final String gambar;
  final bool imageExist;
  final bool isViewed;
  final String status;
  final String tanggal;
  final String? jenisAduan;

  const NotificationTile({
    required this.idKejadian,
    this.judulAduan,
    this.namaBarang,
    required this.kodeNotif,
    required this.gambar,
    required this.imageExist,
    required this.isViewed,
    required this.status,
    required this.tanggal,
    this.jenisAduan,
  });

  Future<void> changeNotificationStatusToBeRead() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiWicara.updateNotificationFlagUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'token': token,
          'id_kejadian': idKejadian.toString(),
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
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16), // Optional spacing around the ListTile
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(16), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Shadow color with opacity
            spreadRadius: 1, // How much the shadow spreads
            blurRadius: 10, // Softness of the shadow
            offset: const Offset(0, 4), // Position of the shadow (x, y)
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent, // Ensure the Material widget doesn't add a background color
        borderRadius: BorderRadius.circular(16), // Match the container's borderRadius
        child: InkWell(
          onTap: () {
            Future.delayed(const Duration(milliseconds: 100), () async {
              if (!isViewed) {
                await changeNotificationStatusToBeRead();
              }
              Navigator.pushNamed(
                context,
                '/notification_detail',
                arguments: { 'id_kejadian': idKejadian },
              );
            });
          },
          borderRadius: BorderRadius.circular(16), // Match the ripple to the container's shape
          splashColor: Colors.grey.withOpacity(0.3), // Optional ripple effect color
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width / 35,
                  height: height / 5,
                  decoration: BoxDecoration(
                    color: !isViewed ? Colors.red : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8), // Jarak antara lingkaran dan gambar
                Container(
                  width: width / 8,
                  height: height / 17,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Set the border radius
                    child: imageExist
                        ? Image.network(
                      gambar,
                      height: MediaQuery.of(context).size.height / 10,
                      width: MediaQuery.of(context).size.width / 6.5,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      "images/aduan_kehilangan_picture_default.png",
                      height: MediaQuery.of(context).size.height / 10,
                      width: MediaQuery.of(context).size.width / 6.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF717171),
                    ),
                    children: [
                      TextSpan(
                        text: kodeNotif,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const TextSpan(
                        text: " - ",
                      ),
                      TextSpan(
                        text: judulAduan != "Judul tidak tersedia" ? judulAduan : namaBarang,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(
                        text: " - ",
                      ),
                      TextSpan(
                        text: status,
                      ),
                      if (jenisAduan != "Jenis tidak tersedia") ...[
                        const TextSpan(
                          text: " | ",
                        ),
                        TextSpan(
                          text: jenisAduan,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8), // Add spacing here
                Text(
                  tanggal,
                  style: const TextStyle(
                    color: Color(0xFF9F9F9F),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
