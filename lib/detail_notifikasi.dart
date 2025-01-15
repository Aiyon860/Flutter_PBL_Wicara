import 'dart:convert';
import 'package:flutter_mobile_pbl/dashboard_notifikasi.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'custom_color.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Notification Screen',
      home: DetailNotificationScreen(),
    );
  }
}

class DetailNotificationScreen extends StatefulWidget {
  const DetailNotificationScreen({super.key});

  @override
  State<DetailNotificationScreen> createState() => _DetailNotificationScreenState();
}

class _DetailNotificationScreenState extends State<DetailNotificationScreen> {
  String nama = '';
  String pesanNotifikasi = '';
  String kodeNotif = '';
  int idKejadian = 0;
  bool _isDataFetched = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isDataFetched) {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      if (args != null) {
        setState(() {
          idKejadian = args["id_kejadian"];
        });
        fetchNotificationDetail();
        _isDataFetched = true;
      }
    }
  }

  Future<void> fetchNotificationDetail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan di SharedPreferences');
      }

      final response = await http.post(
        Uri.parse(ApiWicara.fetchNotificationDetailUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'token': token,
          'id_kejadian': idKejadian.toString(),
        },
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Connection timed out');
      });

      // Memeriksa status response dari server
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          var detailNotification = responseData["data"];
          setState(() {
            nama = detailNotification["nama_user"];
            pesanNotifikasi = detailNotification["pesan_notifikasi"];
            kodeNotif = detailNotification["kode_notif"];
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
    String jenisKejadian = '';

    if (kodeNotif == "A") {
      jenisKejadian = "Aduan";
    } else if (kodeNotif == "K") {
      jenisKejadian = "Kehilangan";
    } else {
      jenisKejadian = "Temuan";
    }

    return Scaffold(
      backgroundColor: CustomColor.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/dashboard_notification');
          },
        ),
        title: const Text(
          "Detail Notifikasi",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $nama!!',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        pesanNotifikasi,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        )
                      ),
                      const SizedBox(height: 30.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}